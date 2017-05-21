`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:13:45 05/20/2017
// Design Name:   clock_data_recovery
// Module Name:   C:/Users/Luke/Documents/P2A/GB1 Fibre Optic Project/clock_recovery/clock_data_recovery_tb.v
// Project Name:  clock_recovery
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: clock_data_recovery
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`define BIT_TIME 100

module clock_data_recovery_tb;

	// Inputs
	reg clk_x8;
	reg rst;
	reg d_in;

	// Outputs
	wire d_out;
	wire d_out_valid;
	wire clk_out;

	// Instantiate the Unit Under Test (UUT)
	clock_data_recovery uut (
		.clk_x8(clk_x8), 
		.rst(rst), 
		.d_in(d_in), 
		.d_out(d_out), 
		.d_out_valid(d_out_valid), 
		.clk_out(clk_out)
	);
    
    always #(`BIT_TIME / 16) clk_x8 = ~clk_x8;
    
    always #(`BIT_TIME * 1.05) d_in = ~d_in;

	initial begin
		// Initialize Inputs
		clk_x8 = 0;
		rst = 1;
		d_in = 0;

		// Wait 100 ns for global reset to finish
		#`BIT_TIME;
        
		rst = 0;

	end
      
endmodule

