module wb_ram
#(
   parameter addr_width = 8
)
(
   input clk,
   input rst,
   wishbone_b3.slave bus
);

logic [31:0] data_tmp;

assign data_tmp[31:24] = bus.sel[3]?bus.dat_m2s[31:24]:bus.dat_s2m[31:24];
assign data_tmp[23:16] = bus.sel[2]?bus.dat_m2s[23:16]:bus.dat_s2m[23:16];
assign data_tmp[15:8]  = bus.sel[1]?bus.dat_m2s[15:8] :bus.dat_s2m[15:8];
assign data_tmp[7:0]   = bus.sel[0]?bus.dat_m2s[7:0]  :bus.dat_s2m[7:0];

InferableRAM
#(
   .data_width (32),
   .addr_width (addr_width-2)
)
myRAM
(
   .dat_in  (data_tmp),
   .dat_out (bus.dat_s2m),
   .addr_a  (bus.adr[addr_width-1:2]),
   .we      (bus.we & bus.ack),
   .clk     (~clk)
);

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

