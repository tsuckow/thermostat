//****************************************************************************
//	WishboneIOSlaves.sv
//	Wishbone slave modules for simple I/O.
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//		This file contains wishbone bus slaves for basic I/O.
//			wb_reg - A register that partially decodes 
//					address to allow simple assignment or 
//					setting/clearing/inverting bits.
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//
//  Modified By:
//		Thomas Suckow
//****************************************************************************

//****************************************************************************
//	wb_reg
//	A wishbone bus slave with a register for holding output data.
//
//	Description:
//		This module contains a register for holding output data.  It 
//		acts as a wishbone slave and will partially decode it's 
//		address to allow multiple actions.  The mode is the bits of 
//		address just above those needed to address the data granules 
//		(for example just above the 2 bits needed to address a byte 
//		in a 32 bit word).
//			mode=0:	Just overwrite the contents of the register
//				with the input.
//			mode=1:	Use input as a mask to set bits of the
//				register.
//			mode=2:	Use input as a mask to clear bits of the
//				register.
//			mode=3:	Use input as a mask to invert bits of the
//				register.
//
//		When reset is asserted and a write is attempted the bus 
//		error line will be asserted.
//	
//	Inputs:
//		reset:	An asynchronus active high reset.  Loads RESET_PAT
//			into the register.
//
//	Outputs:
//		out:	Then current contents of the register.
//
//	Interfaces:
//		bus:	A wishbone bus slave interface.
//
//****************************************************************************
module wb_reg
#(
	parameter	DATA_WIDTH =	32,
	parameter	SELECT_WIDTH =	4,
	parameter	RESET_PAT =	0,
	parameter	TGD =		2'h0
)
(
	input   logic               clk,
	input	logic				reset,
	wishbone_b3.slave			bus,
	output	logic	[DATA_WIDTH-1:0]	out
);
`include "oitConstant.sv"
	localparam	DATA_GRANULARITY = DATA_WIDTH/SELECT_WIDTH;
	localparam	SELECT_BITS	= oitBits(SELECT_WIDTH);
	
	logic	error;//Indicates a bus error state
	logic	active;//Indicates we are performing a write or read action.

	//The value of the register.
	logic	[DATA_WIDTH-1:0]	value;
	//The next value to load.
	logic	[DATA_WIDTH-1:0]	nextValue;

	assign error = bus.we & reset;
	assign active = bus.cyc & bus.stb;
	assign bus.ack = active & (~error);
	assign bus.rty = 1'b0;
	assign bus.err = active & error;
	
generate
	genvar i;
	for (i=0; i<SELECT_WIDTH; i=i+1) begin :generateNextValue
		logic	[DATA_GRANULARITY-1:0]	incoming;
		logic	[DATA_GRANULARITY-1:0]	last;
		logic	[DATA_GRANULARITY-1:0]	next;
		assign incoming = bus.dat_m2s[(i+1)*DATA_GRANULARITY-1:i*DATA_GRANULARITY];
		assign last = value[(i+1)*DATA_GRANULARITY-1:i*DATA_GRANULARITY];
		
		always_comb begin
			if (active & bus.we & bus.sel[i]) begin//Make this enable to ff
				case(bus.adr[SELECT_BITS+1:SELECT_BITS])
					2'h0:next = incoming;
					2'h1:next = last | incoming;
					2'h2:next = last & ~incoming;
					2'h3:next = last ^ incoming;
				endcase
			end else begin
				next = last;
			end
		end
		assign nextValue[(i+1)*DATA_GRANULARITY-1:i*DATA_GRANULARITY] = next;
	end
endgenerate
	
	always @(negedge clk or posedge reset) begin
		if (reset) begin
			value = RESET_PAT;
		end else begin
			value = nextValue;
		end
	end
	assign bus.dat_s2m = value;
	assign out = value;
endmodule
