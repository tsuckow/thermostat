module InferableROM
#(
	parameter data_width = 8,
	parameter addr_width = 8
)
(
   input [(addr_width-1):0] addr_a,
   input clk, 
   output reg [(data_width-1):0] q_a
);
   reg [data_width-1:0] rom[0:2**addr_width-1];
   
   initial //Init ROM from file
   begin
      $readmemh("../../Firmware_BootRom/boot.dat", rom); // It would be great if this could be a parameter
   end
   
   always @ (posedge clk)
   begin
      q_a <= rom[addr_a];
   end
   
endmodule
