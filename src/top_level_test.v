`timescale 1ns / 1ps
    
module top_level(
    input clk_100mhz,
    input clk_12mhz,
    input rx_in,
    output tx_out,
    output clk_recovered,
    output [7:0] LED,
    input [5:0] Switch,
    input [7:0] DPSwitch,
    output [7:0] SevenSegment,
    output [2:0] SevenSegmentEnable
    );
    
    wire clk_sample;
    wire clk_bit_tx;
    wire rst;
    wire scan_clk_7seg;
    reg rx_in_s;
    wire [7:0] rx_d_out;
    reg [7:0] rx_d_out_s;
    wire rx_d_out_valid;
    wire rx_reframe;
    reg reframe_led;
    reg data_led;
    wire fast_blink;
    assign rst = ~Switch[5];
    assign LED[6:5] = {reframe_led, data_led};
    assign LED[4:0] = 4'b0;
    
    pll_tx_clk pll_t(
        .RESET(rst),
        .CLK_IN1(clk_12mhz),
        .CLK_OUT1(clk_bit_tx)
    );
    
    pll_sample_clk pll_s(
        .RESET(rst),
        .CLK_IN1(clk_100mhz),
        .CLK_OUT1(clk_sample)
    );
    
    rx rx(
        .clk_x8(clk_sample),
        .rst(rst),
        .d_in(rx_in_s),
        .clk_recovered(clk_recovered),
        .d_out(rx_d_out),
        .d_out_valid(rx_d_out_valid),
        .reframe(rx_reframe)
     );

    tx tx(
        .clk_bit(clk_bit_tx),
        .rst(rst),
        .prbs_on(1'b0),
        .d_in(DPSwitch),
		  // Push switch to idle
        .d_in_valid(~Switch[4]),
        .out(tx_out)
    );

     blinky #(.width(18)) blink1(
        .clk(clk_sample),
        .rst(rst),
        .out(scan_clk_7seg)
     );

    blinky #(.width(24)) blink2(
        .clk(clk_sample),
        .rst(rst),
        .out(fast_blink)
    );

    // Output 
    sevenseg_controller sseg_ctrl(
        .clk_scan(scan_clk_7seg),
        .rst(rst),
        .value(rx_d_out_s ),
        .sevenseg_enables(SevenSegmentEnable),
        .sevenseg_segments(SevenSegment)
    );

always @ (posedge clk_sample or posedge rst) begin
    if (rst) begin
        rx_d_out_s <= 0;
        rx_in_s <= 0;
    end else begin
        rx_in_s <= rx_in;
        if (rx_d_out_valid) begin
            rx_d_out_s <= rx_d_out;
            data_led <= fast_blink;
            reframe_led <= 0;
        end else if (rx_reframe) begin
            data_led <= 0;
            reframe_led <= fast_blink;
        end
    end
end

endmodule
