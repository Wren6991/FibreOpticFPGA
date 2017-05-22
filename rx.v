`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:41:20 05/21/2017 
// Design Name: 
// Module Name:    rx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`include "txrx_incl.vh"

module rx(
    input clk_x8,
    input rst,
    input d_in,
    output reg [7:0] d_out,
    output reg d_out_valid,
    output reg reframe,
    output clk_recovered
    );
    
    wire cdr_d_out;
    wire cdr_d_out_valid;
    
    reg [9:0] bits;
    reg [3:0] bit_counter;
    wire [7:0] decoded_bits;
    
    clock_data_recovery cdr(
        .clk_x8(clk_x8),
        .rst(rst),
        .d_in(d_in),
        .d_out(cdr_d_out),
        .d_out_valid(cdr_d_out_valid),
        .clk_out(clk_recovered)
    );
     
    decode_8b10b decoder(
        .d_in(bits),
        .d_out(decoded_bits)
    );

always @ (posedge clk_x8 or posedge rst) begin
    if (rst) begin
        bits <= 0;
        bit_counter <= 0;
        d_out_valid <= 0;
        reframe <= 0;
    end else if (cdr_d_out_valid) begin
        // default assignments: shift and increment
        bits <= {cdr_d_out, bits[9:1]};
        bit_counter <= bit_counter + 1;
        d_out_valid <= 0;
        reframe <= 0;
        // Commas (K.28.5) are used to idle the line whilst maintaining clock and framing.
        if ((bits == `COMMA_POSTV) || (bits == `COMMA_NEGTV)) begin
            // Reframe. Do not output data.
            bit_counter <= 0;
            reframe <= 1;
        end else if (bit_counter == 9) begin
            bit_counter <= 0;
            d_out_valid <= 1;
            d_out <= decoded_bits;
        end 
    end
end
endmodule
