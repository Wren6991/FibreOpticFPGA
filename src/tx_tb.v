`timescale 1ns / 1ps

`define BIT_TIME 100

// Purpose: turn the TX on. Initially, provide no valid data, and observe that it enters the idle state and outputs a correct idle sequence.
// Then provide data and observe that the data is correctly encoded and shifted out onto the line.

module tx_tb;

	// Inputs
	reg clk_bit;
	reg [7:0] d_in;
    reg d_in_valid;
	reg prbs_on;
	reg rst;
    
    integer i;

	// Outputs
	wire out;
    wire clk_word;
    wire idle;
    
	// Instantiate the Unit Under Test (UUT)
	tx uut (
		.clk_bit(clk_bit), 
		.rst(rst),
		.d_in(d_in),
        .d_in_valid(d_in_valid),
		.prbs_on(prbs_on), 
		.out(out),
        .read_enable(clk_word),
        .idle(idle)
	);

    always #(`BIT_TIME/2) clk_bit = ~clk_bit;

	initial begin
		clk_bit = 0;
		d_in = 0;
		prbs_on = 0;
        d_in_valid = 0;
		rst = 1;

		#`BIT_TIME

        rst = 0;
        
        #(`BIT_TIME * 100)
        
        d_in_valid = 1;
        
        for (i = 0; i < 256; i = i + 1) begin
            #(`BIT_TIME * 10);
            d_in = d_in + 1;
        end
    end
      
endmodule

