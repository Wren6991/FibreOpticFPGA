`timescale 1ns / 1ps

// We oversample the incoming stream by ~8x the bit rate.
// Always sample the data on the 4th clock of every bit period.
// When we detect an edge, we reset the clock counter.
// If the edge appears before the 4th clock, then we have a period of
// <= 3 clocks with no sampling; effectively we have extended the previous
// bit period.
// If the edge appears after the 4th clock, we have already sampled, and
// the reset acts to shorten the current bit period.
// The degree of lateness is also used to adjust the input to a delta-sigma modulator
// which adds or swallows sample pulses to adjust the free-running sampling frequency.

module clock_data_recovery(
    input clk_x8,
    input rst,
    input d_in,
    output reg d_out,
    output reg d_out_valid,
    output reg clk_out
    );

parameter ds_width = 8;
parameter counter_top_default = 7;  // x8 oversampling
    
reg [7:0] history;
reg [3:0] clk_counter;
// Combinational "regs":
reg [3:0] counter_top;
reg [3:0] sample_delay;

reg [ds_width-1:0] ds_acc;
reg [ds_width-1:0] ds_inc;

// Change the top of the sampling counter to add or swallow a pulse
// Depending on the overflow of the delta-sigma, and the sign of the increment
always @ (*) begin
    if (ds_acc[ds_width-1]) begin
        if (ds_inc[ds_width-1])
            counter_top = counter_top_default - 1;
        else
            counter_top = counter_top_default + 1;
    end else begin
        counter_top = counter_top_default;
    end

    // sample_delay = (period - 1) / 2
    sample_delay = counter_top[3:1];
end

always @ (posedge clk_x8 or posedge rst)
    if (rst) begin
        history <= 0;
        clk_counter <= 0;
        d_out <= 0;
        d_out_valid <= 0;
        ds_acc <= 0;
        ds_inc <= 0;
        clk_out <= 0;
    end else begin
        history <= {history[6:0], d_in};
        d_out_valid <= 0; // by default; can override
        
        if (clk_counter == counter_top) begin
            clk_counter <= 0;
            clk_out <= 0;
            // Top bit of counter is not retained for next addition.
            ds_acc <= {0, ds_acc[ds_width-2:0]} + ds_inc;
        end else begin
            if (clk_counter == sample_delay) begin
                clk_out <= 1;
                d_out <= history[0];
                d_out_valid <= 1;
            end
            clk_counter <= clk_counter + 1;
        end
        
        // Detect data transition:
        // Reset counter (adjust phase to match edge) and
        // adjust delta sigma increment (-> average sampling frequency)
        if (d_in ^ history[0]) begin
            clk_counter <= 0;
            clk_out <= 0;
            if (clk_counter < sample_delay) begin
                ds_inc <= ds_inc + clk_counter;
            end else begin
                ds_inc <= ds_inc + (clk_counter - counter_top);
            end
        end

    end
endmodule
