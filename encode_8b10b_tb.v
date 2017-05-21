`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:41:37 05/19/2017
// Design Name:   encode_8b10b
// Module Name:   C:/Users/Luke/Documents/P2A/GB1 Fibre Optic Project/clock_recovery/encode_8b10b_tb.v
// Project Name:  clock_recovery
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: encode_8b10b
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module encode_8b10b_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [7:0] d_in;

	// Outputs
	wire [9:0] d_out;

	// Instantiate the Unit Under Test (UUT)
	encode_8b10b uut (
		.clk(clk), 
		.rst(rst), 
		.d_in(d_in), 
		.d_out(d_out)
	);

    always #100 clk = ~clk;

    always #2000 d_in = d_in + 1;

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		d_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
        rst = 0;
        
		// Add stimulus here

	end
      
endmodule

