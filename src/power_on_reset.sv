module POR
#(
   parameter delay = 4
)
(
   input  bit   clk,
   output logic rst
);

`include "oitConstant.sv"

localparam width = oitBits(delay);
logic [width-1:0] count;
oitBinCounter #( .COUNT( delay ) ) cnt ( .clock( clk ), .reset( 1'b0 ), .enable( rst ), .out( count ) );

assign rst = count != (delay - 1);

endmodule

