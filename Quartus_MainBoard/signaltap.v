// megafunction wizard: %SignalTap II Logic Analyzer%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: sld_signaltap 

// ============================================================
// File Name: signaltap.v
// Megafunction Name(s):
// 			sld_signaltap
//
// Simulation Library Files(s):
// 			
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 10.1 Build 153 11/29/2010 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2010 Altera Corporation
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
module signaltap (
	acq_clk,
	acq_data_in,
	acq_trigger_in);

	input	  acq_clk;
	input	[3:0]  acq_data_in;
	input	[0:0]  acq_trigger_in;


	sld_signaltap	sld_signaltap_component (
				.acq_clk (acq_clk),
				.acq_data_in (acq_data_in),
				.acq_trigger_in (acq_trigger_in));
	defparam
		sld_signaltap_component.sld_advanced_trigger_entity = "basic,1,",
		sld_signaltap_component.sld_data_bits = 4,
		sld_signaltap_component.sld_data_bit_cntr_bits = 3,
		sld_signaltap_component.sld_enable_advanced_trigger = 0,
		sld_signaltap_component.sld_mem_address_bits = 10,
		sld_signaltap_component.sld_node_crc_bits = 32,
		sld_signaltap_component.sld_node_crc_hiword = 12460,
		sld_signaltap_component.sld_node_crc_loword = 7991,
		sld_signaltap_component.sld_node_info = 1076736,
		sld_signaltap_component.sld_ram_block_type = "Auto",
		sld_signaltap_component.sld_sample_depth = 1024,
		sld_signaltap_component.sld_storage_qualifier_gap_record = 0,
		sld_signaltap_component.sld_storage_qualifier_mode = "OFF",
		sld_signaltap_component.sld_trigger_bits = 1,
		sld_signaltap_component.sld_trigger_in_enabled = 0,
		sld_signaltap_component.sld_trigger_level = 1,
		sld_signaltap_component.sld_trigger_level_pipeline = 1;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: DATA_WIDTH_SPIN STRING ""
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone III"
// Retrieval info: PRIVATE: RAM_TYPE_COMBO STRING "Auto"
// Retrieval info: PRIVATE: SAMPLE_DEPTH_COMBO STRING "1 K"
// Retrieval info: PRIVATE: SLD_TRIGGER_OUT_ENABLED NUMERIC "0"
// Retrieval info: PRIVATE: TRIGGER_LEVELS_COMBO STRING "1"
// Retrieval info: PRIVATE: TRIGGER_WIDTH_SPIN STRING ""
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: SLD_ADVANCED_TRIGGER_ENTITY STRING "basic,1,"
// Retrieval info: CONSTANT: SLD_DATA_BITS NUMERIC "4"
// Retrieval info: CONSTANT: SLD_DATA_BIT_CNTR_BITS NUMERIC "3"
// Retrieval info: CONSTANT: SLD_ENABLE_ADVANCED_TRIGGER NUMERIC "0"
// Retrieval info: CONSTANT: SLD_MEM_ADDRESS_BITS NUMERIC "10"
// Retrieval info: CONSTANT: SLD_NODE_CRC_BITS NUMERIC "32"
// Retrieval info: CONSTANT: SLD_NODE_CRC_HIWORD NUMERIC "12460"
// Retrieval info: CONSTANT: SLD_NODE_CRC_LOWORD NUMERIC "7991"
// Retrieval info: CONSTANT: SLD_NODE_INFO NUMERIC "1076736"
// Retrieval info: CONSTANT: SLD_RAM_BLOCK_TYPE STRING "Auto"
// Retrieval info: CONSTANT: SLD_SAMPLE_DEPTH NUMERIC "1024"
// Retrieval info: CONSTANT: SLD_STORAGE_QUALIFIER_GAP_RECORD NUMERIC "0"
// Retrieval info: CONSTANT: SLD_STORAGE_QUALIFIER_MODE STRING "OFF"
// Retrieval info: CONSTANT: SLD_TRIGGER_BITS NUMERIC "1"
// Retrieval info: CONSTANT: SLD_TRIGGER_IN_ENABLED NUMERIC "0"
// Retrieval info: CONSTANT: SLD_TRIGGER_LEVEL NUMERIC "1"
// Retrieval info: CONSTANT: SLD_TRIGGER_LEVEL_PIPELINE NUMERIC "1"
// Retrieval info: USED_PORT: acq_clk 0 0 0 0 INPUT NODEFVAL "acq_clk"
// Retrieval info: USED_PORT: acq_data_in 0 0 4 0 INPUT NODEFVAL "acq_data_in[3..0]"
// Retrieval info: USED_PORT: acq_trigger_in 0 0 1 0 INPUT NODEFVAL "acq_trigger_in[0..0]"
// Retrieval info: CONNECT: @acq_clk 0 0 0 0 acq_clk 0 0 0 0
// Retrieval info: CONNECT: @acq_data_in 0 0 4 0 acq_data_in 0 0 4 0
// Retrieval info: CONNECT: @acq_trigger_in 0 0 1 0 acq_trigger_in 0 0 1 0
// Retrieval info: GEN_FILE: TYPE_NORMAL signaltap.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL signaltap.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL signaltap.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL signaltap.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL signaltap_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL signaltap_bb.v TRUE
