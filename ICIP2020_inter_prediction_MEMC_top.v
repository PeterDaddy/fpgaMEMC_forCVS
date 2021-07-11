// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Sun Apr 19 18:33:37 2020"

module ICIP2020_inter_prediction_MEMC_top(
	RST,
	CLK,
	COLUMNS,
	ROWS,
	STREAMING_Y_IN,
	FINISH_FLAG,
	STREAMING_Y_OUT
);


input wire	RST;
input wire	CLK;
input wire	[7:0] COLUMNS;
input wire	[7:0] ROWS;
input wire	[2047:0] STREAMING_Y_IN;
output wire	FINISH_FLAG;
output wire	[2047:0] STREAMING_Y_OUT;

wire	SYNTHESIZED_WIRE_0;
wire	[15:0] SYNTHESIZED_WIRE_1;
wire	[255:0] SYNTHESIZED_WIRE_2;
wire	[255:0] SYNTHESIZED_WIRE_3;





ram_sp_ar_aw	b2v_inst(
	.clock(CLK),
	.wren(SYNTHESIZED_WIRE_0),
	.address(SYNTHESIZED_WIRE_1),
	.data(SYNTHESIZED_WIRE_2),
	.q(SYNTHESIZED_WIRE_3));


memc_3l_hierarchical_search	b2v_inst2(
	.rst(RST),
	.clk(CLK),
	.candidate_y_in(SYNTHESIZED_WIRE_3),
	.columns(COLUMNS),
	.rows(ROWS),
	.streaming_y_in(STREAMING_Y_IN),
	.finish_flag(FINISH_FLAG),
	.we(SYNTHESIZED_WIRE_0),
	.addr(SYNTHESIZED_WIRE_1),
	.data(SYNTHESIZED_WIRE_2),
	.streaming_y_out(STREAMING_Y_OUT));
	defparam	b2v_inst2.five = 3'b101;
	defparam	b2v_inst2.four = 4;
	defparam	b2v_inst2.one = 1;
	defparam	b2v_inst2.three = 3;
	defparam	b2v_inst2.two = 2;
	defparam	b2v_inst2.zero = 0;


endmodule
