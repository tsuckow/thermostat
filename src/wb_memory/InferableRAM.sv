module InferableRAM
#(
   parameter data_width = 8,
   parameter addr_width = 8
)
(
   input [(addr_width-1):0] addr_a,
   input clk,
   input we,
   input  logic [(data_width-1):0] dat_in,
   output logic [(data_width-1):0] dat_out
);
   reg [data_width-1:0] rom[0:2**addr_width-1];

   always @ (posedge clk)
   begin
      dat_out <= rom[addr_a];
      if(we)
         rom[addr_a] = dat_in;
   end

endmodule
