`timescale 1ns / 1ps
    
module top_level(
    input clk_100mhz_in,
    inout [7:0] IO_P9,
    output [7:0] IO_P8,
    inout [7:0] IO_P7,
    output [7:0] LED,
    input [5:0] Switch,
    output [7:0] SevenSegment,
    output [2:0] SevenSegmentEnable
    );
    
    wire clk_sample;
    wire clk_100mhz;
    wire clk_7seg_scan;
    wire rst;
    wire rx_in;
    wire rx_d_out_valid;
    wire rx_reframe;
    wire [7:0] rx_d_out;
    wire fast_blink;
    wire fifo_below_min;
    wire clk_external;
    wire [7:0] fifo_d_out;

    reg rx_in_s;
    reg clk_external_s;
    reg clk_external_s_prev;
    reg reframe_led;
    reg data_led;
    reg [7:0] last_rx_data;

    // IO Outputs
    assign rst = ~Switch[5];
    assign LED[7:6] = {reframe_led, data_led};
    assign LED[5:0] = 6'b0;
    assign IO_P9 = {clk_recovered, {7{1'bZ}}};
    assign IO_P8 = fifo_d_out;
    assign IO_P7 = {1'bZ, ~fifo_below_min, {6{1'bZ}}};

    // IO Inputs
    assign rx_in = IO_P9[5];
    assign clk_external = IO_P7[5];
    
    pll_sample_clk pll_s(
        .RESET(rst),
        .CLK_IN1(clk_100mhz_in),
        .CLK_OUT1(clk_sample),
        .CLK_OUT2(clk_100mhz)
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

    // The FIFO must be continuously clocked on the read side to ensure
    // the DREQ signal is updated. The rising edge of the "clock" from the Pi
    // is then synchronously detected and used as a write enable pulse.
    rx_fifo fifo (
        .rst(rst),
        .wr_clk(clk_sample),
        .rd_clk(clk_100mhz),
        .din(rx_d_out),
        .wr_en(rx_d_out_valid),
        .rd_en(clk_external_s && !clk_external_s_prev),
        .dout(fifo_d_out),
        .full(),
        .empty(),
        .prog_empty(fifo_below_min)
    );

    blinky #(.width(24)) blink1(
        .clk(clk_sample),
        .rst(rst),
        .out(fast_blink)
    );

    blinky #(.width(18)) blink2(
        .clk(clk_sample),
        .rst(rst),
        .out(clk_7seg_scan)
    );

    sevenseg_controller sseg_ctrl(
        .clk_scan(clk_7seg_scan),
        .rst(rst),
        .value({4'b0, last_rx_data}),
        .sevenseg_enables(SevenSegmentEnable),
        .sevenseg_segments(SevenSegment)
    );

always @ (posedge clk_sample or posedge rst) begin
    if (rst) begin
        rx_in_s <= 0;
        last_rx_data <= 0;
    end else begin
        rx_in_s <= rx_in;
        if (rx_d_out_valid) begin
            last_rx_data <= rx_d_out;
            data_led <= fast_blink;
            reframe_led <= 0;
        end else if (rx_reframe) begin
            data_led <= 0;
            reframe_led <= fast_blink;
        end
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
