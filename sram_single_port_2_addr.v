`timescale 1ns/1ps
`include "cs_constants.v"

module sram_single_port_2_addr
(
	input 						 	 	 clk,
	input 						 	 	 rst,
	input  	  [`PACKET_WIDTH-1:0] data,
	input  	  [`ADDR_WIDTH-1:0] 	 addr,
	
	output     [`PACKET_WIDTH-1:0] candidate_value
);
// Declare the RAM variable
reg [`DATA_WIDTH_256-1:0] memory_0 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_1 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_2 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_3 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_4 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_5 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_6 [3600-1:0];
reg [`DATA_WIDTH_256-1:0] memory_7 [3600-1:0];

reg [`DATA_WIDTH_16-1:0]  candidate_position_request_reg;
always@(posedge clk or negedge rst)
begin
	// Write
	if (~rst) begin
		candidate_position_request_reg <= 0;
	end
	else begin
		memory_0[addr] <= data[(`DATA_WIDTH_256*1)-1:(`DATA_WIDTH_256*0)];
		memory_1[addr] <= data[(`DATA_WIDTH_256*2)-1:(`DATA_WIDTH_256*1)];
		memory_2[addr] <= data[(`DATA_WIDTH_256*3)-1:(`DATA_WIDTH_256*2)];
		memory_3[addr] <= data[(`DATA_WIDTH_256*4)-1:(`DATA_WIDTH_256*3)];
		memory_4[addr] <= data[(`DATA_WIDTH_256*5)-1:(`DATA_WIDTH_256*4)];
		memory_5[addr] <= data[(`DATA_WIDTH_256*6)-1:(`DATA_WIDTH_256*5)];
		memory_6[addr] <= data[(`DATA_WIDTH_256*7)-1:(`DATA_WIDTH_256*6)];
		memory_7[addr] <= data[(`DATA_WIDTH_256*8)-1:(`DATA_WIDTH_256*7)];
		
		candidate_position_request_reg <= addr;
	end
end

// Continuous assignment implies read returns NEW data.
// This is the natural behavior of the TriMatrix memory
// blocks in Single Port mode.  

assign candidate_value[(`DATA_WIDTH_256*1)-1:(`DATA_WIDTH_256*0)] = memory_0[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*2)-1:(`DATA_WIDTH_256*1)] = memory_1[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*3)-1:(`DATA_WIDTH_256*2)] = memory_2[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*4)-1:(`DATA_WIDTH_256*3)] = memory_3[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*5)-1:(`DATA_WIDTH_256*4)] = memory_4[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*6)-1:(`DATA_WIDTH_256*5)] = memory_5[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*7)-1:(`DATA_WIDTH_256*6)] = memory_6[candidate_position_request_reg];
assign candidate_value[(`DATA_WIDTH_256*8)-1:(`DATA_WIDTH_256*7)] = memory_7[candidate_position_request_reg];

endmodule
