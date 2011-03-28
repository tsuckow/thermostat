module rom_wb
#(
	parameter data_width = 8,
	parameter addr_width = 8
)
(
	dat_i,
	dat_o,
	adr_i,
	we_i,
	sel_i,
	cyc_i,
	stb_i,
	ack_o,
	cti_i,
	clk_i,
	rst_i
);
   
// wishbone signals
input      [data_width-1:0] dat_i;   
output     [data_width-1:0] dat_o;
input      [addr_width-1:0] adr_i;
input                       we_i;
input      [3:0]            sel_i;
input                       cyc_i;
input                       stb_i;
output reg                  ack_o;
input      [2:0]            cti_i;

input clk_i; // clock
input rst_i; // async reset

InferableROM
#(
	.data_width (data_width),
	.addr_width (addr_width-2)
)
myROM
(
	.q_a    (dat_o),
	.addr_a (adr_i[addr_width-1:2]),
	.clk    (clk_i)
);

// ack_o
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
	ack_o <= 1'b0;
else
	if (!ack_o)
	begin
		if (cyc_i & stb_i)
			ack_o <= 1'b1;
	end  
	else if ((sel_i != 4'b1111) | (cti_i == 3'b000) | (cti_i == 3'b111))
		ack_o <= 1'b0;
         
endmodule
 
	      