// Purpose: toggle the output once, each time the input is high for at least a certain number of cycles.
module debounce_toggle(
	input clk,
	input rst,
	input button,
	output reg out
	);

parameter counter_width = 18;

reg [counter_width-1:0] counter;

always @ (posedge rst or posedge clk) begin
	if (rst) begin
		counter <= 0;
		out <= 0;
	end else begin
		if (button) begin
			if (counter == {counter_width{1'b1}}) begin
				// do nothing!
			end else if (counter == {counter_width{1'b1}} - 1) begin
				counter <= counter + 1'b1;
				out <= ~out;
			end else begin
				counter <= counter + 1'b1;
			end
		end else begin
			counter <= 0;
		end
	end
end
endmodule
