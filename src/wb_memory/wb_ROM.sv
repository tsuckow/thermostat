module wb_rom
#(
   parameter data_width = 8,
   parameter addr_width = 8
)
(
   input clk,
   input rst,
   wishbone_b3.slave bus
);


InferableROM
#(
   .data_width (data_width),
   .addr_width (addr_width-2)
)
myROM
(
   .q_a    (bus.dat_s2m),
   .addr_a (bus.adr[addr_width-1:2]),
   .clk    (clk)
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
assign bus.err = bus.we;

endmodule

