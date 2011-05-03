// megafunction wizard: %Parallel Flash Loader%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altparallel_flash_loader 

// ============================================================
// File Name: FlashLoader.v
// Megafunction Name(s):
// 			altparallel_flash_loader
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 10.1 Build 197 01/19/2011 SP 1 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2011 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module FlashLoader (
	pfl_flash_access_granted,
	pfl_nreset,
	flash_addr,
	flash_data,
	flash_nce,
	flash_noe,
	flash_nwe,
	pfl_flash_access_request);

	input	  pfl_flash_access_granted;
	input	  pfl_nreset;
	output	[20:0]  flash_addr;
	inout	[15:0]  flash_data;
	output	  flash_nce;
	output	  flash_noe;
	output	  flash_nwe;
	output	  pfl_flash_access_request;

	wire [20:0] sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire  sub_wire3;
	wire  sub_wire4;
	wire [20:0] flash_addr = sub_wire0[20:0];
	wire  pfl_flash_access_request = sub_wire1;
	wire  flash_nce = sub_wire2;
	wire  flash_noe = sub_wire3;
	wire  flash_nwe = sub_wire4;

	altparallel_flash_loader	altparallel_flash_loader_component (
				.flash_data (flash_data),
				.pfl_flash_access_granted (pfl_flash_access_granted),
				.pfl_nreset (pfl_nreset),
				.flash_addr (sub_wire0),
				.pfl_flash_access_request (sub_wire1),
				.flash_nce (sub_wire2),
				.flash_noe (sub_wire3),
				.flash_nwe (sub_wire4)
				// synopsys translate_off
				,
				.flash_ale (),
				.flash_cle (),
				.flash_clk (),
				.flash_io (),
				.flash_io0 (),
				.flash_io1 (),
				.flash_io2 (),
				.flash_io3 (),
				.flash_nadv (),
				.flash_ncs (),
				.flash_nreset (),
				.flash_rdy (),
				.flash_sck (),
				.fpga_conf_done (),
				.fpga_data (),
				.fpga_dclk (),
				.fpga_nconfig (),
				.fpga_nstatus (),
				.fpga_pgm (),
				.pfl_clk (),
				.pfl_nreconfigure (),
				.pfl_reset_watchdog (),
				.pfl_watchdog_error ()
				// synopsys translate_on
				);
	defparam
		altparallel_flash_loader_component.addr_width = 21,
		altparallel_flash_loader_component.disable_crc_checkbox = 0,
		altparallel_flash_loader_component.enhanced_flash_programming = 0,
		altparallel_flash_loader_component.features_cfg = 0,
		altparallel_flash_loader_component.features_pgm = 1,
		altparallel_flash_loader_component.fifo_size = 16,
		altparallel_flash_loader_component.flash_data_width = 16,
		altparallel_flash_loader_component.flash_nreset_checkbox = 0,
		altparallel_flash_loader_component.flash_type = "CFI_FLASH",
		altparallel_flash_loader_component.n_flash = 1,
		altparallel_flash_loader_component.tristate_checkbox = 1;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: DISABLE_CRC_CHECKBOX STRING "1"
// Retrieval info: PRIVATE: IDC_ENHANCED_FLASH_PROGRAMMING_COMBO STRING "Area"
// Retrieval info: PRIVATE: IDC_FIFO_SIZE_COMBO STRING "16"
// Retrieval info: PRIVATE: IDC_FLASH_DATA_WIDTH_COMBO STRING "16 bits"
// Retrieval info: PRIVATE: IDC_FLASH_DEVICE_COMBO STRING "CFI 32 Mbit"
// Retrieval info: PRIVATE: IDC_FLASH_NRESET_CHECKBOX STRING "0"
// Retrieval info: PRIVATE: IDC_FLASH_TYPE_COMBO STRING "CFI Parallel Flash"
// Retrieval info: PRIVATE: IDC_NUM_FLASH_COMBO STRING "1"
// Retrieval info: PRIVATE: IDC_OPERATING_MODES_COMBO STRING "Flash Programming"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone III"
// Retrieval info: PRIVATE: TRISTATE_CHECKBOX STRING "1"
// Retrieval info: CONSTANT: ADDR_WIDTH NUMERIC "21"
// Retrieval info: CONSTANT: DISABLE_CRC_CHECKBOX NUMERIC "0"
// Retrieval info: CONSTANT: ENHANCED_FLASH_PROGRAMMING NUMERIC "0"
// Retrieval info: CONSTANT: FEATURES_CFG NUMERIC "0"
// Retrieval info: CONSTANT: FEATURES_PGM NUMERIC "1"
// Retrieval info: CONSTANT: FIFO_SIZE NUMERIC "16"
// Retrieval info: CONSTANT: FLASH_DATA_WIDTH NUMERIC "16"
// Retrieval info: CONSTANT: FLASH_NRESET_CHECKBOX NUMERIC "0"
// Retrieval info: CONSTANT: FLASH_TYPE STRING "CFI_FLASH"
// Retrieval info: CONSTANT: N_FLASH NUMERIC "1"
// Retrieval info: CONSTANT: TRISTATE_CHECKBOX NUMERIC "1"
// Retrieval info: USED_PORT: flash_addr 0 0 21 0 OUTPUT NODEFVAL "flash_addr[20..0]"
// Retrieval info: USED_PORT: flash_data 0 0 16 0 BIDIR NODEFVAL "flash_data[15..0]"
// Retrieval info: USED_PORT: flash_nce 0 0 0 0 OUTPUT NODEFVAL "flash_nce"
// Retrieval info: USED_PORT: flash_noe 0 0 0 0 OUTPUT NODEFVAL "flash_noe"
// Retrieval info: USED_PORT: flash_nwe 0 0 0 0 OUTPUT NODEFVAL "flash_nwe"
// Retrieval info: USED_PORT: pfl_flash_access_granted 0 0 0 0 INPUT NODEFVAL "pfl_flash_access_granted"
// Retrieval info: USED_PORT: pfl_flash_access_request 0 0 0 0 OUTPUT NODEFVAL "pfl_flash_access_request"
// Retrieval info: USED_PORT: pfl_nreset 0 0 0 0 INPUT NODEFVAL "pfl_nreset"
// Retrieval info: CONNECT: @pfl_flash_access_granted 0 0 0 0 pfl_flash_access_granted 0 0 0 0
// Retrieval info: CONNECT: @pfl_nreset 0 0 0 0 pfl_nreset 0 0 0 0
// Retrieval info: CONNECT: flash_addr 0 0 21 0 @flash_addr 0 0 21 0
// Retrieval info: CONNECT: flash_data 0 0 16 0 @flash_data 0 0 16 0
// Retrieval info: CONNECT: flash_nce 0 0 0 0 @flash_nce 0 0 0 0
// Retrieval info: CONNECT: flash_noe 0 0 0 0 @flash_noe 0 0 0 0
// Retrieval info: CONNECT: flash_nwe 0 0 0 0 @flash_nwe 0 0 0 0
// Retrieval info: CONNECT: pfl_flash_access_request 0 0 0 0 @pfl_flash_access_request 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL FlashLoader.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL FlashLoader.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL FlashLoader.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL FlashLoader.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL FlashLoader_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL FlashLoader_bb.v TRUE
// Retrieval info: LIB_FILE: altera_mf
