`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:39:35 05/26/2017 
// Design Name: 
// Module Name:    blinky 
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
module blinky(
    input clk,
    input rst,
    output out
    );
 
parameter width = 32;

reg [width - 1 : 0] counter;
assign out = counter[width - 1];

always @ (posedge clk or posedge rst) begin
	if (rst) begin
		counter <= 0;
	end else begin
		counter <= counter + 1'b1;
	end
end

endmodule
