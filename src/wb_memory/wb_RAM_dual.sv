module wb_color_ram
#(
   parameter addr_width = 8
)
(
   input clk,
   input clk2,
   input rst,
   wishbone_b3.slave bus,
   input [addr_width-1:2] addr,
   output [7:0] r,
   output [7:0] g,
   output [7:0] b
);

logic [23:0] data;
logic [23:0] data_tmp;

assign data_tmp[23:16] = bus.sel[3]?bus.dat_m2s[23:16]:bus.dat_s2m[23:16];
assign data_tmp[15:8]  = bus.sel[2]?bus.dat_m2s[15:8] :bus.dat_s2m[15:8];
assign data_tmp[7:0]   = bus.sel[1]?bus.dat_m2s[7:0]  :bus.dat_s2m[7:0];

InferableDualPortRAM
#(
   .data_width (24),
   .addr_width (addr_width-2)
)
myRAM
(
   .dat_in  (data_tmp),
   .dat_out (bus.dat_s2m[23:0]),
   .dat_ro  (data),
   .addr    (bus.adr[addr_width-1:2]),
   .addr_ro (addr),
   .we      (bus.we & bus.ack),
   .clk     (~clk),
   .clk2(clk2)
);

//Last byte is not used
assign bus.dat_s2m[31:24] = 'd0;
assign r = data[23:16];
assign g = data[15:8];
assign b = data[7:0];

always @ (posedge clk or posedge rst)
begin
   if (rst)
      bus.ack <= 1'b0;
   else
      if (!bus.ack)
      begin
         if (bus.cyc & bus.stb)
            bus.ack <= 1'b1;
      end
      else if ((bus.sel != 4'b1111) | (bus.cti == 3'b000) | (bus.cti == 3'b111))
         bus.ack <= 1'b0;
end

assign bus.rty = 1'b0;
assign bus.err = 1'b0;

endmodule

