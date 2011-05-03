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
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            		:| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Fan				:| 07/06/30  :| Initial Revision
//   V1.1 :| Thomas Suckow			:| 11/03/02  :| Timing Fix & Generalized
// --------------------------------------------------------------------
module lcd_timing_generator (
						iCLK, 				// LCD display clock
						iRST_n, 			// systen reset
						//LCD SIDE
						oHD,				// LCD Horizontal sync 
						oVD,				// LCD Vertical sync 	
						oDEN,				// LCD Data Enable
						oXCoord,            // X Coordinate 
						oYCoord,             // Y Coordinate
                  xdisplay_area, //Is X coord valid?
                  ydisplay_area  //Is Y coord valid?
						);
//============================================================================
// PARAMETER declarations
//============================================================================
parameter H_LINE = 1056;
parameter V_LINE = 525;
parameter Hsync_Back_Porch = 216;
parameter Hsync_Front_Porch = 40;
parameter Vertical_Back_Porch = 35;
parameter Vertical_Front_Porch = 10;

//===========================================================================
// PORT declarations
//===========================================================================
input			iCLK;   
input			iRST_n;
output			oHD;
output			oVD;
output			oDEN;
output [9:0]    oXCoord;
output [8:0]    oYCoord;
output xdisplay_area;
output ydisplay_area;

//=============================================================================
// REG/WIRE declarations
//=============================================================================
reg		[10:0]  x_cnt;  
reg		[9:0]	y_cnt;
reg				oHD;
reg		        oVD;
reg				oDEN;

reg				mhd;
reg				mvd;
reg				mden;

wire			display_area;

//=============================================================================
// Structural coding
//=============================================================================

					
// This signal indicate if we are within the lcd display area
assign xdisplay_area =
   (
      (x_cnt>(Hsync_Back_Porch-1+1)) && //>215
      (x_cnt<(H_LINE-Hsync_Front_Porch)) //< 1016
   );
assign ydisplay_area =
   (
      (y_cnt>(Vertical_Back_Porch-1))&&
      (y_cnt<(V_LINE - Vertical_Front_Porch))
   );
assign display_area = xdisplay_area && ydisplay_area;

//Convert to screen coordinates
assign oXCoord = xdisplay_area?(x_cnt-Hsync_Back_Porch+1):10'd0;
assign oYCoord = ydisplay_area?(y_cnt-Vertical_Back_Porch):9'd0;

///////////////////////// x  y counter  and lcd hd generator //////////////////
//X Pixel Count & Horizontal Sync
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
		begin
			x_cnt <= 11'd0;	
			mhd  <= 1'd0;  	
		end	
		else if (x_cnt == (H_LINE-1))
		begin
			x_cnt <= 11'd0;
			mhd  <= 1'd0;
		end	   
		else
		begin
			x_cnt <= x_cnt + 11'd1;
			mhd  <= 1'd1;
		end	
	end

//Y Pixel Count
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			y_cnt <= 10'd0;
		else if (x_cnt == (H_LINE-1))
		begin
			if (y_cnt == (V_LINE-1))
				y_cnt <= 10'd0;
			else
				y_cnt <= y_cnt + 10'd1;	
		end
	end

//Vertical Sync
always@(posedge iCLK  or negedge iRST_n)
	begin
		if (!iRST_n)
			mvd  <= 1'b1;
		else if (y_cnt == 10'd0)
			mvd  <= 1'b0;
		else
			mvd  <= 1'b1;
	end	

//Data Enable
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				oDEN <= 1'd0;
			end
		else
			begin
				oDEN <= display_area;
			end		
	end

//Sync signals
always@(*)
	begin
		oHD	<= mhd;
		oVD	<= mvd;
	end

endmodule
