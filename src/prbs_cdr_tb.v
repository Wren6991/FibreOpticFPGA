`timescale 1ns / 1ps

`define BIT_TIME 100

// Input a pseudorandom sequence into the CDR unit, with a 5% clock rate mismatch.
// Check that the CDR can correctly recover the clock and the data sequence.
// The output clock should be in antiphase with the original data clock (sample on rising edge, => 
// rising edge halfway between data transitions => halfway between TX clk rising edges)

module prbs_cdr_tb;

	// Inputs
	reg clk_x8;
	reg rst;

	// Outputs
	wire d_out;
	wire d_out_valid;
	wire clk_out;
	wire nclk_out;
	assign nclk_out = ~clk_out;
    
    reg clk_bit;
	wire tx_out;

	// Instantiate the Unit Under Test (UUT)
	clock_data_recovery uut (
		.clk_x8(clk_x8), 
		.rst(rst), 
		.d_in(tx_out), 
		.d_out(d_out), 
		.d_out_valid(d_out_valid), 
		.clk_out(clk_out)
	);
    
    // Instantiate the TX half
    
	tx test_tx (
		.clk_bit(clk_bit), 
		.rst(rst),
		.d_in(0),
		.prbs_on(1), 
		.out(tx_out)
	);
    
    
    always #(`BIT_TIME / 16) clk_x8 = ~clk_x8;
    always #(`BIT_TIME / 2 * 1.05) clk_bit = ~clk_bit;
    

	initial begin
		// Initialize Inputs
		clk_x8 = 0;
        clk_bit = 0;
		rst = 1;
		// Wait 100 ns for global reset to finish
		// Wait 100 ns for global reset to finish
		// Wait 100 ns for global reset to finish
		#`BIT_TIME;
        
        rst = 0;
		// Add stimulus here

	end
      
endmodule

