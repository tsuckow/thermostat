module InferableDualPortRAM
#(
   parameter data_width = 8,
   parameter addr_width = 8
)
(
   input [(addr_width-1):0] addr,
   input [(addr_width-1):0] addr_ro,
   input clk,
   input clk2,
   input we,
   input  logic [(data_width-1):0] dat_in,
   output logic [(data_width-1):0] dat_out,
   output logic [(data_width-1):0] dat_ro
);
   reg [data_width-1:0] rom[0:2**addr_width-1];

   always @ (posedge clk)
   begin
      dat_out <= rom[addr];
      if(we)
         rom[addr] = dat_in;
   end

   always @ (posedge clk2)
   begin
      dat_ro <= rom[addr_ro];
   end

endmodule
