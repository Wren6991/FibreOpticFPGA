`timescale 1ns / 1ps
    
module top_level(
    input clk_100mhz,
    inout [7:0] IO_P9,
    output [7:0] IO_P8,
    inout [7:0] IO_P7,
    output [7:0] LED,
    input [5:0] Switch
    );
    
    wire clk_sample;
    wire rst;
    wire rx_in;
    wire rx_d_out_valid;
    wire rx_reframe;
    wire [7:0] rx_d_out;
    wire fast_blink;
    wire fifo_empty;
    wire clk_fifo_rd;
    wire fifo_d_out;

    reg rx_in_s;
    reg reframe_led;
    reg data_led;
    // IO Outputs
    assign rst = ~Switch[5];
    assign LED[7:6] = {reframe_led, data_led};
    assign LED[5:0] = 6'b0;
    assign IO_P9 = {clk_recovered, {7{1'bZ}}};
    assign IO_P8 = fifo_d_out;
    assign IO_P7 = {1'bZ, fifo_empty, {6{1'bZ}}};

    // IO Inputs
    assign rx_in = IO_P9[5];
    assign clk_fifo_rd = IO_P7[5];
    
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

    rx_fifo fifo (
        .rst(rst),
        .wr_clk(clk_sample),
        .rd_clk(clk_fifo_rd),
        .din(rx_d_out),
        .wr_en(rx_d_out_valid),
        .rd_en(1),
        .dout(fifo_d_out),
        .empty(fifo_empty)
    );

    blinky #(.width(24)) blink1(
        .clk(clk_sample),
        .rst(rst),
        .out(fast_blink)
    );

always @ (posedge clk_sample or posedge rst) begin
    if (rst) begin
        rx_in_s <= 0;
    end else begin
        rx_in_s <= rx_in;
        if (rx_d_out_valid) begin
            data_led <= fast_blink;
            reframe_led <= 0;
        end else if (rx_reframe) begin
            data_led <= 0;
            reframe_led <= fast_blink;
        end
    end
end

endmodule
