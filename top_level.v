`timescale 1ns / 1ps
    
module top_level(
    input clk_100mhz,
    input clk_12mhz,
    input rst,
    input rx_in,
    output tx_out,
    output clk_recovered,
    output rx_out,
    // User I/O
    input prbs_on
    );
    
    wire clk_sample;
    wire clk_bit_tx;
    
    pll_tx_clk pll_t(
        .CLK_IN1(clk_12mhz),
        .CLK_OUT1(clk_bit_tx)
    );
    
    pll_sample_clk pll_s(
        .CLK_IN1(clk_100mhz),
        .CLK_OUT1(clk_sample)
    );
    
    rx rx(
        .clk_x8(clk_sample),
        .rst(rst),
        .d_in(rx_in),
        .clk_recovered(clk_recovered)
     );
    
    tx tx(
        .clk_bit(clk_bit_tx),
        .rst(rst),
        .prbs_on(prbs_on),
        .out(tx_out)
    );

endmodule
