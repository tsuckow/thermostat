// ============================================================================
// Generates a multiplexer.
// COUNT:  The number of input vectors
// WIDTH:  The number of bits in each input vector
//
// select: A vector which selects between the given inputs
// in:     A vector containing each input
// out:    The multiplexed output
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
module oitMux #( parameter COUNT = 2, parameter WIDTH = 1 )
(
input      [oitBits( COUNT ) - 1:0] select,
input      [COUNT * WIDTH  - 1:0] in,
output reg [        WIDTH  - 1:0] out
);

`include "oitConstant.sv"

generate
	always @ ( select or in )
	for ( int i = 0; i < WIDTH; i += 1 )
	begin
		reg [COUNT - 1:0] tmp;
		for ( int s = 0; s < COUNT; s += 1 )
			tmp[s] = &
			{   in[i + s * WIDTH]
			,   select ^ ~s[oitBits( COUNT ) - 1:0]
			};

		out[i] = |tmp;
	end
endgenerate

endmodule

// ============================================================================
// Generates a decoder.
// COUNT:  The number of states to decode
// ACTIVE: Determines the active state
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
module oitDecoder #( parameter COUNT = 0, parameter ACTIVE = 1 )
(
input      [oitBits( COUNT ) - 1:0] in,
output reg [COUNT          - 1:0]   out
);

`include "oitConstant.sv"

generate
	always @ ( in )
	for ( int i = 0; i < COUNT; i += 1 )
		out[i] = ACTIVE
			?  &{ in ^ ~i[oitBits( COUNT ) - 1:0] }  // Active High
			: ~&{ in ^ ~i[oitBits( COUNT ) - 1:0] }; // Active Low
endgenerate

endmodule

// ============================================================================
// A Half Adder, calculates the sum of two bits.
// in:  A vector containing each of the input values
// out: A vector containing the sum and carry out bits
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
module oitHalfAdder
(
input  [1:0] in,
output [1:0] out
);
	assign out[0] = in[1] ^ in[0];
	assign out[1] = in[1] & in[0];
endmodule

// ============================================================================
// A Full Adder, calculates the sum of three bits.
// in:  A vector containing each of the input values
// out: A vector containing the sum and carry out bits
// Author: Keith Majhor
// Updated: Thomas Suckow
// ============================================================================
module oitFullAdder
(
input  [2:0] in,
output [1:0] out
);
	assign out[0] = in[2] ^ in[1] ^ in[0];
	assign out[1] = ( in[2] & in[1] )
	              | ( in[2] & in[0] )
	              | ( in[1] & in[0] );
endmodule

module debug #(parameter a=0,parameter b=0) (output x);

assign x = b;

endmodule

// ============================================================================
// Generates an adder.
// WIDTH_a: The width of the first input vector
// WIDTH_b: The width of the second input vector
//
// a:       A vector containing the two input vectors
// b:       A vector containing the two input vectors
// out:     A vector containing the sum of each input
//
// Author: Thomas Suckow
// ============================================================================
module oitAdder #( parameter WIDTH_a = 0, parameter WIDTH_b = 0 )
(
input  [WIDTH_a - 1:0]                a,
input  [WIDTH_b - 1:0]                b,
output [oitMax( WIDTH_a, WIDTH_b ):0] out
);

`include "oitConstant.sv"

localparam WIDTH_OUT = oitMax( WIDTH_a, WIDTH_b ) + 1;

wire [WIDTH_OUT - 2:0] carry;
genvar i;

generate

for (i=1; i < WIDTH_OUT - 1; i=i+1)
begin : oitAdderSubAdders
  wire first, second;
  assign first  = (i<WIDTH_a)?a[i]:1'b0;
  assign second = (i<WIDTH_b)?b[i]:1'b0;
	oitFullAdder fa( { carry[i-1], first, second }, { carry[i], out[i] } );
end

endgenerate

oitHalfAdder fa0( { a[0], b[0] }, { carry[0], out[0] } );

assign out[ WIDTH_OUT - 1 ] = carry[ WIDTH_OUT - 2 ];

endmodule

// ============================================================================
// Generates a clock divider.
// INPUT: The input frequency.
// OUTPUT: The desired output frequency
// 
// Important note: this totally isn't going to guarantee any phase offset 
// between its input and output.  It could be anywhere.
// 
// in: Input clock.
// out: Output clock.
// Author: Noah Bacon
// ============================================================================
module oitClockDivider #( parameter INPUT = 1, parameter OUTPUT = 1 )
(
	input wire		in,
	output reg		out
);

`include "oitConstant.sv"

generate
	parameter COUNT = INPUT/OUTPUT/2 -1;
	if (COUNT>0)  begin
		wire [oitBits(COUNT) - 1 :0]count;
		oitBinCounter #(.COUNT(COUNT)) 
			counter (.clock(in),.reset(1'b0),.enable(1'b1),.out(count));
		always @ (posedge count[oitBits(COUNT)-1])
			out=~out;
	end else begin
		assign out=in;
	end
endgenerate

endmodule

// ============================================================================
// Generates a dynamic clock divider.
// WIDTH: Determines the width of the internal counter
// ASYNC: Determines whether the reset is synchronous or asynchronous
// 
// This clock divider works off of a count provided at run time.
// Important note: this totally isn't going to guarantee any phase offset 
// between its input and output.  It could be anywhere.  When the clock 
// period is odd then the output will be low for the odd clock cycle, it will 
// be in the middle.
// 
// in: Input clock.
// out: Output clock.
// count: Clock will have a period of count+1 clocks.
// Author: Noah Bacon
// ============================================================================
module oitDynamicClockDivider #( parameter WIDTH = 0, parameter ASYNC = 1 )
(
	input wire		reset,
	input wire		in,
	input wire [WIDTH - 1:0] count,
	output reg		out
);

`include "oitConstant.sv"

generate
	wire [WIDTH - 1 :0]temp;
	oitDynamicBinCounter #(.WIDTH(WIDTH),.ASYNC(ASYNC)) 
		counter (
			.clock(in),
			.reset(reset),
			.enable(1'b1),
			.count(count),
			.out(temp)
	);
	assign out=(|count)?(temp>{1'b0,count[WIDTH-1:1]}):(in);
endgenerate

endmodule

// ============================================================================
// Generates a binary counter.
// COUNT: The number of counts
// ASYNC: Determines whether the reset is synchronous or asynchronous
//
// clock: A clock
// reset: Sets out to 0
// enable: Enables counting on clock.
// out:   The current count
// Author: Keith Majhor
// Updated: Thomas Suckow
// Updated: Noah Bacon
// ============================================================================
module oitBinCounter #( parameter COUNT = 0, parameter ASYNC = 1 )
(
input                               clock,
input                               reset,
input				    enable,
output reg [oitBits( COUNT ) - 1:0] out
);

`include "oitConstant.sv"

generate
	parameter POWER_OF_2 = ( COUNT == oitPow( 2, oitLog( 2, COUNT ) ) );
	parameter OUT_WIDTH  = oitBits( COUNT );
	parameter LAST       = COUNT - 1;

	wire [OUT_WIDTH:0] inc;
	wire [OUT_WIDTH:0] next;
	

	oitAdder #( 1, OUT_WIDTH ) a1 ( 1'b1, out, inc );

	// Determine next output value
	if ( POWER_OF_2 && ASYNC )
		assign next = inc;
	else
	begin
	  wire                   temp;
		if ( POWER_OF_2 ) assign temp = reset;
		else if ( ASYNC ) assign temp =         &( out ^ ~LAST );
		else              assign temp = reset | &( out ^ ~LAST );

		oitMux #( 2, OUT_WIDTH+1 )
		m1 (   temp
		,   { { OUT_WIDTH+1{ 1'b0 } }, inc }
		,   next
		);
	end

	// Build Flip Flops
	if ( ASYNC ) begin
		always @ ( posedge clock or posedge reset ) begin
			if (reset) begin
				out=0;
			end else begin
				out = enable ? next[OUT_WIDTH-1:0] : out;
			end
		end
	end else begin
		always @ ( posedge clock )
			if (reset | enable) begin
				out = next;
			end else begin
				out = out;
			end
	end
		
endgenerate

endmodule

// ============================================================================
// Generates a dynamic binary counter.
// WIDTH: Determines the width of the internal counter
// ASYNC: Determines whether the reset is synchronous or asynchronous
//
// This counter uses a count provided at run time. Counts from [0,count] (it 
// includes both 0 and count when it counts.
// 
// clock: A clock
// reset: Sets out to 0
// enable: Enables counting on clock.
// count: Sets the current count (interval is from 0 to count inclusive).
// out:   The current count
// Author: Noah Bacon
// ============================================================================
module oitDynamicBinCounter #( parameter WIDTH = 0, ASYNC = 1 )
(
	input  wire clock,
	input  wire reset,
	input  wire enable,
	input  wire [WIDTH - 1:0] count,
	output reg [WIDTH - 1:0] out
);

`include "oitConstant.sv"
wire [WIDTH-1:0] next;

assign next=(out<count)?(out+1):(0);

generate
	// Build Flip Flops
	if ( ASYNC )
		always @ ( posedge clock or posedge reset )
			if (reset) begin
				out=0;
			end else begin
				out = enable ? next : out;
			end
	else
		always @ ( posedge clock )
			if (reset) begin
				out=0;
			end else begin
				out = enable ? next : out;
			end
endgenerate

endmodule

// ============================================================================
// Generates a latch.
// WIDTH:  The number of bits to latch
// ASYNC:  Determines if the reset is asynchronus.
// ACTIVE: Determines if the enable is active low or active high.
// RESETPAT: The pattern of bits that the counter will be reset to.
//
// clock:  A clock
// enable: Latches the input
// in:     The input
// out:    The output
// Author: Keith Majhor
// Updated: Thomas Suckow
// Updated: Noah Bacon
// ============================================================================
module oitLatch
#(
	parameter WIDTH = 0,
	parameter ASYNC=1,
	parameter ACTIVE = 1,
	parameter RESETPAT = 0
)
(
input                    clock,
input			 reset,
input                    enable,
input      [WIDTH - 1:0] in,
output reg [WIDTH - 1:0] out
);

generate
	wire [WIDTH - 1:0] tmp;
	oitMux #( 2, WIDTH ) lmux ( enable == ACTIVE, { in, out }, tmp );

	if (ASYNC) begin
		always @ ( posedge clock or posedge reset)
			if (reset) begin
				out = RESETPAT;
			end else begin
				out = tmp;
			end
	end else begin
		always @ ( posedge clock )
			out = (reset)?(RESETPAT):(tmp);
	end
endgenerate

endmodule

// ============================================================================
// Generates a Hex to 7 segment decoder.
// ACTIVE:  Determines that the outputs are active hight or active low.
// COUNT:  The number of BCD inputs (4 bits wide each) to convert.
// CODE0:  Sets the 7 bit output for this hex input.
// CODE1:  Sets the 7 bit output for this hex input.
// CODE2:  Sets the 7 bit output for this hex input.
// CODE3:  Sets the 7 bit output for this hex input.
// CODE4:  Sets the 7 bit output for this hex input.
// CODE5:  Sets the 7 bit output for this hex input.
// CODE6:  Sets the 7 bit output for this hex input.
// CODE7:  Sets the 7 bit output for this hex input.
// CODE8:  Sets the 7 bit output for this hex input.
// CODE9:  Sets the 7 bit output for this hex input.
// CODEA:  Sets the 7 bit output for this hex input.
// CODEB:  Sets the 7 bit output for this hex input.
// CODEC:  Sets the 7 bit output for this hex input.
// CODED:  Sets the 7 bit output for this hex input.
// CODEE:  Sets the 7 bit output for this hex input.
// CODEF:  Sets the 7 bit output for this hex input.
//
// in:     The BCD input
// out:    The the 7 segment output output
// Author: Noah Bacon
// ============================================================================
module oitHexTo7Seg #(
	parameter ACTIVE = 1,
	parameter COUNT = 1,
	parameter CODE0 = 7'b1111110,
	parameter CODE1 = 7'b0000110,
	parameter CODE2 = 7'b1101101,
	parameter CODE3 = 7'b1111001,
	parameter CODE4 = 7'b0110011,
	parameter CODE5 = 7'b1011011,
	parameter CODE6 = 7'b1011111,
	parameter CODE7 = 7'b1110000,
	parameter CODE8 = 7'b1111111,
	parameter CODE9 = 7'b1111011,
	parameter CODEA = 7'b1110111,
	parameter CODEB = 7'b0011111,
	parameter CODEC = 7'b1001110,
	parameter CODED = 7'b0111101,
	parameter CODEE = 7'b1001111,
	parameter CODEF = 7'b1000111
)
(
input  wire [COUNT * 4 - 1:0] in,
output wire [COUNT * 7 - 1:0] out
);

`include "oitConstant.sv"

generate
	genvar i;
	for ( i = 0; i < COUNT; i += 1 )
	begin : oitHexTo7SegDigits
		wire [3:0] tmpIn;
		reg [6:0] tmpOut;
		assign tmpIn=in[(i+1)*4 - 1 : i*4];
		
		always @ (tmpIn)
			case (tmpIn)
				4'h0	: tmpOut = CODE0;
				4'h1	: tmpOut = CODE1;
				4'h2	: tmpOut = CODE2;
				4'h3	: tmpOut = CODE3;
				4'h4	: tmpOut = CODE4;
				4'h5	: tmpOut = CODE5;
				4'h6	: tmpOut = CODE6;
				4'h7	: tmpOut = CODE7;
				4'h8	: tmpOut = CODE8;
				4'h9	: tmpOut = CODE9;
				4'hA	: tmpOut = CODEA;
				4'hB	: tmpOut = CODEB;
				4'hC	: tmpOut = CODEC;
				4'hD	: tmpOut = CODED;
				4'hE	: tmpOut = CODEE;
				4'hF	: tmpOut = CODEF;
				default	: tmpOut = (ACTIVE)?(7'h7F):(7'h00);
			endcase
		assign out[(i+1)*7 - 1: i*7]=(ACTIVE)?(tmpOut):(~tmpOut);
	end
endgenerate

endmodule
/* Filetype tags for editors.
* vim: set filetype=verilog : 
*/
