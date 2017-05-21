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

`define BIT_TIME 100

module encode_8b10b_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [7:0] d_in;
    reg nextword_enable;

	// Outputs
	wire [9:0] d_out;

	// Instantiate the Unit Under Test (UUT)
	encode_8b10b uut (
		.clk(clk), 
		.rst(rst), 
		.d_in(d_in), 
		.d_out(d_out),
        .nextword_enable(nextword_enable)
	);

    always #(`BIT_TIME / 2) clk = ~clk;

    always begin
        #(`BIT_TIME * 9) 
        d_in = d_in + 1;
        nextword_enable <= 1;
        #`BIT_TIME
        nextword_enable <= 0;
    end
    
	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		d_in = 0;
        nextword_enable = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
        rst = 0;
        
		// Add stimulus here

	end
      
endmodule

