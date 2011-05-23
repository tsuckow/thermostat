
//
// Thermostat Top Level
//
// Author: Thomas Suckow
//

module SeniorProject
(
input          clock_board,
input  [2:0]   buttons,
input  [1:0]   GPIO0_CLKIN,
output [1:0]   GPIO0_CLKOUT,
inout  [31:0]  GPIO0_DATA,
output [1:0] sdr_ba,
output[12:0] sdr_addr,
output       sdr_ras_n,
output       sdr_cas_n,
output       sdr_we_n,
output       sdr_cke,
output       sdr_cs_n,
output [1:0] sdr_dqm,
inout [15:0] sdr_data,
output       sdr_clk,
spi.master   spi_out,
output [9:0] led_out,
cfi.master   flash_out,
IntellitecSignal.slave intellitec,
spi.master   a2d_out,
output [1:0] debug
);

//
// Clock Divider
//

GLOBAL inputclk (.in(clock_board), .out(clock_50mhz));

wire clock_50mhz, clock_30khz, clock_33khz, clock_25mhz, clock_20khz, clock_over;
logic lcd_clk;
logic lock;
ClockDiv divider
(
   .inclk0(clock_50mhz),
   .c0    (clock_25mhz),
   .c1    (clock_30khz),
   .c2    (clock_20khz)
);

pll2 master_divider
(
   .inclk0(clock_50mhz),
   .c0    (clock_33khz)
);

PLLFAST clkmult
(
   .inclk0(clock_50mhz),
   .c0    (clock_over),
   .c1    (lcd_clk),
   .locked(lock)
);

wire clock_slow;
oitClockDivider #(30_000, 0.5) slow ( clock_30khz, clock_slow );

cfi cfi_proc();
cfi cfi_prog();
logic cfi_request;

cfi_arbitrator cfi_arb
(
   .request(cfi_request),
   .out(flash_out),
   .normal(cfi_proc),
   .requester(cfi_prog)
);

//
//Flash programmer
//
FlashLoader loader(
   .pfl_flash_access_granted(1'b1),
   .pfl_nreset(1'b1),
   .flash_addr(cfi_prog.addr),
   .flash_data(cfi_prog.dq),
   .flash_nce(cfi_prog.ce_n),
   .flash_noe(cfi_prog.oe_n),
   .flash_nwe(cfi_prog.we_n),
   .pfl_flash_access_request(cfi_request)
);
assign cfi_prog.byte_n = 1'b1;
assign cfi_prog.wp_n   = 1'b1;
assign cfi_prog.reset_n= 1'b1;

//
// Power On Reset
//

logic reset;
POR #( .delay( 2 ) ) poweron ( .clk( clock_slow ), .en(lock && !cfi_request), .rst( reset ) );

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


assign adc_ltm_sclk = ( adc_dclk & ltm_3wirebusy_n )  |  ( ~ltm_3wirebusy_n & ltm_sclk );

lcd_spi_cotroller	u1	(	
					// Host Side
					.iCLK(clock_50mhz),
					.spiCLK(clock_20khz),
					.iRST_n(~reset),
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
					.iCLK(clock_50mhz),
					.iRST_n(~reset),
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
always@(posedge clock_50mhz)
begin
	if( touching & ~touching2 )
		count = count + 10'd1;
	
	touching2 = touching;
end

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
wire ltm_yvalid;


lcd_timing_generator ltg
	(
		.iCLK(lcd_clk),//25mhz),
		.iRST_n( ~reset ),

		.oHD(ltm_hd),
		.oVD(ltm_vd),
		.oDEN(ltm_den),
		.oXCoord(xCoord),
		.oYCoord(yCoord),
      .ydisplay_area(ltm_yvalid)
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
assign	GPIO_0[9]	=lcd_clk;//clock_25mhz;
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

//
// Intellitec
//

wire sync12;

wire ac1;
wire ac2;
wire f1O;
wire f1H;
wire f2O;
wire f2H;
wire ht1;
wire ht2;

wishbone_b3 thermostat_bus ();

wb_reg thermostatreg
(
   .clk( proc_clk ),
   .reset( reset ),
   .bus( thermostat_bus ),
   .out( {ac1,ac2,f1O,f1H,f2O,f2H,ht1,ht2} )
);

//assign ac1 = 1'b1;
//assign ac2 = 1'b1;
//assign f1O = 1'b1;
//assign f1H = 1'b0;
//assign f2O = 1'b1;
//assign f2H = 1'b0;
//assign ht1 = 1'b0;
//assign ht2 = 1'b0;

wire [1:0] shed;
IntellitecThermostatControl tc (clock_30khz, ac1, ac2, f1O, f1H, f2O, f2H, ht1, ht2, intellitec, sync12, shed);
assign led_out = {shed,count[7:0]};
assign debug={clock_50mhz,clock_30khz};

//
// Processor
//
wishbone_b3 sdr_bus ();
wishbone_b3 lcd_bus ();
wishbone_b3 sdr_bus_fast ();

logic proc_clk;
assign proc_clk = clock_50mhz;

lcd::color bufcolor;
ThermoProcessor proc
(
   .clock(proc_clk),
   .rst( reset),
   .lcd_bus( lcd_bus ),
   .sdr_bus( sdr_bus ),
   .spi_out,
   .vsync( ltm_vd ),
   .flash_out( cfi_proc ),
   .thermostat( thermostat_bus ),
   .spi2_out( a2d_out )
);

assign ltm_r = bufcolor.r;
assign ltm_g = bufcolor.g;
assign ltm_b = bufcolor.b;

screen_dma myLCDDMA
(
   .clk(proc_clk),
   .rst(reset),
   .buffer_addr(xCoord),
   .buffer_out(bufcolor),
   .buffer_clk(~lcd_clk),
   .row(yCoord),
   .hsync( ~ltm_hd && ltm_yvalid ),
   .bus( lcd_bus )
);

wb_bridge_fastmasterout
sdbridge
(
   .clk_slave(proc_clk),
   .clk_master(clock_over),
   .rst(reset),
   .slave( sdr_bus ),
   .master( sdr_bus_fast )
);

wb_sdram16 sdr
(
   .clk(clock_over),
   .rst(reset),
   .bus(sdr_bus_fast),
   .ba(sdr_ba),
   .addr(sdr_addr),
   .ras_n(sdr_ras_n),
   .cas_n(sdr_cas_n),
   .we_n(sdr_we_n),
   .cke(sdr_cke),
   .cs_n(sdr_cs_n),
   .dqm(sdr_dqm),
   .data(sdr_data),
   .clk_out( sdr_clk )
);

endmodule
