`timescale 1ns / 1ps

// Purpose: connect an idle TX to a listening RX.
// Should observe that TX enters idle state and transmits comma sequences with correct running disparity
// and that RX recovers clock and framing, and does not output any data.

`define BIT_TIME 100

module link_idle_tb;

	// Inputs
	reg clk_x8;
	reg rst;
	wire rx_in;
    
    reg clk_tx;
    reg tx_din_valid;
    reg [7:0] tx_din;

	// Outputs
	wire [7:0] d_out;
	wire d_out_valid;
	wire reframe;
	wire clk_recovered;
	wire not_clk_recovered;
	
	assign not_clk_recovered = ~clk_recovered;
    
    wire tx_read_enable;
    wire tx_idle;


    integer i;
    
	// Instantiate the Unit Under Test (UUT)
	rx rx (
		.clk_x8(clk_x8), 
		.rst(rst), 
		.d_in(rx_in), 
		.d_out(d_out), 
		.d_out_valid(d_out_valid), 
		.reframe(reframe), 
		.clk_recovered(clk_recovered)
	);
    
    tx tx(
        .clk_bit(clk_tx),
        .rst(rst),
        .d_in(tx_din),
        .d_in_valid(tx_din_valid),
        .prbs_on(0),
        .out(rx_in),
        .read_enable(tx_read_enable),
        .idle(tx_idle)
    );

    always #(`BIT_TIME / 16 * 1.05) clk_x8 = ~clk_x8;
    always #(`BIT_TIME / 2) clk_tx = ~clk_tx;
    
	initial begin
		// Initialize Inputs
		clk_x8 = 0;
        clk_tx = 0;
        tx_din = 0;
        tx_din_valid = 0;
        i = 0;
        rst = 1;

		#(`BIT_TIME * 20)
        
        rst = 0;
        
        #(`BIT_TIME * 50)
        
        tx_din_valid = 1;
        
        for (i = 0; i < 256; i = i + 1) begin
            #(`BIT_TIME * 10);
            tx_din = tx_din + 1;
        end

        $finish;

	end
      
endmodule

