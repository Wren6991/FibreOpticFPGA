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

`include "txrx_incl.vh"

module tx(
    input clk_bit,
    input rst,
    input [7:0] d_in,
    input d_in_valid,
    input prbs_on,
    output reg out,
    output reg read_enable,
    output reg idle
    );

reg [15:0] lfsr;
reg [3:0] bitcount;
reg encode_enable;
wire [9:0] d_out;

encode_8b10b encoder(
    .clk(clk_bit),
    .nextword_enable(encode_enable),
    .rst(rst),
    .d_in(d_in),
    .idle(idle),
    .d_out(d_out)
    );

always @ (posedge clk_bit or posedge rst) begin
    if (rst) begin
        read_enable <=  0;
        encode_enable <= 0;
        lfsr <= 16'h5678;
        out <= 0;
        bitcount <= 0;
        idle <= 0;
    end else begin
        if (prbs_on) begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            out <= lfsr[0];
        end else begin
            read_enable <=  0;
            encode_enable <= 0;
            if (bitcount == 9) begin
                bitcount <= 0;
            end else begin
                if (bitcount == 8) begin
                    encode_enable <= 1;
                    if (d_in_valid) begin
                        read_enable <= 1;
                        idle <= 0;
                    end else begin
                        idle <= 1;
                    end
                end
                bitcount <= bitcount + 1;
            end
            out <= d_out[bitcount];
        end
    end 
end
endmodule
