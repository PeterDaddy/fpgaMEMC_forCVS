`ifndef __cs_constants__
`define __cs_constants__

// Width-related constants
`define CLOCK_CYCLE 		8
`define ARRAY_ROLLING 	16
`define MODE_WIDTH 		2
`define BIT_SHIFT_WIDTH 3
`define PREDICTED_MODE  3
`define HIERARCHICAL_LEVEL 3
`define DATA_WIDTH_8    8
`define DATA_WIDTH_16   16
`define DATA_WIDTH_32   32
`define DATA_WIDTH_64  	64
`define DATA_WIDTH_256  256
`define REG_BANK_DEPTH  128
`define PACKET_WIDTH    `DATA_WIDTH_8*`REG_BANK_DEPTH
`define ROWS_WIDTH      8
`define COLUMNS_WIDTH   8
`define ADDR_WIDTH   	16

`define UART_DATA_WIDTH 8
`endif