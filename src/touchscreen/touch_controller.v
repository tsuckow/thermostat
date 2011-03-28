// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	This funtion will config and read Touch Screen Digitizer 
// 					X an Y coordinate form LTM 
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Fan        :| 06/03/23  :|      Initial Revision
// --------------------------------------------------------------------
module touch_controller	(
					iCLK,
					iRST_n,
					oADC_DIN,
					oADC_DCLK,
					iADC_DOUT,
					iADC_BUSY,
					iADC_PENIRQ_n,
					oTOUCH_IRQ,
					oX_COORD,
					oY_COORD,
					oTouch
					///////////////////
					);
					
//============================================================================
// PARAMETER declarations
//============================================================================	
parameter SYSCLK_FRQ	= 50000000;
parameter ADC_DCLK_FRQ	= 40000;
parameter ADC_DCLK_CNT	= SYSCLK_FRQ/(ADC_DCLK_FRQ*2);
					
//===========================================================================
// PORT declarations
//=========================================================================== 
input			iCLK;
input			iRST_n;
input			iADC_DOUT;
input			iADC_PENIRQ_n;
input			iADC_BUSY;
output			oADC_DIN;
output			oADC_DCLK;
output			oTOUCH_IRQ;
output	[11:0]	oX_COORD;
output	[11:0]	oY_COORD;
output          oTouch;
			
//=============================================================================
// REG/WIRE declarations
//=============================================================================
reg				d1_PENIRQ_n;
wire			touch_irq;
reg		[15:0]	dclk_cnt;
wire			dclk;
reg				transmit_en;
reg		[6:0]	spi_ctrl_cnt;
wire			oADC_CS;
reg				mdclk;
wire	[7:0]	x_config_reg;
wire	[7:0]	y_config_reg;
wire	[7:0]	ctrl_reg;
reg		[7:0]	mdata_in;
reg				y_coordinate_config;
wire			eof_transmition;	
reg		[5:0]	bit_cnt;	
reg				madc_out;	
reg		[11:0]	mx_coordinate;
reg		[11:0]	my_coordinate;	
reg		[11:0]	oX_COORD;
reg		[11:0]	oY_COORD;
wire			rd_coord_strob;
reg		[5:0]	irq_cnt;
reg		[15:0]	clk_cnt;
//=============================================================================
// Structural coding
//=============================================================================
assign	x_config_reg = 8'hd2;//8'h92;
assign	y_config_reg = 8'h92;//8'hd2;

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			madc_out <= 0;
		else
			madc_out <= iADC_DOUT;
	end		

//The ADC will sometimes strobe the irq then go into an invalid state waiting for our request.
//Remember that the irq happened till we actually handle it.
always@(negedge iADC_PENIRQ_n or posedge iADC_BUSY or negedge iRST_n)
begin
	if (!iRST_n | !iADC_PENIRQ_n)
		d1_PENIRQ_n	<= 1'b0;
	else if( iADC_BUSY )
		d1_PENIRQ_n	<= 1'b1;
end

// if iADC_PENIRQ_n form high to low , touch_irq goes high
assign		touch_irq = ~d1_PENIRQ_n;//d2_PENIRQ_n & ~d1_PENIRQ_n; 
assign		oTOUCH_IRQ = touch_irq;
// if touch_irq goes high , starting transmit procedure ,transmit_en goes high
// if end of transmition and no penirq , transmit procedure stop.

assign oTouch = transmit_en;

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			transmit_en <= 0;
		else if (eof_transmition&&iADC_PENIRQ_n) 
			transmit_en <= 0;	
		else if (touch_irq)
			transmit_en <= 1;
	end			

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			dclk_cnt <= 0;
		else if (transmit_en) 
			begin
				if (dclk_cnt == ADC_DCLK_CNT)
					dclk_cnt <= 0;
				else
					dclk_cnt <= dclk_cnt + 16'd1;		
			end
		else
			dclk_cnt <= 0;
	end			
	
assign	dclk =   (dclk_cnt == ADC_DCLK_CNT)? 1'b1 : 1'b0;		

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
		begin
			spi_ctrl_cnt <= 0;
		end
		else if (dclk)	
			begin
				if (spi_ctrl_cnt == 65)
				begin
					spi_ctrl_cnt <= 0;
				end
				else if( (spi_ctrl_cnt == 18) & ~iADC_BUSY ) //Error, try again
				begin
					spi_ctrl_cnt <= 0;
				end
				else
				begin
					spi_ctrl_cnt <= spi_ctrl_cnt + 7'd1;
				end
			end
	end				

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				mdclk	<= 0;
				mdata_in <= 0;
				y_coordinate_config <= 0;
				mx_coordinate <= 0;
				my_coordinate <= 0;
			end
		else if (transmit_en)
			begin
				if (dclk)
					begin
						if (spi_ctrl_cnt == 0)
							begin
								mdata_in <= ctrl_reg;
								mdclk	<= 0;
							end	
						else if (spi_ctrl_cnt == 49)
							begin
								mdclk	<= 0;
								y_coordinate_config <= ~y_coordinate_config;	
							end
						else if (spi_ctrl_cnt != 0)
							mdclk	<= ~mdclk;				
						if (mdclk)
							mdata_in <= {mdata_in[6:0],1'b0};
						if (!mdclk)	
							begin
								if(rd_coord_strob)
									begin
										if(y_coordinate_config)
											my_coordinate <= {my_coordinate[10:0],madc_out};
										else
											mx_coordinate <= {mx_coordinate[10:0],madc_out};	
									end
							end		
					end				
			end
	end

assign	oADC_DIN = 	mdata_in[7];
assign	oADC_DCLK = mdclk;
assign	ctrl_reg = y_coordinate_config ? y_config_reg : x_config_reg;
 
assign	eof_transmition = (y_coordinate_config & (spi_ctrl_cnt == 49) & dclk);

assign	rd_coord_strob = ((spi_ctrl_cnt>=19)&&(spi_ctrl_cnt<=41)) ? 1'b1 : 1'b0;

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				oX_COORD <= 0;	
				oY_COORD <= 0;
			end
		else if (eof_transmition&&(my_coordinate!=0))
			begin			
				oX_COORD <= mx_coordinate;	
				oY_COORD <= my_coordinate;
			end	
	end

endmodule
