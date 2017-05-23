`timescale 1ns / 1ps

`define BIT_TIME 100

// Purpose: input an alternating signal into the CDR
// with a 5% bitrate mismatch. Ensure correct recovery.

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

