`timescale 1ns / 1ps
`default_nettype none

module polyphase_halfband_fir #(
    parameter integer SAMPLE_WIDTH = 6,  
    parameter integer N = 128, 
    parameter integer M = 2,
    parameter integer TAPS = 56,
    parameter signed [15:0] FIR_Coefficients[0:M-1] = {
    16'sd 5, 16'sd 0, 16'sd -17, 16'sd 0, 16'sd 44, 16'sd 0, 16'sd -96, 16'sd 0,
    16'sd 187, 16'sd 0, 16'sd -335, 16'sd 0, 16'sd 565, 16'sd 0, 16'sd -906,
    16'sd 0, 16'sd 1401, 16'sd 0, 16'sd -2112, 16'sd 0, 16'sd 3145, 16'sd 0,
    16'sd -4723, 16'sd 0, 16'sd 7415, 16'sd 0, 16'sd -13331, 16'sd 0, 16'sd 41526,
    16'sd 0, 16'sd 65536
    };
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire [SAMPLE_WIDTH-1:0] data_in, 
    output reg valid_out,
    output reg[SAMPLE_WIDTH-1:0] data_out
);    
    input wire [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_1_array[TAPS-1:0];
    input wire [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_2_array[TAPS-1:0];
    input wire [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_3_array[TAPS-1:0];
    input wire [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_4_array[TAPS-1:0];
    output wire [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_out_array [TAPS-1:0];

    genvar i 
    generate
        for (int i = 0; i < TAPS; i = i + 1) begin
            multiply_accumulator multiply_accumulator_0 (
                .clk(clk),
                .reset(reset),
                .signal_1(multiply_accumulator_signal_1_array[i]),
                .signal_2(multiply_accumulator_signal_2_array[i]),
                .signal_3(multiply_accumulator_signal_3_array[i]),
                .signal_4(multiply_accumulator_signal_4_array[i]),
                .valid_out(valid_out_mul),
                .data_out(multiply_accumulator_signal_out_array[i])
            );
        end
    endgenerate 

    reg [SAMPLE_WIDTH-1:0] sample_buffer[N-1:0];
    state {waiting, setup, ready} state; 

    always_ff @(posedge clk) begin
        if (reset) begin 
            data_out <= 0;
            valid_out <= 0;
            state <= setup;
        end else if (valid_in) begin
            for (i = N-1; i > 0; i = i - 1) begin
                sample_buffer[i] <= sample_buffer[i-1];
            end
            sample_buffer[0] <= data_in;
            sample_count <= sample_count + 1;
            if (state == waiting) begin 
                if (sample_buffer >= TAPS) begin 
                    state <= setup;
                end 
            end else if (state == setup) begin 
                multiply_accumulator_signal_1[sample_count] <= sample_buffer[0]; 
                multiply_accumulator_signal_3[sample_count] <= FIR_Coefficients[sample_count - 1];
                multiply_accumulator_signal_4[sample_count] <= multiply_accumulator_signal_out_array[sample_count - 2];
                valid_out <= 0;
                data_out <= 0;
            end else if (state == ready) begin
                data_out <= multiply_accumulator_signal_out_array[TAPS-1];
                valid_out <= 1;
                state <= waiting;
            end
        end 
    end


endmodule