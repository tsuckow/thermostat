module POR
#(
   parameter delay = 4
)
(
   input  bit   clk,
   input  bit   en,
   output logic rst
);

`include "oitConstant.sv"

localparam width = oitBits(delay);
logic [width-1:0] count;
logic notdone;
oitBinCounter #( .COUNT( delay ) ) cnt ( .clock( clk ), .reset( 1'b0 ), .enable( notdone && en ), .out( count ) );
assign notdone = count != (delay - 1);

always_ff@(posedge clk)
   rst = notdone;

endmodule

