`timescale 1ns / 1ps

// Encoder for IBM 8b/10b line coding
// Guarantees DC balance and a max run length of 5 1s/0s.
// Based on information from this article: https://en.wikipedia.org/wiki/8b/10b_encoding

`include "txrx_incl.vh"

module encode_8b10b(
    input clk,
    input nextword_enable,
    input rst,
    input idle,
    input [7:0] d_in,
    output reg [9:0] d_out
    );

    reg rd;
    // Combinationally calculate the codewords *without* disparity correction
    reg [5:0] b6;
    reg [3:0] b4;
    // Whether b6/b4 has a balance of ones and zeroes
    reg b6_parity;
    reg b4_parity;

always @ (d_in) begin
    case (d_in[4:0]) 
        5'b00000: b6 = 6'b100111;
        5'b00001: b6 = 6'b011101;
        5'b00010: b6 = 6'b101101;
        5'b00011: b6 = 6'b110001;
        5'b00100: b6 = 6'b110101;
        5'b00101: b6 = 6'b101001;
        5'b00110: b6 = 6'b011001;
        5'b00111: b6 = 6'b111000;
        5'b01000: b6 = 6'b111001;
        5'b01001: b6 = 6'b100101;
        5'b01010: b6 = 6'b010101;
        5'b01011: b6 = 6'b110100;
        5'b01100: b6 = 6'b001101;
        5'b01101: b6 = 6'b101100;
        5'b01110: b6 = 6'b011100;
        5'b01111: b6 = 6'b010111;
        5'b10000: b6 = 6'b011011;
        5'b10001: b6 = 6'b100011;
        5'b10010: b6 = 6'b010011;
        5'b10011: b6 = 6'b110010;
        5'b10100: b6 = 6'b001011;
        5'b10101: b6 = 6'b101010;
        5'b10110: b6 = 6'b011010;
        5'b10111: b6 = 6'b111010;
        5'b11000: b6 = 6'b110011;
        5'b11001: b6 = 6'b100110;
        5'b11010: b6 = 6'b010110;
        5'b11011: b6 = 6'b110110;
        5'b11100: b6 = 6'b001110;
        5'b11101: b6 = 6'b101110;
        5'b11110: b6 = 6'b011110;
        5'b11111: b6 = 6'b101011;
        5'b11100: b6 = 6'b001111;
    endcase
    
    b6_parity = (b6[5] + b6[4] + b6[3] + b6[2] + b6[1] + b6[0]) == 3;
      
    // Need to take previous output and running disparity into account
    // for selection of D.x.P7 vs D.x.A7
    casez ({d_out[0], rd, d_in[7:5]})
        5'b??000: b4 = 4'b1011;
        5'b??001: b4 = 4'b1001;
        5'b??010: b4 = 4'b0101;
        5'b??011: b4 = 4'b1100;
        5'b??100: b4 = 4'b1101;
        5'b??101: b4 = 4'b1010;
        5'b??110: b4 = 4'b0110;
        5'b00111: b4 = 4'b1110;
        5'b01111: b4 = 4'b0111;
        5'b10111: b4 = 4'b1110;
        5'b11111: b4 = 4'b0111;
    endcase
    
    b4_parity = (b4[3] + b4[2] + b4[1] + b4[0]) == 2;
end

reg b6_invert, b4_invert;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rd <= 0;
        d_out <= 0;
    end else if (nextword_enable) begin
        if (idle) begin
            d_out <= rd ? `COMMA_NEGTV : `COMMA_POSTV;
            rd <= ~rd;
        end else begin
            // Decide which codewords *need* inversion to maintain DC balance
            case ({rd, b6_parity, b4_parity})
                3'b000: {b6_invert, b4_invert} = 2'b01;
                3'b001: {b6_invert, b4_invert} = 2'b00;
                3'b010: {b6_invert, b4_invert} = 2'b00;
                3'b011: {b6_invert, b4_invert} = 2'b00;
                3'b100: {b6_invert, b4_invert} = 2'b10;
                3'b101: {b6_invert, b4_invert} = 2'b10;
                3'b110: {b6_invert, b4_invert} = 2'b01;
                3'b111: {b6_invert, b4_invert} = 2'b00;
            endcase
            
            rd <= rd ^ b6_parity ^ b4_parity;
            
            // Also consider special cases which are inverted to guarantee run-length
            d_out <= {
                (b4_invert | ((d_in[7:5] == 3) & rd)) ? ~b4 : b4,
                (b6_invert | ((d_in[4:0] == 7) & rd)) ? ~b6 : b6
            };
        end
    end
end
endmodule
