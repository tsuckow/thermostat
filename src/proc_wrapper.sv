module proc_wrapper
(
   input logic clk,
   input logic rst,
   wishbone_b3.master wb_inst,
   wishbone_b3.master wb_data,
   debug_interface.master debug,
   input logic [19:0] interrupts
);
//
//Processor
wire sig_tick;

//Wishbone Common
wire wb_clk = clk;
wire wb_rst = rst;

or1200_top proc
(

	.rst_i		( wb_rst ),
	.clk_i		( wb_clk ),

	.clmode_i	( 2'b00 ), // 1 to 1 clock?

	// WISHBONE Instruction Master
	.iwb_clk_i	( wb_clk ),
	.iwb_rst_i	( wb_rst ),
	.iwb_cyc_o	( wb_inst.cyc ),
	.iwb_adr_o	( wb_inst.adr ),
	.iwb_dat_i	( wb_inst.dat_s2m ),
	.iwb_dat_o	( wb_inst.dat_m2s ),
	.iwb_sel_o	( wb_inst.sel ),
	.iwb_ack_i	( wb_inst.ack ),
	.iwb_err_i	( wb_inst.err ),
	.iwb_rty_i	( wb_inst.rty ),
	.iwb_we_o	( wb_inst.we ),
	.iwb_stb_o	( wb_inst.stb ),
	.iwb_cti_o  ( wb_inst.cti ),
	.iwb_bte_o  ( wb_inst.bte ),

	// WISHBONE Data Master
	.dwb_clk_i	( wb_clk ),
	.dwb_rst_i	( wb_rst ),
	.dwb_cyc_o	( wb_data.cyc ),
	.dwb_adr_o	( wb_data.adr ),
	.dwb_dat_i	( wb_data.dat_s2m ),
	.dwb_dat_o	( wb_data.dat_m2s ),
	.dwb_sel_o	( wb_data.sel ),
	.dwb_ack_i	( wb_data.ack ),
	.dwb_err_i	( wb_data.err ),
	.dwb_rty_i	( wb_data.rty ),
	.dwb_we_o	( wb_data.we ),
	.dwb_stb_o	( wb_data.stb ),
	.dwb_cti_o  ( wb_data.cti ),
	.dwb_bte_o  ( wb_data.bte ),

   // Debug
   .dbg_stall_i( debug.stall ),
   .dbg_ewt_i  ( debug.ewt ),
   .dbg_lss_o  ( debug.lss ),
   .dbg_is_o   ( debug.is ),
   .dbg_wp_o   ( debug.wp ),
   .dbg_bp_o   ( debug.bp ),
   .dbg_stb_i  ( debug.stb ),
   .dbg_we_i   ( debug.we ),
   .dbg_adr_i  ( debug.adr ),
   .dbg_dat_i  ( debug.dat_s2m ),
   .dbg_dat_o  ( debug.dat_m2s ),
   .dbg_ack_o  ( debug.ack ),

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
	.pic_ints_i	( interrupts ),

	.sig_tick(sig_tick)
);

endmodule

