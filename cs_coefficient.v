`include "cs_constants.v"

module cs_coefficient
(
	input 	  [`DATA_WIDTH-1:0]   avg_y_left_out,
	input 	  [`DATA_WIDTH-1:0]   avg_y_up_out,
	input 	  [`DATA_WIDTH-1:0]   avg_y_dc_out,
	output reg [`DATA_WIDTH-1:0]   y_p_left_out_0,
	output reg [`DATA_WIDTH-1:0]   y_p_up_out_0,
	output reg [`DATA_WIDTH-1:0]   y_p_dc_out_0,
	output reg [`DATA_WIDTH-1:0]   y_p_left_out,
	output reg [`DATA_WIDTH-1:0]   y_p_up_out,
	output reg [`DATA_WIDTH-1:0]   y_p_dc_out
);

always@(avg_y_left_out or avg_y_up_out or avg_y_dc_out)
begin
	y_p_left_out_0 = avg_y_left_out << 4'b1000;
	y_p_up_out_0	= avg_y_up_out   << 4'b1000;
	y_p_dc_out_0	= avg_y_dc_out   << 4'b1000;

	y_p_left_out	= avg_y_left_out << 4'b0111;
	y_p_up_out		= avg_y_up_out   << 4'b0111;
	y_p_dc_out		= avg_y_dc_out   << 4'b0111;
end
endmodule

