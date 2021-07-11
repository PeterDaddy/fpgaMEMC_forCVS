`timescale 1ns/1ps
`include "cs_constants.v"

module ICIP2020_inter_prediction_MEMC_top_tb;
reg				RST;
reg				CLK;
reg	[7:0]    COLUMNS;
reg	[7:0]    ROWS;
reg	[2047:0] STREAMING_Y_IN;
wire				FINISH_FLAG;
wire	[2047:0] STREAMING_Y_OUT;

reg				state;
reg   [15:0] 	buffer [0:3600-1];
reg   [15:0] 	memory [0:128-1][0:3600-1]; 
reg   [15:0] 	output_memory [0:128-1][0:1200-1]; 

ICIP2020_inter_prediction_MEMC_top DUT(
	.CLK(CLK),
	.RST(RST),
	.COLUMNS(COLUMNS),
	.ROWS(ROWS),
	.STREAMING_Y_IN(STREAMING_Y_IN),
	.FINISH_FLAG(FINISH_FLAG),
	.STREAMING_Y_OUT(STREAMING_Y_OUT)
	);

integer i, j, SLOT, MODES, fd_mode;
integer INDEX   = 0;
integer INDEX_I = 0;
integer INDEX_J = 0;
integer INDEX_K = 0;
integer INDEX_LIMITED = 0;

reg [31:0] fd 		 [0:128-1];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           

initial begin 
  MODES   	  = 2'b01; //00-25 01-50 10-75
  SLOT 		  = 0;
  
  //___READMEMH INITIALIZED___
  if(MODES == 2'b00) begin
	  INDEX_LIMITED = 64;
  end
  else if(MODES == 2'b01) begin
	  INDEX_LIMITED = 128;  
  end
  else if(MODES == 2'b10) begin
	  INDEX_LIMITED = 192;
  end
  else begin
	  INDEX_LIMITED = 0;
  end
  
  fd_mode = $fopen("C:/Users/Jay/Desktop/Research/FPGA_ASIC/ICIP2020_FPGA_inter_prediction_MEMC/y_reconstruct/modes.dat", "w");
  
  for(i=0; i<=INDEX_LIMITED-1; i=i+1) begin
		$readmemb($sformatf("C:/Users/Jay/Desktop/Research/FPGA_ASIC/ICIP2020_FPGA_inter_prediction_MEMC/y_source/TouchDown_y%0d.dat",i), buffer);
		fd[i]   = $fopen($sformatf("C:/Users/Jay/Research/FPGA_ASIC/Desktop/ICIP2020_FPGA_inter_prediction_MEMC/y_reconstruct/TouchDown_y%0d.dat",i), "w");
		for (j=0; j<=3600-1; j=j+1) begin
			memory[i][j] = buffer[j];
		end
  end
end 
    
initial begin
  CLK = 1'b0;
  RST = 1'b0;
  repeat(2) #10 CLK = ~CLK;
  RST = 1'b1;
  forever #10 CLK = ~CLK; // generate a clock
end

initial begin
	for(ROWS=0; ROWS<=45-1; ROWS=ROWS+1) begin
		for(COLUMNS=0; COLUMNS<=80-1; COLUMNS=COLUMNS+1) begin
			if(SLOT <= 3600) begin
				for(INDEX=0; INDEX<=INDEX_LIMITED-1; INDEX=INDEX+1) begin //LMB first
					STREAMING_Y_IN[`DATA_WIDTH_16*INDEX +: `DATA_WIDTH_16] = memory[INDEX][SLOT];
				end
				@(posedge FINISH_FLAG)
//				for(INDEX=0; INDEX<=INDEX_LIMITED-1; INDEX=INDEX+1) begin
//					$display(`DATA_WIDTH_16*INDEX);
//					$fwrite(fd[INDEX],"%d\n", $signed(PACKAGE_OUT[`DATA_WIDTH_16*INDEX +: `DATA_WIDTH_16]));
//				end
//				$fwrite(fd_mode,"%d\n", PREDICTION_MODE);
				SLOT = SLOT+1;
			end
		end
	end
	
	SLOT 	  = 0;
	ROWS 	  = 0;
	COLUMNS = 0;
	for(ROWS=0; ROWS<=45-1; ROWS=ROWS+1) begin
		for(COLUMNS=0; COLUMNS<=80-1; COLUMNS=COLUMNS+1) begin
			if(SLOT <= 3600) begin
				for(INDEX=0; INDEX<=INDEX_LIMITED-1; INDEX=INDEX+1) begin //LMB first
					STREAMING_Y_IN[`DATA_WIDTH_16*INDEX +: `DATA_WIDTH_16] = memory[INDEX][SLOT];
				end
				@(posedge FINISH_FLAG)
//				for(INDEX=0; INDEX<=INDEX_LIMITED-1; INDEX=INDEX+1) begin
//					$display(`DATA_WIDTH_16*INDEX);
//					$fwrite(fd[INDEX],"%d\n", $signed(PACKAGE_OUT[`DATA_WIDTH_16*INDEX +: `DATA_WIDTH_16]));
//				end
//				$fwrite(fd_mode,"%d\n", PREDICTION_MODE);
				SLOT = SLOT+1;
			end
		end
	end
	
end
endmodule
