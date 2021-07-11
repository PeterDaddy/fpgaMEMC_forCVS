`timescale 1ns/1ps
`include "cs_constants.v"

module memc_3l_hierarchical_search
(
	input								  	  	   rst,
	input				   			     	   clk,
	input	 signed [`ROWS_WIDTH-1:0]     rows,
	input	 signed [`COLUMNS_WIDTH-1:0]  columns,
	input 	  	  [`PACKET_WIDTH-1:0]   streaming_y_in,
	input 	  	  [`DATA_WIDTH_256-1:0] candidate_y_in,
	
	output reg    [`PACKET_WIDTH-1:0]   streaming_y_out,
	output reg 							  	   finish_flag,
	output reg 	  [`DATA_WIDTH_256-1:0] data,
	output reg 	  [`DATA_WIDTH_16-1:0]  addr,
	output reg 	  					  		   we
);

reg		 					  		  bypass_token;
reg 		  [2:0] 					  state;
reg 		 					  		  hirachical_search_top_finished_flag;
reg 		 					  		  hirachical_search_middle_finished_flag;
reg 		 					  		  hirachical_search_bottom_finished_flag;

reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_x 			     [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_y 			     [-8+1:8-1][-8+1:8-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_top 				   	  [-8+1:8-1][-8+1:8-1];

reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_re_arrange_x 	  [0:9-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_re_arrange_y 	  [0:9-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_top_re_arrange 		  [0:9-1];

reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_first_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_second_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_third_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_first_branch_y;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_second_branch_y;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_top_third_branch_y;

reg 		  [`DATA_WIDTH_16-1:0] temp_top_candidate_value;
reg signed [`DATA_WIDTH_16-1:0] temp_top_candidate_position_x;
reg signed [`DATA_WIDTH_16-1:0] temp_top_candidate_position_y;

reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_x_branch_1	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_x_branch_2	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_x_branch_3	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_y_branch_1	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_y_branch_2	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_y_branch_3	  [-8+1:8-1][-8+1:8-1];

reg 		  [`DATA_WIDTH_16-1:0] candidate_value_middle_branch_1		  [-8+1:8-1][-8+1:8-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_middle_branch_2		  [-8+1:8-1][-8+1:8-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_middle_branch_3		  [-8+1:8-1][-8+1:8-1];

reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_re_arrange_x [0:27-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_re_arrange_y [0:27-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_middle_re_arrange 	  [0:27-1];

reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_first_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_second_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_third_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_first_branch_y;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_second_branch_y;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_middle_third_branch_y;

reg 		  [`DATA_WIDTH_16-1:0] temp_middle_candidate_value;
reg signed [`DATA_WIDTH_16-1:0] temp_middle_candidate_position_x;
reg signed [`DATA_WIDTH_16-1:0] temp_middle_candidate_position_y;

reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_x_branch_1	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_x_branch_2	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_x_branch_3	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_y_branch_1	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_y_branch_2	  [-8+1:8-1][-8+1:8-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_y_branch_3	  [-8+1:8-1][-8+1:8-1];

reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_branch_1		  [-8+1:8-1][-8+1:8-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_branch_2		  [-8+1:8-1][-8+1:8-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_branch_3		  [-8+1:8-1][-8+1:8-1];

reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_re_arrange_x [0:27-1];
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_re_arrange_y [0:27-1];
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_re_arrange 	  [0:27-1];

reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_first_branch;
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_second_branch;
reg 		  [`DATA_WIDTH_16-1:0] candidate_value_bottom_third_branch;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_first_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_second_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_third_branch_x;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_first_branch_y;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_second_branch_y;
reg signed [`DATA_WIDTH_16-1:0] candidate_position_bottom_third_branch_y;

reg 		  [`DATA_WIDTH_16-1:0] temp_bottom_candidate_value;
reg signed [`DATA_WIDTH_16-1:0] temp_bottom_candidate_position_x;
reg signed [`DATA_WIDTH_16-1:0] temp_bottom_candidate_position_y;

reg signed [`DATA_WIDTH_16-1:0] internal_rows_top;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_top;
reg signed [`DATA_WIDTH_16-1:0] internal_rows_middle_branch_1;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_middle_branch_1;
reg signed [`DATA_WIDTH_16-1:0] internal_rows_middle_branch_2;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_middle_branch_2;
reg signed [`DATA_WIDTH_16-1:0] internal_rows_middle_branch_3;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_middle_branch_3;
reg signed [`DATA_WIDTH_16-1:0] internal_rows_bottom_branch_1;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_bottom_branch_1;
reg signed [`DATA_WIDTH_16-1:0] internal_rows_bottom_branch_2;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_bottom_branch_2;
reg signed [`DATA_WIDTH_16-1:0] internal_rows_bottom_branch_3;
reg signed [`DATA_WIDTH_16-1:0] internal_columns_bottom_branch_3;

reg 		  [`DATA_WIDTH_16-1:0] temp_candidate_value_top;
reg		  [`DATA_WIDTH_16-1:0] delay_counter;
parameter zero=3'b000, one=3'b001, two=3'b010, three=3'b011, four=3'b100, five=3'b101, six=3'b110, seven=3'b111;

integer i_rst, j_rst;

reg signed [`DATA_WIDTH_16-1:0] i_top;
reg signed [`DATA_WIDTH_16-1:0] j_top;
reg signed [`DATA_WIDTH_16-1:0] i_top_candidate;
reg signed [`DATA_WIDTH_16-1:0] i_top_candidate_load;
reg signed [`DATA_WIDTH_16-1:0] j_top_candidate_load;

reg signed [`DATA_WIDTH_16-1:0] i_middle;
reg signed [`DATA_WIDTH_16-1:0] j_middle;
reg signed [`DATA_WIDTH_16-1:0] i_middle_candidate;
reg signed [`DATA_WIDTH_16-1:0] i_middle_candidate_load;
reg signed [`DATA_WIDTH_16-1:0] j_middle_candidate_load;

reg signed [`DATA_WIDTH_16-1:0] i_bottom;
reg signed [`DATA_WIDTH_16-1:0] j_bottom;
reg signed [`DATA_WIDTH_16-1:0] i_bottom_candidate;
reg signed [`DATA_WIDTH_16-1:0] i_bottom_candidate_load;
reg signed [`DATA_WIDTH_16-1:0] j_bottom_candidate_load;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		state 											<= zero;
		hirachical_search_top_finished_flag 	<= 0;
		hirachical_search_middle_finished_flag <= 0;
		hirachical_search_bottom_finished_flag <= 0;
		addr												<= 0;
		we													<= 0;
		internal_rows_top 							<= -4;
		internal_columns_top 						<= -4;
		internal_rows_middle_branch_1 			<= -2;
		internal_columns_middle_branch_1 		<= -2;
		internal_rows_middle_branch_2 			<= -2;
		internal_columns_middle_branch_2 		<= -2;
		internal_rows_middle_branch_3 			<= -2;
		internal_columns_middle_branch_3 		<= -2;
		internal_rows_bottom_branch_1 			<= -1;
		internal_columns_bottom_branch_1 		<= -1;
		internal_rows_bottom_branch_2 			<= -1;
		internal_columns_bottom_branch_2 		<= -1;
		internal_rows_bottom_branch_3 			<= -1;
		internal_columns_bottom_branch_3 		<= -1;
		
		i_top_candidate 								<= 8;
		i_top_candidate_load 						<= -4;
		j_top_candidate_load 						<= -4;
		i_top												<= 8;
		j_top												<= 0;
		
		i_middle_candidate 							<= 26;
		i_middle_candidate_load 					<= -2;
		j_middle_candidate_load 					<= -2;
		i_middle											<= 26;
		j_middle											<= 0;

		i_bottom_candidate 							<= 26;
		i_bottom_candidate_load 					<= -1;
		j_bottom_candidate_load 					<= -1;
		i_bottom											<= 26;
		j_bottom											<= 0;
		
		finish_flag 									<= 0;
		bypass_token 									<= 0;
		streaming_y_out 								<= 0;
		delay_counter 									<= 0;
		for (i_rst = -7;i_rst<=7;i_rst=i_rst+1) begin
			for (j_rst= -7;j_rst<=7;j_rst=j_rst+1) begin
				candidate_position_top_x			 	[i_rst][j_rst] <= 0;
				candidate_position_top_y			 	[i_rst][j_rst] <= 0;
				candidate_value_top					 	[i_rst][j_rst] <= 0;
				candidate_value_middle_branch_1	 	[i_rst][j_rst] <= 0;
				candidate_value_middle_branch_2	 	[i_rst][j_rst] <= 0;					
				candidate_value_middle_branch_3	 	[i_rst][j_rst] <= 0;
				candidate_position_middle_x_branch_1[i_rst][j_rst] <= 0;
				candidate_position_middle_x_branch_2[i_rst][j_rst] <= 0;
				candidate_position_middle_x_branch_3[i_rst][j_rst] <= 0;
				candidate_position_middle_y_branch_1[i_rst][j_rst] <= 0;
				candidate_position_middle_y_branch_2[i_rst][j_rst] <= 0;
				candidate_position_middle_y_branch_3[i_rst][j_rst] <= 0;
				candidate_value_bottom_branch_1	 		[i_rst][j_rst] <= 0;
				candidate_value_bottom_branch_2	 		[i_rst][j_rst] <= 0;					
				candidate_value_bottom_branch_3	 		[i_rst][j_rst] <= 0;
				candidate_position_bottom_x_branch_1	[i_rst][j_rst] <= 0;
				candidate_position_bottom_x_branch_2	[i_rst][j_rst] <= 0;
				candidate_position_bottom_x_branch_3	[i_rst][j_rst] <= 0;
				candidate_position_bottom_y_branch_1	[i_rst][j_rst] <= 0;
				candidate_position_bottom_y_branch_2	[i_rst][j_rst] <= 0;
				candidate_position_bottom_y_branch_3	[i_rst][j_rst] <= 0;
			end
		end
	end
	else begin
		if(state == zero) begin
			finish_flag 	 <= 0;
			//Bypass first frame
			if (~bypass_token) begin
				streaming_y_out <= streaming_y_in;
				if (rows == 45-1 && columns == 80-1) begin
					bypass_token <= 1;
				end
				state <= three;
			end
			else begin
				if(internal_rows_top<=4) begin
					if(internal_columns_top<=4) begin
						candidate_position_top_x[internal_rows_top][internal_columns_top] <= internal_rows_top;
						candidate_position_top_y[internal_rows_top][internal_columns_top] <= internal_columns_top;
						addr 																					<= ((internal_rows_top+rows)*80)+(internal_columns_top+columns);
						if(((internal_rows_top+rows)<0) || ((internal_columns_top+columns)<0)) begin
							candidate_value_top		[internal_rows_top][internal_columns_top] <= streaming_y_in[`DATA_WIDTH_16-1:0];
							internal_columns_top																<= internal_columns_top+4;
						end
						else begin
							if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
								delay_counter <= delay_counter+1;
							end
							else begin
								candidate_value_top	[internal_rows_top][internal_columns_top] 	<= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
								internal_columns_top																<= internal_columns_top+4;
								delay_counter 																		<= 0;
							end
						end
					end
					else begin
						internal_rows_top 	<= internal_rows_top+4;
						internal_columns_top <= -4;
					end
				end
				
				else begin
					//Candidate value re-arrange
					if (i_top_candidate_load <= 4) begin
						if (j_top_candidate_load <= 4) begin
							if (i_top_candidate >= 0) begin	
								candidate_value_top_re_arrange[i_top_candidate]      <= candidate_value_top[i_top_candidate_load][j_top_candidate_load];
								candidate_position_top_re_arrange_x[i_top_candidate] <= candidate_position_top_x[i_top_candidate_load][j_top_candidate_load];
								candidate_position_top_re_arrange_y[i_top_candidate] <= candidate_position_top_y[i_top_candidate_load][j_top_candidate_load];
							end
							j_top_candidate_load <= j_top_candidate_load + 4;
							i_top_candidate 		<= i_top_candidate - 1;
						end
						else begin
							i_top_candidate_load <= i_top_candidate_load + 4;
							j_top_candidate_load <= -4;
						end
					end
					else begin
						//Sorting algorithm
						if (i_top >= 0) begin
							if (j_top < i_top) begin
								if (candidate_value_top_re_arrange[j_top] < candidate_value_top_re_arrange[j_top + 1]) begin
									candidate_value_top_re_arrange[j_top + 1]		  <= candidate_value_top_re_arrange[j_top];
									candidate_value_top_re_arrange[j_top] 	   	  <= candidate_value_top_re_arrange[j_top + 1];
									
									candidate_position_top_re_arrange_x[j_top + 1] <= candidate_position_top_re_arrange_x[j_top];
									candidate_position_top_re_arrange_x[j_top] 	  <= candidate_position_top_re_arrange_x[j_top + 1];
									
									candidate_position_top_re_arrange_y[j_top + 1] <= candidate_position_top_re_arrange_y[j_top];
									candidate_position_top_re_arrange_y[j_top] 	  <= candidate_position_top_re_arrange_y[j_top + 1];
								end
								else if (candidate_value_top_re_arrange[j_top] == candidate_value_top_re_arrange[j_top + 1]) begin
									candidate_value_top_re_arrange[j_top]  	 	  <= 16'b1111111111111111;
									candidate_position_top_re_arrange_x[j_top] 	  <= 16'b1111111111111111;
									candidate_position_top_re_arrange_y[j_top] 	  <= 16'b1111111111111111;
								end
								j_top <= j_top + 1;
							end
							else begin
								i_top <= i_top - 1;
								j_top <= 0;
							end
						end
						else begin
							candidate_position_top_first_branch_x  <= candidate_position_top_re_arrange_x[8];
							candidate_position_top_second_branch_x <= candidate_position_top_re_arrange_x[7];
							candidate_position_top_third_branch_x  <= candidate_position_top_re_arrange_x[6];

							candidate_position_top_first_branch_y  <= candidate_position_top_re_arrange_y[8];
							candidate_position_top_second_branch_y <= candidate_position_top_re_arrange_y[7];
							candidate_position_top_third_branch_y  <= candidate_position_top_re_arrange_y[6];
							
							hirachical_search_top_finished_flag 	<= 1;
							state 											<= one;
						end
					end
				end
			end
		end
		
		else if(state == one) begin
			//Branch 1
			if(internal_rows_middle_branch_1<=2) begin
				if(internal_columns_middle_branch_1<=2) begin
					candidate_position_middle_x_branch_1[internal_rows_middle_branch_1+candidate_position_top_first_branch_x][internal_columns_middle_branch_1+candidate_position_top_first_branch_y] <= internal_rows_middle_branch_1+candidate_position_top_first_branch_x;
					candidate_position_middle_y_branch_1[internal_rows_middle_branch_1+candidate_position_top_first_branch_x][internal_columns_middle_branch_1+candidate_position_top_first_branch_y] <= internal_columns_middle_branch_1+candidate_position_top_first_branch_y;
					addr = ((internal_rows_middle_branch_1+candidate_position_top_first_branch_x)*80)+(internal_columns_middle_branch_1+candidate_position_top_first_branch_y);//Asynchronous read with offset;
					if(((internal_rows_middle_branch_1+candidate_position_top_first_branch_x)<0) || ((internal_columns_middle_branch_1+candidate_position_top_first_branch_y)<0)) begin
						candidate_value_middle_branch_1	 	[internal_rows_middle_branch_1+candidate_position_top_first_branch_x][internal_columns_middle_branch_1+candidate_position_top_first_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0];
						internal_columns_middle_branch_1 <= internal_columns_middle_branch_1+2;
					end
					else begin
						if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
							delay_counter <= delay_counter+1;
						end
						else begin
							candidate_value_middle_branch_1	 	[internal_rows_middle_branch_1+candidate_position_top_first_branch_x][internal_columns_middle_branch_1+candidate_position_top_first_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
							internal_columns_middle_branch_1 <= internal_columns_middle_branch_1+2;
							delay_counter 							<= 0;
						end
					end
				end
				else begin
					internal_columns_middle_branch_1 <= -2;
					internal_rows_middle_branch_1 	<= internal_rows_middle_branch_1+2;
				end
			end
			else begin
				//Branch 2
				if(internal_rows_middle_branch_2<=2) begin
					if(internal_columns_middle_branch_2<=2) begin
						candidate_position_middle_x_branch_2[internal_rows_middle_branch_2+candidate_position_top_second_branch_x][internal_columns_middle_branch_2+candidate_position_top_second_branch_y] <= internal_rows_middle_branch_2+candidate_position_top_second_branch_x;
						candidate_position_middle_y_branch_2[internal_rows_middle_branch_2+candidate_position_top_second_branch_x][internal_columns_middle_branch_2+candidate_position_top_second_branch_y] <= internal_columns_middle_branch_2+candidate_position_top_second_branch_y;
						addr = ((internal_rows_middle_branch_2+candidate_position_top_second_branch_x)*80)+(internal_columns_middle_branch_2+candidate_position_top_second_branch_y);//Asynchronous read with offset;
						if(((internal_rows_middle_branch_2+candidate_position_top_second_branch_x)<0) || ((internal_columns_middle_branch_2+candidate_position_top_second_branch_y)<0)) begin
							candidate_value_middle_branch_2	 	[internal_rows_middle_branch_2+candidate_position_top_second_branch_x][internal_columns_middle_branch_2+candidate_position_top_second_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0];
							internal_columns_middle_branch_2 <= internal_columns_middle_branch_2+2;
						end
						else begin
							if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
								delay_counter <= delay_counter+1;
							end
							else begin
								candidate_value_middle_branch_2	 	[internal_rows_middle_branch_2+candidate_position_top_second_branch_x][internal_columns_middle_branch_2+candidate_position_top_second_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
								internal_columns_middle_branch_2 <= internal_columns_middle_branch_2+2;
								delay_counter 							<= 0;
							end
						end
					end
					else begin
						internal_columns_middle_branch_2 <= -2;
						internal_rows_middle_branch_2 	<= internal_rows_middle_branch_2+2;
					end
				end
				else begin
					//Branch 3
					if(internal_rows_middle_branch_3<=2) begin
						if(internal_columns_middle_branch_3<=2) begin
							candidate_position_middle_x_branch_3[internal_rows_middle_branch_3+candidate_position_top_third_branch_x][internal_columns_middle_branch_3+candidate_position_top_third_branch_y] <= internal_rows_middle_branch_3+candidate_position_top_third_branch_x;
							candidate_position_middle_y_branch_3[internal_rows_middle_branch_3+candidate_position_top_third_branch_x][internal_columns_middle_branch_3+candidate_position_top_third_branch_y] <= internal_columns_middle_branch_3+candidate_position_top_third_branch_y;
							addr = ((internal_rows_middle_branch_3+candidate_position_top_third_branch_x)*80)+(internal_columns_middle_branch_3+candidate_position_top_third_branch_y);//Asynchronous read with offset;
							if(((internal_rows_middle_branch_3+candidate_position_top_third_branch_x)<0) || ((internal_columns_middle_branch_3+candidate_position_top_third_branch_y)<0)) begin
								candidate_value_middle_branch_3	 	[internal_rows_middle_branch_3+candidate_position_top_third_branch_x][internal_columns_middle_branch_3+candidate_position_top_third_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0];
								internal_columns_middle_branch_3 <= internal_columns_middle_branch_3+2;
							end
							else begin
								if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
									delay_counter <= delay_counter+1;
								end
								else begin
									candidate_value_middle_branch_3	 	[internal_rows_middle_branch_3+candidate_position_top_third_branch_x][internal_columns_middle_branch_3+candidate_position_top_third_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
									internal_columns_middle_branch_3 <= internal_columns_middle_branch_3+2;
									delay_counter 							<= 0;
								end
							end
						end
						else begin
							internal_columns_middle_branch_3 <= -2;
							internal_rows_middle_branch_3 	<= internal_rows_middle_branch_3+2;
						end
					end
					else begin
						//Candidate value re-arrange
						if(i_middle_candidate_load <= 2) begin
							if(j_middle_candidate_load <= 2) begin
								if(i_middle_candidate >= 0) begin	
									candidate_value_middle_re_arrange[i_middle_candidate]    	  <= candidate_value_middle_branch_1[i_middle_candidate_load+candidate_position_top_first_branch_x] [j_middle_candidate_load+candidate_position_top_first_branch_y];
									candidate_value_middle_re_arrange[i_middle_candidate-9]  	  <= candidate_value_middle_branch_2[i_middle_candidate_load+candidate_position_top_second_branch_x][j_middle_candidate_load+candidate_position_top_second_branch_y];
									candidate_value_middle_re_arrange[i_middle_candidate-18] 	  <= candidate_value_middle_branch_3[i_middle_candidate_load+candidate_position_top_third_branch_x] [j_middle_candidate_load+candidate_position_top_third_branch_y];
									
									candidate_position_middle_re_arrange_x[i_middle_candidate]    <= candidate_position_middle_x_branch_1[i_middle_candidate_load+candidate_position_top_first_branch_x] [j_middle_candidate_load+candidate_position_top_first_branch_y];
									candidate_position_middle_re_arrange_x[i_middle_candidate-9]  <= candidate_position_middle_x_branch_2[i_middle_candidate_load+candidate_position_top_second_branch_x][j_middle_candidate_load+candidate_position_top_second_branch_y];
									candidate_position_middle_re_arrange_x[i_middle_candidate-18] <= candidate_position_middle_x_branch_3[i_middle_candidate_load+candidate_position_top_third_branch_x] [j_middle_candidate_load+candidate_position_top_third_branch_y];
									
									candidate_position_middle_re_arrange_y[i_middle_candidate]    <= candidate_position_middle_y_branch_1[i_middle_candidate_load+candidate_position_top_first_branch_x] [j_middle_candidate_load+candidate_position_top_first_branch_y];
									candidate_position_middle_re_arrange_y[i_middle_candidate-9]  <= candidate_position_middle_y_branch_2[i_middle_candidate_load+candidate_position_top_second_branch_x][j_middle_candidate_load+candidate_position_top_second_branch_y];
									candidate_position_middle_re_arrange_y[i_middle_candidate-18] <= candidate_position_middle_y_branch_3[i_middle_candidate_load+candidate_position_top_third_branch_x] [j_middle_candidate_load+candidate_position_top_third_branch_y];
								end
								j_middle_candidate_load <= j_middle_candidate_load + 2;
								i_middle_candidate 		<= i_middle_candidate - 1;
							end
							else begin
								i_middle_candidate_load <= i_middle_candidate_load + 2;
								j_middle_candidate_load <= -2;
							end
						end
						else begin
							//Sorting algorithm 
							if(i_middle >= 0) begin
								if(j_middle < i_middle) begin
									if(candidate_value_middle_re_arrange[j_middle] < candidate_value_middle_re_arrange[j_middle + 1]) begin
										candidate_value_middle_re_arrange[j_middle + 1]		  <= candidate_value_middle_re_arrange[j_middle];
										candidate_value_middle_re_arrange[j_middle] 	   	  <= candidate_value_middle_re_arrange[j_middle + 1];

										candidate_position_middle_re_arrange_x[j_middle + 1] <= candidate_position_middle_re_arrange_x[j_middle];
										candidate_position_middle_re_arrange_x[j_middle] 	  <= candidate_position_middle_re_arrange_x[j_middle + 1];

										candidate_position_middle_re_arrange_y[j_middle + 1] <= candidate_position_middle_re_arrange_y[j_middle];
										candidate_position_middle_re_arrange_y[j_middle] 	  <= candidate_position_middle_re_arrange_y[j_middle + 1];
									end
									else if (candidate_value_middle_re_arrange[j_middle] == candidate_value_middle_re_arrange[j_middle + 1]) begin
										candidate_value_middle_re_arrange[j_middle]	  		  <= 16'b1111111111111111;
										candidate_position_middle_re_arrange_x[j_middle] 	  <= 32'b11111111111111111111111111111111;
										candidate_position_middle_re_arrange_y[j_middle]     <= 32'b11111111111111111111111111111111;
									end
									j_middle <= j_middle + 1;
								end
								else begin
									i_middle <= i_middle - 1;
									j_middle <= 0;
								end 
							end
							else begin
								candidate_position_middle_first_branch_x  <= candidate_position_middle_re_arrange_x[26];
								candidate_position_middle_second_branch_x <= candidate_position_middle_re_arrange_x[25];
								candidate_position_middle_third_branch_x  <= candidate_position_middle_re_arrange_x[24];
							
								candidate_position_middle_first_branch_y  <= candidate_position_middle_re_arrange_y[26];
								candidate_position_middle_second_branch_y <= candidate_position_middle_re_arrange_y[25];
								candidate_position_middle_third_branch_y  <= candidate_position_middle_re_arrange_y[24];
								
								hirachical_search_middle_finished_flag 	<= 1;
								state 												<= two;
							end
						end
					end
				end
			end
		end
		
		else if(state == two) begin
			//Branch 1
			if(internal_rows_bottom_branch_1<=2) begin
				if(internal_columns_bottom_branch_1<=2) begin
					candidate_position_bottom_x_branch_1[internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x][internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y] <= internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x;
					candidate_position_bottom_y_branch_1[internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x][internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y] <= internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y;
					addr = ((internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x)*80)+(internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y);//Asynchronous read with offset;
					if(((internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x)<0) || ((internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y)<0)) begin
						candidate_value_bottom_branch_1	 	[internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x][internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0];
						internal_columns_bottom_branch_1 <= internal_columns_bottom_branch_1+2;
					end
					else begin
						if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
							delay_counter <= delay_counter+1;
						end
						else begin
							candidate_value_bottom_branch_1	 	[internal_rows_bottom_branch_1+candidate_position_middle_first_branch_x][internal_columns_bottom_branch_1+candidate_position_middle_first_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
							internal_columns_bottom_branch_1 <= internal_columns_bottom_branch_1+2;
							delay_counter 							<= 0;
						end
					end
				end
				else begin
					internal_columns_bottom_branch_1 <= -2;
					internal_rows_bottom_branch_1 	<= internal_rows_bottom_branch_1+2;
				end
			end
			else begin
				//Branch 2
				if(internal_rows_bottom_branch_2<=2) begin
					if(internal_columns_bottom_branch_2<=2) begin
						candidate_position_bottom_x_branch_2[internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x][internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y] <= internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x;
						candidate_position_bottom_y_branch_2[internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x][internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y] <= internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y;
						addr = ((internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x)*80)+(internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y);//Asynchronous read with offset;
						if(((internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x)<0) || ((internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y)<0)) begin
							candidate_value_bottom_branch_2	 	[internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x][internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0];
							internal_columns_bottom_branch_2 <= internal_columns_bottom_branch_2+2;
						end
						else begin
							if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
								delay_counter <= delay_counter+1;
							end
							else begin
								candidate_value_bottom_branch_2	 	[internal_rows_bottom_branch_2+candidate_position_middle_second_branch_x][internal_columns_bottom_branch_2+candidate_position_middle_second_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
								internal_columns_bottom_branch_2 <= internal_columns_bottom_branch_2+2;
								delay_counter 							<= 0;
							end
						end
					end
					else begin
						internal_columns_bottom_branch_2 <= -2;
						internal_rows_bottom_branch_2 	<= internal_rows_bottom_branch_2+2;
					end
				end
				else begin
					//Branch 3
					if(internal_rows_bottom_branch_3<=2) begin
						if(internal_columns_bottom_branch_3<=2) begin
							candidate_position_bottom_x_branch_3[internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x][internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y] <= internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x;
							candidate_position_bottom_y_branch_3[internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x][internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y] <= internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y;
							addr = ((internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x)*80)+(internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y);//Asynchronous read with offset;
							if(((internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x)<0) || ((internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y)<0)) begin
								candidate_value_bottom_branch_3	 	[internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x][internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0];
								internal_columns_bottom_branch_3 <= internal_columns_bottom_branch_3+2;
							end
							else begin
								if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
									delay_counter <= delay_counter+1;
								end
								else begin
									candidate_value_bottom_branch_3	 	[internal_rows_bottom_branch_3+candidate_position_middle_third_branch_x][internal_columns_bottom_branch_3+candidate_position_middle_third_branch_y] <= streaming_y_in[`DATA_WIDTH_16-1:0] - candidate_y_in[`DATA_WIDTH_16-1:0];
									internal_columns_bottom_branch_3 <= internal_columns_bottom_branch_3+2;
									delay_counter 							<= 0;
								end
							end
						end
						else begin
							internal_columns_bottom_branch_3 <= -2;
							internal_rows_bottom_branch_3 	<= internal_rows_bottom_branch_3+2;
						end
					end
					else begin
						if(i_bottom_candidate_load <= 1) begin
							if(j_bottom_candidate_load <= 1) begin
								if(i_bottom_candidate >= 0) begin	
									candidate_value_bottom_re_arrange[i_bottom_candidate]    	  <= candidate_value_bottom_branch_1[i_bottom_candidate_load+candidate_position_top_first_branch_x] [j_bottom_candidate_load+candidate_position_top_first_branch_y];
									candidate_value_bottom_re_arrange[i_bottom_candidate-9]  	  <= candidate_value_bottom_branch_2[i_bottom_candidate_load+candidate_position_top_second_branch_x][j_bottom_candidate_load+candidate_position_top_second_branch_y];
									candidate_value_bottom_re_arrange[i_bottom_candidate-18] 	  <= candidate_value_bottom_branch_3[i_bottom_candidate_load+candidate_position_top_third_branch_x] [j_bottom_candidate_load+candidate_position_top_third_branch_y];
									
									candidate_position_bottom_re_arrange_x[i_bottom_candidate]    <= candidate_position_bottom_x_branch_1[i_bottom_candidate_load+candidate_position_top_first_branch_x] [j_bottom_candidate_load+candidate_position_top_first_branch_y];
									candidate_position_bottom_re_arrange_x[i_bottom_candidate-9]  <= candidate_position_bottom_x_branch_2[i_bottom_candidate_load+candidate_position_top_second_branch_x][j_bottom_candidate_load+candidate_position_top_second_branch_y];
									candidate_position_bottom_re_arrange_x[i_bottom_candidate-18] <= candidate_position_bottom_x_branch_3[i_bottom_candidate_load+candidate_position_top_third_branch_x] [j_bottom_candidate_load+candidate_position_top_third_branch_y];
									
									candidate_position_bottom_re_arrange_y[i_bottom_candidate]    <= candidate_position_bottom_y_branch_1[i_bottom_candidate_load+candidate_position_top_first_branch_x] [j_bottom_candidate_load+candidate_position_top_first_branch_y];
									candidate_position_bottom_re_arrange_y[i_bottom_candidate-9]  <= candidate_position_bottom_y_branch_2[i_bottom_candidate_load+candidate_position_top_second_branch_x][j_bottom_candidate_load+candidate_position_top_second_branch_y];
									candidate_position_bottom_re_arrange_y[i_bottom_candidate-18] <= candidate_position_bottom_y_branch_3[i_bottom_candidate_load+candidate_position_top_third_branch_x] [j_bottom_candidate_load+candidate_position_top_third_branch_y];
								end
								j_bottom_candidate_load <= j_bottom_candidate_load + 1;
								i_bottom_candidate 		<= i_bottom_candidate - 1;
							end
							else begin
								i_bottom_candidate_load <= i_bottom_candidate_load + 1;
								j_bottom_candidate_load <= 0;
							end
						end
						else begin
							//Sorting algorithm 
							if(i_bottom >= 0) begin
								if(j_bottom < i_bottom) begin
									if(candidate_value_bottom_re_arrange[j_bottom] < candidate_value_bottom_re_arrange[j_bottom + 1]) begin
										temp_bottom_candidate_value					  		  <= candidate_value_bottom_re_arrange[j_bottom];
										candidate_value_bottom_re_arrange[j_bottom] 	   	  <= candidate_value_bottom_re_arrange[j_bottom + 1];
										candidate_value_bottom_re_arrange[j_bottom + 1]		  <= temp_bottom_candidate_value;
										
										temp_bottom_candidate_position_x					     <= candidate_position_bottom_re_arrange_x[j_bottom];
										candidate_position_bottom_re_arrange_x[j_bottom] 	  <= candidate_position_bottom_re_arrange_x[j_bottom + 1];
										candidate_position_bottom_re_arrange_x[j_bottom + 1] <= temp_bottom_candidate_position_x;
										
										temp_bottom_candidate_position_y					     <= candidate_position_bottom_re_arrange_y[j_bottom];
										candidate_position_bottom_re_arrange_y[j_bottom] 	  <= candidate_position_bottom_re_arrange_y[j_bottom + 1];
										candidate_position_bottom_re_arrange_y[j_bottom + 1] <= temp_bottom_candidate_position_y;
									end
									else if (candidate_value_bottom_re_arrange[j_bottom] == candidate_value_bottom_re_arrange[j_bottom + 1]) begin
										candidate_value_bottom_re_arrange[j_bottom]	  		  <= 16'b1111111111111111;
										candidate_position_bottom_re_arrange_x[j_bottom] 	  <= 32'b11111111111111111111111111111111;
										candidate_position_bottom_re_arrange_y[j_bottom]     <= 32'b11111111111111111111111111111111;
									end
									j_bottom <= j_bottom + 1;
								end
								else begin
									i_bottom <= i_bottom - 1;
									j_bottom <= 0;
								end 
							end
							else begin
								candidate_position_bottom_first_branch_x <= candidate_position_bottom_re_arrange_x[26];
								candidate_position_bottom_first_branch_y <= candidate_position_bottom_re_arrange_y[26];			
								hirachical_search_bottom_finished_flag   <= 1;
								state 											  <= three;
							end
						end
					end
				end
			end
		end

		else if(state == three) begin //output
			//Bypass first frame
			if (~bypass_token) begin
				streaming_y_out <= streaming_y_in;
				state 			 <= four;
			end
			else begin
				addr = ((candidate_position_bottom_first_branch_x+rows)*80)+(candidate_position_bottom_first_branch_y+columns);
				if(delay_counter < 3) begin // wait for SRAM reply 1 clock for output and 2 clocks for SRAM
					delay_counter <= delay_counter+1;
				end
				else begin
					streaming_y_out <= streaming_y_in - candidate_y_in;
					delay_counter 	 <= 0;
					state 			 <= four;
				end
			end
		end

		else if(state == four) begin // writeback
			addr 				 <= (rows*80)+columns;
			we 				 <= 1;
			data				 <= streaming_y_out;
			finish_flag 	 <= 1;
			state 			 <= five;
		end
		
		else if(state == five) begin //reset stage
			state 											<= zero;
			hirachical_search_top_finished_flag 	<= 0;
			hirachical_search_middle_finished_flag <= 0;
			hirachical_search_bottom_finished_flag <= 0;
			addr 												<= 0;
			we													<= 0;
			internal_rows_top 							<= -4;
			internal_columns_top 						<= -4;
			internal_rows_middle_branch_1 			<= -2;
			internal_columns_middle_branch_1 		<= -2;
			internal_rows_middle_branch_2 			<= -2;
			internal_columns_middle_branch_2 		<= -2;
			internal_rows_middle_branch_3 			<= -2;
			internal_columns_middle_branch_3 		<= -2;
			internal_rows_bottom_branch_1 			<= -1;
			internal_columns_bottom_branch_1 		<= -1;
			internal_rows_bottom_branch_2 			<= -1;
			internal_columns_bottom_branch_2 		<= -1;
			internal_rows_bottom_branch_3 			<= -1;
			internal_columns_bottom_branch_3 		<= -1;
			
			i_top_candidate 								<= 8;
			i_top_candidate_load 						<= -4;
			j_top_candidate_load 						<= -4;
			i_top												<= 8;
			j_top												<= 0;
			
			i_middle_candidate 							<= 26;
			i_middle_candidate_load 					<= -2;
			j_middle_candidate_load 					<= -2;
			i_middle											<= 26;
			j_middle											<= 0;
	
			i_bottom_candidate 							<= 26;
			i_bottom_candidate_load 					<= -1;
			j_bottom_candidate_load 					<= -1;
			i_bottom											<= 26;
			j_bottom											<= 0;
			
			for (i_rst = -7;i_rst<=7;i_rst=i_rst+1) begin
				for (j_rst= -7;j_rst<=7;j_rst=j_rst+1) begin
					candidate_position_top_x			 	 [i_rst][j_rst] <= 0;
					candidate_position_top_y			 	 [i_rst][j_rst] <= 0;
					candidate_value_top					 	 [i_rst][j_rst] <= 0;
					candidate_value_middle_branch_1	 	 [i_rst][j_rst] <= 0;
					candidate_value_middle_branch_2	 	 [i_rst][j_rst] <= 0;					
					candidate_value_middle_branch_3	 	 [i_rst][j_rst] <= 0;
					candidate_position_middle_x_branch_1 [i_rst][j_rst] <= 0;
					candidate_position_middle_x_branch_2 [i_rst][j_rst] <= 0;
					candidate_position_middle_x_branch_3 [i_rst][j_rst] <= 0;
					candidate_position_middle_y_branch_1 [i_rst][j_rst] <= 0;
					candidate_position_middle_y_branch_2 [i_rst][j_rst] <= 0;
					candidate_position_middle_y_branch_3 [i_rst][j_rst] <= 0;
					candidate_value_bottom_branch_1	 	 [i_rst][j_rst] <= 0;
					candidate_value_bottom_branch_2	 	 [i_rst][j_rst] <= 0;					
					candidate_value_bottom_branch_3	 	 [i_rst][j_rst] <= 0;
					candidate_position_bottom_x_branch_1 [i_rst][j_rst] <= 0;
					candidate_position_bottom_x_branch_2 [i_rst][j_rst] <= 0;
					candidate_position_bottom_x_branch_3 [i_rst][j_rst] <= 0;
					candidate_position_bottom_y_branch_1 [i_rst][j_rst] <= 0;
					candidate_position_bottom_y_branch_2 [i_rst][j_rst] <= 0;
					candidate_position_bottom_y_branch_3 [i_rst][j_rst] <= 0;
				end
			end
		end
	end
end
endmodule
