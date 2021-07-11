`timescale 1ns/1ps
`include "cs_constants.v"

module package_shorten_256
(
	input  [`PACKET_WIDTH-1:0]  streaming_y_in,
	output [`DATA_WIDTH_256-1:0] streaming_y_in_256
);

assign streaming_y_in_256 = streaming_y_in[255:0];

endmodule
