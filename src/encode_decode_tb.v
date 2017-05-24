`timescale 1ns / 1ps

// Purpose: Stick 8b/10b encoder and decoder back to back and input ALL the bytes
// to make sure that we recover the original data after decode!
`define BIT_TIME 100

module encode_decode_tb;

	// Inputs
	reg clk;
	reg nextword_enable;
	reg rst;
	reg idle;
	reg [7:0] d_in;

	// Outputs
	wire [9:0] encode_out;
	wire [7:0] decode_out;
	reg match;

	encode_8b10b uut (
		.clk(clk), 
		.nextword_enable(nextword_enable), 
		.rst(rst), 
		.idle(idle), 
		.d_in(d_in), 
		.d_out(encode_out)
	);
	
	decode_8b10b decoder (
		.d_in(encode_out),
		.d_out(decode_out)
	);
	
    always #(`BIT_TIME / 2) clk = ~clk;

    always begin
        #(`BIT_TIME * 2) 
        d_in = d_in + 1;
    end

    always @ (*) begin
    	match = (decode_out == d_in);
    end
    
	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		d_in = 0;
		idle = 0;
      nextword_enable = 1;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;

		#(`BIT_TIME * 100) $finish;

	end
   
      
endmodule

