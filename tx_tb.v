`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:12:59 05/19/2017
// Design Name:   tx
// Module Name:   C:/Users/Luke/Documents/P2A/GB1 Fibre Optic Project/clock_recovery/tx_tb.v
// Project Name:  clock_recovery
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`define BIT_TIME 100

module tx_tb;

	// Inputs
	reg clk_bit;
	reg [7:0] d_in;
	reg prbs_on;
	reg rst;
    
    integer i;

	// Outputs
	wire out;
    wire clk_word;

	// Instantiate the Unit Under Test (UUT)
	tx uut (
		.clk_bit(clk_bit), 
		.rst(rst),
		.d_in(d_in),
		.prbs_on(prbs_on), 
		.out(out),
        .nextword_enable(clk_word)
	);

    always #(`BIT_TIME/2) clk_bit = ~clk_bit;

	initial begin
		clk_bit = 0;
		d_in = 0;
		prbs_on = 0;
		rst = 1;

		#`BIT_TIME
        
        rst = 0;
        
        for (i = 0; i < 256; i = i + 1) begin
            #(`BIT_TIME * 10);
            d_in = d_in + 1;
        end
    end
      
endmodule

