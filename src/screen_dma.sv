module screen_dma
(
input              clk,
input              rst,
input  [11:2]      buffer_addr,
output lcd::color  buffer_out,
input              buffer_clk,
input  [8:0]       row,
input              hsync,
wishbone_b3.master bus
);

localparam base_addr = 'h01000000;

typedef enum logic [0:0] { IDLE, RUNNING } State;
State state;

logic [9:0] counter;
logic inc;
assign inc = bus.ack;

always_ff@(posedge clk or posedge rst)
begin
   if( rst )
   begin
      state = IDLE;
      counter = 0;
   end
   else
   begin
      case(state)
         IDLE:
            begin
               state = hsync?RUNNING:IDLE;
               counter = 0;
            end
         RUNNING:
            begin
               state = (bus.err || bus.rty || (counter==799 && inc))?IDLE:RUNNING;
               counter = inc?counter+1:counter;
            end
      endcase
   end
end

always_comb
begin
   case(state)
      IDLE:
         begin
            bus.cyc = 0;
            bus.stb = 0;
            bus.adr = 0;
         end
      RUNNING:
         begin
            bus.adr = base_addr + (counter<<2) + (row*800*4);
            bus.cyc = 1;
            bus.stb = 1;
         end
   endcase
end

logic [23:0] readbuffer;
always_ff@(posedge clk)
begin
   readbuffer = bus.dat_s2m[23:0];
end

assign bus.dat_m2s = 0;
assign bus.we      = 0;
assign bus.cti     = 3'b111;
assign bus.bte     = 1;
assign bus.sel     = 4'b1111;

//
// RAM MODULE
//

logic [23:0] buffer_out_tmp;

InferableDualPortRAM
#(
   .data_width (24),
   .addr_width (10)
)
myRAM
(
   .dat_in  (readbuffer),
   .dat_ro  (buffer_out_tmp),
   .addr    (counter),
   .addr_ro (buffer_addr),
   .we      (bus.ack),
   .clk     (~clk),
   .clk2    (buffer_clk)
);

assign buffer_out.r = buffer_out_tmp[23:16];
assign buffer_out.g = buffer_out_tmp[15:8];
assign buffer_out.b = buffer_out_tmp[7:0];

endmodule

