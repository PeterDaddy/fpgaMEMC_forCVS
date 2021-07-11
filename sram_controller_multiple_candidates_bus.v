`timescale 1ns/1ps
`include "cs_constants.v"

module sram_controller_multiple_candidates_bus
(
	input   					 	   	 		 rst,
	input   					 	   	 		 clk,
	
	input		  [`ROWS_WIDTH-1:0]  		 rows,
	input		  [`COLUMNS_WIDTH-1:0]		 columns,
	
	input		  [`HIERARCHICAL_LEVEL-1:0] hierarchical_level,
	input		  [`PACKET_WIDTH-1:0] 		 candidate_value_from_sram,

	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_top_left,
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_top_middle,
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_top_right,
	
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_middle_left,
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_middle_right,
	
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_bottom_left,
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_bottom_middle,
	output reg [(`DATA_WIDTH_16*3)-1:0]  candidate_bottom_right,
	
	output reg 							 		 candidate_ready_flag,
	
	output reg [`DATA_WIDTH_16-1:0] 		 candidate_position_request,
	output reg [`PACKET_WIDTH-1:0] 		 sram_data,
	output reg [`ADDR_WIDTH-1:0] 		 	 sram_addr,
	output reg 						 		 	 sram_we
);

reg [1:0] state;

parameter zero=2'b00, one=2'b01, two=2'b10, three=2'b11;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		state 							<= zero;
		candidate_top_left 			<= 0;
		candidate_top_middle 		<= 0;
		candidate_top_right 			<= 0;
	
		candidate_middle_left 		<= 0;
		candidate_middle_right 		<= 0;
	
		candidate_bottom_left 		<= 0;
		candidate_bottom_middle 	<= 0;
		candidate_bottom_right 		<= 0;
	
		candidate_ready_flag 		<= 0;
	
		candidate_position_request <= 0;
		sram_data 						<= 0;
		sram_addr 						<= 0;
		sram_we 							<= 0;
	end
	else begin
//		case (state)
//			  zero:
//					 state = one;
//			  one:
//					 if () begin
//						 state = zero;
//					 end
//					 else begin
//						 state = two;
//					 end
//			  two:
//					 state = three;
//			  three:
//					 state = zero;
//		endcase
	end
end

endmodule
