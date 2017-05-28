`timescale 1ns / 1ps

module top_level_tx(
    input clk_100mhz_in,
    inout [9:0] IO_P2,
    output [0:0] IO_P3,
    output [7:0] LED,
    input [3:0] Switch
 );

    wire clk_bit;
    wire clk_100mhz;
    wire rst;

	wire [7:0] tx_d_in;
	wire [7:0] fifo_d_in;
	wire fifo_empty;
	wire fifo_full;
	wire fifo_read_enable;
	wire prbs_on;
	wire led_mode;
	wire prbs_toggle_switch;
	wire tx_idle;
	wire tx_out;
	wire fast_blink;
	reg data_led;
	reg idle_led;
	reg prbs_led;
	reg clk_external_s;
	reg clk_external_s_prev;
	reg [7:0] leds;
	
	assign IO_P2 = {~fifo_full, {9{1'bZ}}};
	assign IO_P3 = tx_out;
	//assign LED = {data_led, idle_led, prbs_led, 5'b0};
	assign LED = leds;
	assign rst = ~Switch[3];
	assign prbs_toggle_switch = ~Switch[2];
	assign fifo_d_in = IO_P2[7:0];
	assign clk_external = IO_P2[8];

    pll_tx_clk pll_t(
    	.RESET(rst),
    	.CLK_IN1(clk_100mhz_in),
    	.CLK_OUT1(clk_bit),
    	.CLK_OUT2(clk_100mhz)
    );

	tx inst_tx(
		.clk_bit     (clk_bit),
		.rst         (rst),
		.d_in        (tx_d_in),
		.d_in_valid  (~fifo_empty),
		.prbs_on     (prbs_on),
		.out         (tx_out),
		.read_enable (fifo_read_enable),
		.idle        (tx_idle)
	);

	// The FIFO must be continuously clocked on the write side to ensure
	// the "full" signal is updated. The rising edge of the "clock" from the Pi
	// is then synchronously detected and used as a write enable pulse.
	tx_fifo fifo (
		.rst(rst),
		.wr_clk(clk_100mhz),
		.rd_clk(clk_bit),
		.din(fifo_d_in),
		.wr_en(clk_external_s && !clk_external_s_prev),
		.rd_en(fifo_read_enable),
		.dout(tx_d_in),
		.full(),
		.prog_full(fifo_full),	
		.empty(fifo_empty)
	);

	blinky #(.width(21)) blink(
		.clk(clk_bit),
		.rst(rst),
		.out(fast_blink)
	);

	debounce_toggle prbs_toggle(
		.clk(clk_bit),
		.rst(rst),
		.button(prbs_toggle_switch),
		.out(prbs_on)
	);

	debounce_toggle led_toggle(
		.clk(clk_bit),
		.rst(rst),
		.button(~Switch[1]),
		.out(led_mode)
	);

always @ (posedge rst or posedge clk_bit) begin
	if (rst) begin
		{data_led, idle_led, prbs_led} <= 3'b0;
	end else if (led_mode == 0) begin
		if (prbs_on) begin
			leds <= {1'b0, 1'b0, fast_blink, 5'b0};
		end else if (tx_idle) begin
			leds <= {1'b0, fast_blink, 1'b0, 5'b0};
		end else begin
			leds <= {fast_blink, 1'b0, 1'b0, 5'b0};
		end
	end else if (fifo_read_enable) begin
		leds <= tx_d_in;
	end
end

always @ (posedge rst or posedge clk_100mhz) begin
	if (rst) begin
		{clk_external_s, clk_external_s_prev} <= 2'b0;
	end else begin
		clk_external_s <= clk_external;
		clk_external_s_prev <= clk_external_s;
	end
end

endmodule
