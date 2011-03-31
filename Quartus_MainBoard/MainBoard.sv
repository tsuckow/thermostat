
module SeniorProject
(
clk_in,
buttons,
led_out,
debug,
GPIO0_CLKIN,   // GPIO Connection 0 Clock In Bus
GPIO0_CLKOUT,  // GPIO Connection 0 Clock Out Bus
GPIO0_DATA     // GPIO Connection 0 Data Bus
);

input          clk_in          /* synthesis altera_chip_pin_lc="@G21" */;
input  [2:0]   buttons         /* synthesis altera_chip_pin_lc="@F1, @G3, @H2" */;
input  [1:0]   GPIO0_CLKIN     /* synthesis altera_chip_pin_lc="@AA12, @AB12" */;	//	GPIO Connection 0 Clock In Bus
output [1:0]   GPIO0_CLKOUT    /* synthesis altera_chip_pin_lc="@AA3, @AB3" */;		//	GPIO Connection 0 Clock Out Buss
inout  [31:0]  GPIO0_DATA      /* synthesis altera_chip_pin_lc="@U7, @V5, @W6, @W7, @V8, @T8, @W10, @Y10, @V11, @R10, @V12, @U13, @W13, @Y13, @U14, @V14, @AA4, @AB4, @AA5, @AB5, @AA8, @AB8, @AA10, @AB10, @AA13, @AB13, @AB14, @AA14, @AB15, @AA15, @AA16, @AB16" */;	//	GPIO Connection 0 Data Bus

//
// Clock Divider
// 

wire clock_30khz, clock_33khz, clock_25mhz, clock_20khz;
ClockDiv divider
(
	.inclk0(clk_in),
	.c0    (clock_25mhz),
	.c1    (clock_30khz),
	.c2    (clock_20khz)
);

pll2 master_divider
(
	.inclk0(clk_in),
	.c0    (clock_33khz)
);

//
// Touch Screen
//

wire			ltm_sclk;		
wire			ltm_sda;		
wire			ltm_scen;
wire        ltm_3wirebusy_n;

wire 			adc_dclk;
wire 			adc_penirq_n;
wire 			adc_busy;
wire 			adc_din;
wire 			adc_dout;
wire 			adc_ltm_sclk;


assign adc_ltm_sclk	= ( adc_dclk & ltm_3wirebusy_n )  |  ( ~ltm_3wirebusy_n & ltm_sclk );

lcd_spi_cotroller	u1	(	
					// Host Side
					.iCLK(clk_in),
					.spiCLK(clock_20khz),
					.iRST_n(1'b1),
					// 3wire Side
					.o3WIRE_SCLK(ltm_sclk),
					.io3WIRE_SDAT(ltm_sda),
					.o3WIRE_SCEN(ltm_scen),
					.o3WIRE_BUSY_n(ltm_3wirebusy_n)
					);

wire touch_irq;
wire [11:0] x_coord;
wire [11:0] y_coord;
wire [1:0] touchdiag;
wire touching;
// Touch Screen Digitizer ADC configuration //
touch_controller touchc(
					.iCLK(clk_in),
					.iRST_n(1'b1),
					.oADC_DIN(adc_din),
					.oADC_DCLK(adc_dclk),
					.iADC_DOUT(adc_dout),
					.iADC_BUSY(adc_busy),
					.iADC_PENIRQ_n(adc_penirq_n),
					.oTOUCH_IRQ(touch_irq),
					.oX_COORD(x_coord),
					.oY_COORD(y_coord),
					.oTouch(touching)
					);

reg [9:0] count;
reg touching2;
always@(posedge clk_in)
begin
	if( touching & ~touching2 )
		count = count + 10'd1;
	
	touching2 = touching;
end

	//assign debug = {clock_25mhz, ltm_hd, ltm_vd, ltm_den};//{touchdiag ,ltm_scen,adc_din, adc_dclk, adc_dout, adc_busy, adc_penirq_n};
	
wire			ltm_hd;		
wire			ltm_vd;		
wire			ltm_den;
wire            ltm_grst;
assign          ltm_grst = 1'b1;

wire [9:0]      xCoord;
wire [8:0]      yCoord;

wire	[7:0]	ltm_r;		//	LTM Red Data 8 Bits
wire	[7:0]	ltm_g;		//	LTM Green Data 8 Bits
wire	[7:0]	ltm_b;		//	LTM Blue Data 8 Bits

wire [7:0] val;
assign val = (yCoord == 0 | xCoord == 0 | yCoord == 479 | xCoord == 799)?8'hFF:yCoord[8:1];//'h01;
assign ltm_r = (((4096-y_coord)*480/4096) == yCoord | ((4096-x_coord)*800/4096) == xCoord)?8'hFF:(touching?8'h00:val);
assign ltm_g = touching?8'h00:val;
assign ltm_b = touching?8'h60:val;
		
lcd_timing_generator ltg
	(
		.iCLK(clock_25mhz),
		.iRST_n( 1'b1 ),

		.oHD(ltm_hd),
		.oVD(ltm_vd),	
		.oDEN(ltm_den),
		.oXCoord(xCoord),
		.oYCoord(yCoord)
	);
	
	

	
	
	
wire [35:0] GPIO_0;

assign	adc_penirq_n  =GPIO_0[0];
assign	adc_dout    =GPIO_0[1];
assign	adc_busy    =GPIO_0[2];
assign	GPIO_0[3]	=adc_din;
assign	GPIO_0[4]	=adc_ltm_sclk;
assign	GPIO_0[5]	=ltm_b[3];
assign	GPIO_0[6]	=ltm_b[2];
assign	GPIO_0[7]	=ltm_b[1];
assign	GPIO_0[8]	=ltm_b[0];
assign	GPIO_0[9]	=clock_25mhz;
assign	GPIO_0[10]	=ltm_den;
assign	GPIO_0[11]	=ltm_hd;
assign	GPIO_0[12]	=ltm_vd;
assign	GPIO_0[13]	=ltm_b[4];
assign	GPIO_0[14]	=ltm_b[5];
assign	GPIO_0[15]	=ltm_b[6];
assign	GPIO_0[16]	=ltm_b[7];
assign	GPIO_0[17]	=ltm_g[0];
assign	GPIO_0[18]	=ltm_g[1];
assign	GPIO_0[19]	=ltm_g[2];
assign	GPIO_0[20]	=ltm_g[3];
assign	GPIO_0[21]	=ltm_g[4];
assign	GPIO_0[22]	=ltm_g[5];
assign	GPIO_0[23]	=ltm_g[6];
assign	GPIO_0[24]	=ltm_g[7];
assign	GPIO_0[25]	=ltm_r[0];
assign	GPIO_0[26]	=ltm_r[1];
assign	GPIO_0[27]	=ltm_r[2];
assign	GPIO_0[28]	=ltm_r[3];
assign	GPIO_0[29]	=ltm_r[4];
assign	GPIO_0[30]	=ltm_r[5];
assign	GPIO_0[31]	=ltm_r[6];
assign	GPIO_0[32]	=ltm_r[7];
assign	GPIO_0[33]	=ltm_grst;
assign	GPIO_0[34]	=ltm_scen;
assign	GPIO_0[35]	=ltm_sda;
	
assign	GPIO_0[0] = GPIO0_CLKIN[0];
assign	GPIO_0[1] = GPIO0_DATA[0];
assign	GPIO_0[2] = GPIO0_CLKIN[1];
assign	GPIO0_DATA[1] = GPIO_0[3];
assign	GPIO0_DATA[13:2] = GPIO_0[15:4];
assign	GPIO0_DATA[31:15] = GPIO_0[35:19];
assign	GPIO0_DATA[14] = GPIO_0[17];
assign	GPIO0_CLKOUT = {GPIO_0[18],GPIO_0[16]};
					
output [7:0] debug /* synthesis altera_chip_pin_lc="@T10, @T9, @U8, @V7, @U10, @U9, @Y7, @V6" */;
assign debug = 8'd0;

IntellitecSignal signal();



wire clock_slow;
oitClockDivider #(30_000, 0.5) slow ( clock_30khz, clock_slow );

wire sync12;
IntellitecMasterControl mc (clock_33khz,{1'b1,clock_slow}, signal);//(clock_33khz, signal.Master);

wire ac1;
wire ac2;
wire f1O;
wire f1H;
wire f2O;
wire f2H;
wire ht1;
wire ht2;

assign ac1 = 1'b1;
assign ac2 = 1'b1;
assign f1O = 1'b1;
assign f1H = 1'b0;
assign f2O = 1'b1;
assign f2H = 1'b0;
assign ht1 = 1'b0;
assign ht2 = 1'b0;

wire [3:0] item;
wire [1:0] shed;
IntellitecThermostatControl tc (clock_30khz, ac1, ac2, f1O, f1H, f2O, f2H, ht1, ht2, signal, sync12, shed, item);

output [9:0] led_out /* synthesis altera_chip_pin_lc="@B1, @B2, @C2, @C1, @E1, @F2, @H1, @J3, @J2, @J1" */;
//assign led_out = {signal.mt12, signal.mt2, signal.tm4, signal.tm2, 4'd0,clock_30khz, clock_33khz};
//assign led_out = y_coord;
wire sig_tick;
assign led_out = {sig_tick, count[8:0]};
//assign debug = {item/*sync12, 3'd0*/, signal.mt12, signal.mt2, signal.tm4, signal.tm2};

logic reset;
POR #( .delay( 4 ) ) poweron ( .clk( clock_slow ), .rst( reset ) );

//
// Processor
//

ThermoProcessor proc (clock_20khz, reset, sig_tick); //~buttons[0]

endmodule
