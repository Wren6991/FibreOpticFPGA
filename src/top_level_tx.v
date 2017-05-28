`timescale 1ns / 1ps

module top_level_tx(
    input clk_100mhz,
    inout [9:0] IO_P2,
    output [15:0] IO_P3,
    output [7:0] LED,
    input [3:0] Switch
 );

    wire clk_bit;
    wire rst;


	wire [7:0] tx_d_in;
	wire [7:0] fifo_d_in;
	wire clk_fifo_wr;
	wire fifo_empty;
	wire fifo_full;
	wire fifo_read_enable;
	wire prbs_on;
	wire prbs_toggle_switch;
	wire tx_idle;
	wire tx_out;
	wire fast_blink;
	reg data_led;
	reg idle_led;
	reg prbs_led;
	 
	assign IO_P2 = {~fifo_full, {9{1'bZ}}};
	assign IO_P3 = tx_out;
	assign LED = {data_led, idle_led, prbs_led, 5'b0};

	assign rst = ~Switch[3];
	assign prbs_toggle_switch = ~Switch[2];
	assign fifo_d_in = IO_P2[7:0];
	assign clk_fifo_wr = IO_P2[8];

    pll_tx_clk pll_t(
    	.RESET(rst),
    	.CLK_IN1(clk_100mhz),
    	.CLK_OUT1(clk_bit)
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

	tx_fifo your_instance_name (
		.rst(rst),
		.wr_clk(clk_fifo_wr),
		.rd_clk(clk_bit),
		.din(fifo_d_in),
		.wr_en(1'b1),
		.rd_en(fifo_read_enable),
		.dout(tx_d_in),
		.full(fifo_full),
		.empty(fifo_empty)
	);

	blinky #(.width(21)) blink(
		.clk(clk_bit),
		.rst(rst),
		.out(fast_blink)
	);

	debounce_toggle toggle(
		.clk(clk_bit),
		.rst(rst),
		.button(prbs_toggle_switch),
		.out(prbs_on)
	);

always @ (posedge rst or posedge clk_bit) begin
	if (rst) begin
		{data_led, idle_led, prbs_led} <= 3'b0;
	end else begin
		if (prbs_on) begin
			{data_led, idle_led, prbs_led} <= {1'b0, 1'b0, fast_blink};
		end else if (tx_idle) begin
			{data_led, idle_led, prbs_led} <= {1'b0, fast_blink, 1'b0};
		end else begin
			{data_led, idle_led, prbs_led} <= {fast_blink, 1'b0, 1'b0};
		end
	end
end

endmodule
