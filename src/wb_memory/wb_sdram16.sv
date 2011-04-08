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
   inout [15:0] data
);

typedef enum logic [1:0] { IDLE, DAT1, DAT1B, DAT2 } State;
State state;

logic half_word;
assign half_word = state == DAT1 || state == DAT1B;

logic [15:0] za_data;
logic        za_valid;
logic        za_waitrequest;

logic cs;
assign cs = bus.cyc & bus.stb;
sdram myram
(
   // inputs:
   .az_addr({bus.adr[22:2], half_word}),    //We do half word reads
   .az_be_n( ~bus.sel[ (half_word?3:1) -: 2 ] ),//Bring in the right select bits
   .az_cs( cs ),//FYI This isn't actually used... I hate them so much
   .az_data( bus.dat_m2s[ (half_word?31:15) -: 16 ] ),
   .az_rd_n( ~(cs && (~bus.we) && (state == IDLE || state == DAT1 || state == DAT1B)) ),
   .az_wr_n( ~(cs && ( bus.we) && (state == IDLE || state == DAT1)) ),

   .clk( clk ),
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

assign bus.rty = 1'b0;
assign bus.err = 1'b0;
assign bus.ack = bus.we?(state == DAT1 && !za_waitrequest):(state == DAT2 && za_valid);

//Latch Lower Half_Word
always_ff@(negedge clk)
begin
   if( state == DAT1 && za_valid )
      bus.dat_s2m[15:0] = za_data;
   else
      bus.dat_s2m[15:0] = bus.dat_s2m[15:0];
end
assign bus.dat_s2m[31:16] = za_data;

always_ff@(posedge clk)
begin
   case(state)
      IDLE:
         state = (!za_waitrequest && bus.cyc && bus.stb)?DAT1:IDLE;
      DAT1:
      begin
         if( za_valid )
            state = DAT2;
         else if( bus.we && !za_waitrequest )
            state = IDLE;
         else
            state = DAT1;
      end
      DAT2:
         state = (za_valid)?IDLE:DAT2;
      default:
         state = IDLE;
   endcase
end

endmodule

