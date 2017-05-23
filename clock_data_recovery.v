`timescale 1ns / 1ps

// We oversample the incoming stream by ~8x the bit rate.
// Always sample the data on the 4th clock of every bit period.
// When we detect an edge, we reset the clock counter.
// If the edge appears before the 4th clock, then we have a period of
// <= 3 clocks with no sampling; effectively we have extended the previous
// bit period.
// If the edge appears after the 4th clock, we have already sampled, and
// the reset acts to shorten the current bit period.

module clock_data_recovery(
    input clk_x8,
    input rst,
    input d_in,
    output reg d_out,
    output reg d_out_valid,
    output reg clk_out
    );
    
reg [7:0] history;
reg [2:0] clk_counter;

always @ (posedge clk_x8 or posedge rst)
    if (rst) begin
        history <= 0;
        clk_counter <= 0;
        d_out <= 0;
        d_out_valid <= 0;
        clk_out <= 0;
    end else begin
        history <= {history[6:0], d_in};
        d_out_valid <= 0; // by default; can override
        
        if (clk_counter == 7) begin
            clk_counter <= 0;
            clk_out <= 0;
        end else begin
            if (clk_counter == 3) begin
                clk_out <= 1;
                d_out <= history[0];
                d_out_valid <= 1;
            end
            clk_counter <= clk_counter + 1;
        end
        
        // Detect data transition
        if (d_in ^ history[0]) begin
            clk_counter <= 0;
            clk_out <= 0;
        end
    end
endmodule
