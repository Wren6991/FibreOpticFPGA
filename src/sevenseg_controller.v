`timescale 1ns / 1ps

module sevenseg_controller(
    input clk_scan,
    input rst,
    input [11:0] value,
    output [7:0] sevenseg_segments,
    output [2:0] sevenseg_enables
    );

reg [11:0] value_reg;
reg [2:0] sevenseg_enables_reg;
wire [7:0] sevenseg_segments_pos;

assign sevenseg_enables = ~sevenseg_enables_reg;
assign sevenseg_segments = ~sevenseg_segments_pos;

hexto7seg decoder(
	.hex(value_reg[3:0]),
	.sevenseg(sevenseg_segments_pos)
	);

always @ (posedge clk_scan or posedge rst) begin
	if (rst) begin
		sevenseg_enables_reg <= 3'b1;
		value_reg <= 0;
	end else begin
		// rotate the enable bit around
		sevenseg_enables_reg <= {sevenseg_enables_reg[1:0], sevenseg_enables_reg[2]};
		if (sevenseg_enables_reg[2]) begin
			value_reg <= value;
		end else begin
			value_reg <= {4'h0, value_reg[7:4]};
		end
	end
end

endmodule
