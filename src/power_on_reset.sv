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
logic done;
oitBinCounter #( .COUNT( delay ) ) cnt ( .clock( clk ), .reset( 1'b0 ), .enable( done ), .out( count ) );
assign done = count != (delay - 1);

always_ff@(posedge clk)
   rst = done;

endmodule

