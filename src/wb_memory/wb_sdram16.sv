module wb_sdram16
(
   input clk,
   input rst,
   wishbone_b3.slave bus,
   output [1:0] ba,
   output[11:0] addr,
   output       ras_n,
   output       cas_n,
   output       we_n,
   output       cke,
   output       cs_n,
   output [1:0] dqm,
   inout [15:0] data,
   output       clk_out
);


logic [15:0] za_data;
logic        za_valid;
logic        za_waitrequest;

typedef enum logic [1:0] { IDLE, S1, S2, S3 } State;
State state;
logic gotLowerHalfWord;

logic cs;
assign cs = bus.cyc & bus.stb;

logic mywe;
always@(negedge clk)
begin
   if( cs )
      mywe = bus.we;
end

//Latch Lower Half_Word
always_ff@(posedge clk)
begin
   if( !gotLowerHalfWord && za_valid )
      bus.dat_s2m[15:0] = za_data;
   else
      bus.dat_s2m[15:0] = bus.dat_s2m[15:0];
end
assign bus.dat_s2m[31:16] = za_data;

always_ff@(negedge clk or posedge rst)
begin
   if( rst )
   begin
      state = IDLE;
      gotLowerHalfWord = 0;
   end
   else
   case(state)
      IDLE:
         begin
            state = (cs)?S1:IDLE;
            gotLowerHalfWord = 0;
         end
      S1: // RD(ADR1) / WR(ADR1,DAT1)
         begin
            state = (!za_waitrequest)?S2:S1;
            gotLowerHalfWord = 0;
         end
      S2: // RD(ADR2,DAT1?) / WR(ADR2,DAT2)
         begin
            if( mywe ) //WR
            begin
               state = za_waitrequest?S2:IDLE;
            end
            else //RD
            begin
               state = za_waitrequest?S2:S3;
            end

            gotLowerHalfWord = gotLowerHalfWord || za_valid;
         end
      S3:
         begin
            state = (gotLowerHalfWord && za_valid)?IDLE:S3;
            gotLowerHalfWord = gotLowerHalfWord || za_valid;
         end
      default
         begin
            state = IDLE;
            gotLowerHalfWord = 0;
         end
   endcase
end

assign bus.rty = 1'b0;
assign bus.err = 1'b0;
assign bus.ack = mywe?(state == S2 && !za_waitrequest):(state == S3 && gotLowerHalfWord && za_valid);

logic half_word;
assign half_word = state == S2;
sdram myram
(
   // inputs:
   .az_addr({bus.adr[22:2], half_word}),    //We do half word reads
   .az_be_n( ~bus.sel[ (half_word?3:1) -: 2 ] ),//Bring in the right select bits
   .az_cs( cs ),//FYI This isn't actually used... I hate them so much
   .az_data( bus.dat_m2s[ (half_word?31:15) -: 16 ] ),
   .az_rd_n( ~( (~mywe) && (state == S1 || state == S2)) ),
   .az_wr_n( ~( ( mywe) && (state == S1 || state == S2)) ),

   .clk( ~clk ),
   .reset_n( ~rst ),

   // outputs:
   .za_data,
   .za_valid,
   .za_waitrequest,

   //RAM MODULE
   .zs_addr( addr ),
   .zs_ba( ba ),
   .zs_cas_n( cas_n ),
   .zs_cke( cke ),
   .zs_cs_n( cs_n ),
   .zs_dq( data ),
   .zs_dqm( dqm ),
   .zs_ras_n( ras_n ),
   .zs_we_n( we_n )
);
assign clk_out = ~clk;

endmodule

