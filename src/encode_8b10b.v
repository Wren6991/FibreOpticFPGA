`timescale 1ns / 1ps

// Encoder for IBM 8b/10b line coding
// Guarantees DC balance and a max run length of 5 1s/0s.
// Based on information from this article: https://en.wikipedia.org/wiki/8b/10b_encoding
// Combinational case statements are generated with lookup.py

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

always @ (*) begin
	casez ({rd, d_in[4:0]}) 
        6'b000000: b6 = 6'b111001;
        6'b100000: b6 = 6'b000110;
        6'b000001: b6 = 6'b101110;
        6'b100001: b6 = 6'b010001;
        6'b000010: b6 = 6'b101101;
        6'b100010: b6 = 6'b010010;
        6'b?00011: b6 = 6'b100011;
        6'b000100: b6 = 6'b101011;
        6'b100100: b6 = 6'b010100;
        6'b?00101: b6 = 6'b100101;
        6'b?00110: b6 = 6'b100110;
        6'b000111: b6 = 6'b000111;
        6'b100111: b6 = 6'b111000;
        6'b001000: b6 = 6'b100111;
        6'b101000: b6 = 6'b011000;
        6'b?01001: b6 = 6'b101001;
        6'b?01010: b6 = 6'b101010;
        6'b?01011: b6 = 6'b001011;
        6'b?01100: b6 = 6'b101100;
        6'b?01101: b6 = 6'b001101;
        6'b?01110: b6 = 6'b001110;
        6'b001111: b6 = 6'b111010;
        6'b101111: b6 = 6'b000101;
        6'b010000: b6 = 6'b110110;
        6'b110000: b6 = 6'b001001;
        6'b?10001: b6 = 6'b110001;
        6'b?10010: b6 = 6'b110010;
        6'b?10011: b6 = 6'b010011;
        6'b?10100: b6 = 6'b110100;
        6'b?10101: b6 = 6'b010101;
        6'b?10110: b6 = 6'b010110;
        6'b010111: b6 = 6'b010111;
        6'b110111: b6 = 6'b101000;
        6'b011000: b6 = 6'b110011;
        6'b111000: b6 = 6'b001100;
        6'b?11001: b6 = 6'b011001;
        6'b?11010: b6 = 6'b011010;
        6'b011011: b6 = 6'b011011;
        6'b111011: b6 = 6'b100100;
        6'b?11100: b6 = 6'b011100;
        6'b011101: b6 = 6'b011101;
        6'b111101: b6 = 6'b100010;
        6'b011110: b6 = 6'b011110;
        6'b111110: b6 = 6'b100001;
        6'b011111: b6 = 6'b110101;
        6'b111111: b6 = 6'b001010;
	endcase
	
	b6_parity = (b6[5] + b6[4] + b6[3] + b6[2] + b6[1] + b6[0]) == 3;
	  
	// Need to take previous output and running disparity into account
	// for selection of D.x.P7 vs D.x.A7
	casez ({b6[5], rd ^ ~b6_parity, d_in[7:5]})
        5'b?0000: b4 = 4'b1101;
        5'b?1000: b4 = 4'b0010;
        5'b??001: b4 = 4'b1001;
        5'b??010: b4 = 4'b1010;
        5'b?0011: b4 = 4'b0011;
        5'b?1011: b4 = 4'b1100;
        5'b?0100: b4 = 4'b1011;
        5'b?1100: b4 = 4'b0100;
        5'b??101: b4 = 4'b0101;
        5'b??110: b4 = 4'b0110;
        5'b00111: b4 = 4'b0111;
        5'b01111: b4 = 4'b0001;
        5'b10111: b4 = 4'b1110;
        5'b11111: b4 = 4'b1000;
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
			rd <= rd ^ b6_parity ^ b4_parity;
			d_out <= {b4, b6};
		end
	end
end
endmodule
