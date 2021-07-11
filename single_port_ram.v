// Quartus Prime Verilog Template
// Single port RAM with single read/write address 
`timescale 1ns/1ps
`include "cs_constants.v"
module single_port_ram
(
	input  [`DATA_WIDTH_256-1:0] data,
	input  [`DATA_WIDTH_16-1:0]  addr,
	input 						 	  we, clk,
	output reg [`DATA_WIDTH_256-1:0] q
);

	// Declare the RAM variable
	reg [`DATA_WIDTH_256-1:0] ram[4096-1:0];

	// Variable to hold the registered read address
	reg [`DATA_WIDTH_16-1:0] addr_reg;

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[addr] <= data;

		addr_reg <= addr;
		q = ram[addr];
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	//assign q = ram[addr_reg];

endmodule
