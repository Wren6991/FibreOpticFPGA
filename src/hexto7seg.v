`timescale 1ns / 1ps

module hexto7seg(
    input [3:0] hex,
    output reg [7:0] sevenseg
    );

/* Segments assigned to 8 bits: abcdefgP  as described below

     < a >
    ^     ^
    f     b
    v     v
     < g >
    ^     ^
    e     c
    v     v
     < d >   (P)
*/

// Bits given in reverse order, Pgfedcba, to match Mimas UCF.
always @ (*) begin
    case (hex)
        4'h0: sevenseg = 8'b00111111;
        4'h1: sevenseg = 8'b00000110;
        4'h2: sevenseg = 8'b01011011;
        4'h3: sevenseg = 8'b01001111;
        4'h4: sevenseg = 8'b01100110;
        4'h5: sevenseg = 8'b01101101;
        4'h6: sevenseg = 8'b01111101;
        4'h7: sevenseg = 8'b00000111;
        4'h8: sevenseg = 8'b01111111;
        4'h9: sevenseg = 8'b01100111;
        4'ha: sevenseg = 8'b01110111;
        4'hb: sevenseg = 8'b01111100;
        4'hc: sevenseg = 8'b00111001;
        4'hd: sevenseg = 8'b01011110;
        4'he: sevenseg = 8'b01111001;
        4'hf: sevenseg = 8'b01110001;
    endcase
end

// Scramble segments to match default assignment from Mimas UCF
/*assign sevenseg = {
	abcdefgP[3], // e
	abcdefgP[4], // d
	abcdefgP[5], // c
	abcdefgP[0], // P
	abcdefgP[6], // b
	abcdefgP[7], // a
	abcdefgP[2], // f
	abcdefgP[1]  // g
};*/


endmodule
