module ThermoProcessor
(
	clock,
	rst,
	ooo
);

input clock, rst;
output ooo;




//
//Processor
wire sig_tick;

//Wishbone Common
wire wb_clk = clock;
wire wb_rst = rst;

// Instruction master i/f wires
wire [31:0] wb_rim_adr_o;
wire        wb_rim_cyc_o;
wire [31:0] wb_rim_dat_i;
wire [31:0] wb_rim_dat_o;
wire [3:0]  wb_rim_sel_o;
wire        wb_rim_ack_i;
wire        wb_rim_err_i;
wire        wb_rim_rty_i;
wire        wb_rim_we_o;
wire        wb_rim_stb_o;
wire [2:0]  wb_rim_cti_o;
wire        wb_rim_bte_o;

// Data master i/f wires
wire [31:0] wb_rdm_adr_o;
wire        wb_rdm_cyc_o;
wire [31:0] wb_rdm_dat_i;
wire [31:0] wb_rdm_dat_o;
wire [3:0]  wb_rdm_sel_o;
wire        wb_rdm_ack_i;
wire        wb_rdm_err_i;
wire        wb_rdm_rty_i;
wire        wb_rdm_we_o;
wire        wb_rdm_stb_o;
wire [2:0]  wb_rdm_cti_o;
wire        wb_rdm_bte_o;

// Debug i/f wires
wire [3:0]  dbg_lss;
wire [1:0]  dbg_is;
wire [10:0] dbg_wp;
wire        dbg_bp;
wire [31:0] dbg_dat_dbg;
wire [31:0] dbg_dat_risc;
wire [31:0] dbg_adr;
wire        dbg_ewt;
wire        dbg_stall = 1'b0;
wire [2:0]  dbg_op;

or1200_top proc
(

	.rst_i		( wb_rst ),
	.clk_i		( wb_clk ),

	.clmode_i	( 2'b00 ), // 1 to 1 clock?

	// WISHBONE Instruction Master
	.iwb_clk_i	( wb_clk ),
	.iwb_rst_i	( wb_rst ),
	.iwb_cyc_o	( wb_rim_cyc_o ),
	.iwb_adr_o	( wb_rim_adr_o ),
	.iwb_dat_i	( wb_rim_dat_i ),
	.iwb_dat_o	( wb_rim_dat_o ),
	.iwb_sel_o	( wb_rim_sel_o ),
	.iwb_ack_i	( wb_rim_ack_i ),
	.iwb_err_i	( wb_rim_err_i ),
	.iwb_rty_i	( wb_rim_rty_i ),
	.iwb_we_o	( wb_rim_we_o  ),
	.iwb_stb_o	( wb_rim_stb_o ),
	.iwb_cti_o  ( wb_rim_cti_o ),
	.iwb_bte_o  ( wb_rim_bte_o ),

	// WISHBONE Data Master
	.dwb_clk_i	( wb_clk ),
	.dwb_rst_i	( wb_rst ),
	.dwb_cyc_o	( wb_rdm_cyc_o ),
	.dwb_adr_o	( wb_rdm_adr_o ),
	.dwb_dat_i	( wb_rdm_dat_i ),
	.dwb_dat_o	( wb_rdm_dat_o ),
	.dwb_sel_o	( wb_rdm_sel_o ),
	.dwb_ack_i	( wb_rdm_ack_i ),
	.dwb_err_i	( wb_rdm_err_i ),
	.dwb_rty_i	( wb_rdm_rty_i ),
	.dwb_we_o	( wb_rdm_we_o  ),
	.dwb_stb_o	( wb_rdm_stb_o ),
	.dwb_cti_o  ( wb_rdm_cti_o ),
	.dwb_bte_o  ( wb_rdm_bte_o ),

	// Debug
	.dbg_stall_i( dbg_stall ),
	.dbg_dat_i	( dbg_dat_dbg ),
	.dbg_adr_i	( dbg_adr ),
	.dbg_ewt_i	( 1'b0 ),
	.dbg_lss_o	( dbg_lss ),
	.dbg_is_o	( dbg_is ),
	.dbg_wp_o	( dbg_wp ),
	.dbg_bp_o	( dbg_bp ),
	.dbg_dat_o	( dbg_dat_risc ),
	
	//Not all are accounted for ?
	//dbg_stall_i, dbg_ewt_i,	dbg_lss_o, dbg_is_o, dbg_wp_o, dbg_bp_o,
	//dbg_stb_i, dbg_we_i, dbg_adr_i, dbg_dat_i, dbg_dat_o, dbg_ack_o,

	// Power Management
	.pm_clksd_o	( ),
	.pm_cpustall_i	( 1'b0 ),
	.pm_dc_gate_o	( ),
	.pm_ic_gate_o	( ),
	.pm_dmmu_gate_o	( ),
	.pm_immu_gate_o	( ),
	.pm_tt_gate_o	( ),
	.pm_cpu_gate_o	( ),
	.pm_wakeup_o	( ),
	.pm_lvolt_o	( ),

	// Interrupts
	.pic_ints_i	( 20'b0 ),

	.sig_tick(sig_tick)
);

//
//Instruction Wishbone Bus
rom_wb
#(
	.data_width (32),
	.addr_width (13)
)
INST_ROM
(
	.dat_i(wb_rim_dat_o),
	.dat_o(wb_rim_dat_i),
	.adr_i(wb_rim_adr_o),
	.we_i (wb_rim_we_o),
	.sel_i(wb_rim_sel_o),
	.cyc_i(wb_rim_cyc_o),
	.stb_i(wb_rim_stb_o),
	.ack_o(wb_rim_ack_i),
	.cti_i(wb_rim_cti_o),
	.clk_i(wb_clk),
	.rst_i(wb_rst)
);

assign wb_rdm_ack_i = 1'b0;
assign wb_rdm_rty_i = 1'b1;
assign wb_rdm_err_i = 1'b0;
assign wb_rim_rty_i = 1'b0;
assign wb_rim_err_i = 1'b0;

//assign ooo = wb_rim_cyc_o;

//Masters
wishbone_b3 wb_cpu_data ();
wishbone_b3 wb_cpu_inst ();
debug_interface debug ();
wishbone_b3 wb_cpu_dbug ();

proc_wrapper myProc
(
   .clk( wb_clk ),
   .rst( w_rst ),
   .wb_inst( wb_cpu_inst ),
   .wb_data( wb_cpu_data ),
   .debug( debug )
);


//Slaves
wishbone_b3 wb_boot_rom ();
wishbone_b3 wb_ram      ();
wishbone_b3 wb_touchscreen ();

wb_trafficcop_b3
#(
   .masters(3),
   .slaves(3)
)
cop
(
   .master( '{
      wb_cpu_data,
      wb_cpu_inst,
      wb_cpu_dbug
   } ),
   .slave( '{
      wb_boot_rom,
      wb_ram,
      wb_touchscreen
   } ),
   .addrs( '{
      '{32'h00000000,32'h0FFFFFFF},
      '{32'h10000000,32'h1FFFFFFF},
      '{32'h20000000,32'h2FFFFFFF}
   } )
);

assign wb_cpu_data.we =  wb_rdm_we_o;
assign ooo = wb_boot_rom.we;
endmodule
