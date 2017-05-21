`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:46:52 05/19/2017 
// Design Name: 
// Module Name:    tx 
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
module tx(
    input clk_bit,
    input rst,
    input [7:0] d_in,
    input prbs_on,
    output reg out,
    output reg nextword_enable
    );

reg [15:0] lfsr;
reg [3:0] bitcount;
wire [9:0] d_out;

encode_8b10b encoder(
    .clk(clk_bit),
    .nextword_enable(nextword_enable),
    .rst(rst),
    .d_in(d_in),
    .d_out(d_out)
    );

always @ (posedge clk_bit or posedge rst) begin
    if (rst) begin
        nextword_enable <=  0;
        lfsr <= 16'h5678;
        out <= 0;
        bitcount <= 0;
    end else begin
        if (prbs_on) begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            out <= lfsr[0];
        end else begin
            nextword_enable <=  0;
            if (bitcount == 9) begin
                bitcount <= 0;
            end else begin
                if (bitcount == 8) begin
                    nextword_enable <= 1;
                end
                bitcount <= bitcount + 1;
            end
            out <= d_out[bitcount];
        end
    end 
end
endmodule
