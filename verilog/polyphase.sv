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
    input logic clk,
    input logic reset,
    input logic valid_in,
    input logic [SAMPLE_WIDTH-1:0] data_in, 
    output logic valid_out,
    output logic[SAMPLE_WIDTH-1:0] data_out
);    
    logic [SAMPLE_WIDTH-1:0] MAC_signal_1 [TAPS-1:0];
    logic [SAMPLE_WIDTH-1:0] MAC_signal_2 [TAPS-1:0];
    logic [SAMPLE_WIDTH-1:0] MAC_signal_3 [TAPS-1:0];
    logic [SAMPLE_WIDTH-1:0] MAC_signal_4 [TAPS-1:0];
    logic [SAMPLE_WIDTH-1:0] MAC_signal_out [TAPS-1:0];
    logic [TAPS-1:0] MAC_valid_out;
    logic [TAPS-1:0] MAC_valid_in;

    genvar i 
    generate
        for (int i = 0; i < TAPS; i = i + 1) begin
            if (i == 0) begin 
                multiply_accumulator multiply_accumulator_0 (
                    .clk(clk),
                    .reset(reset),
                    .signal_1(MAC_signal_1[0]),
                    .signal_2(0),
                    .signal_3(FIR_Coefficients[0]),
                    .signal_4(0),
                    .valid_out(valid_out_mul),
                    .data_out(multiply_accumulator_signal_out_array[i])
                );
            end 
            multiply_accumulator multiply_accumulator_0 (
                .clk(clk),
                .reset(reset),
                .signal_1(MAC_signal_1[i]),
                .signal_2(0),
                .signal_3(FIR_Coefficients[i]),
                .signal_4(MAC_signal_out[i-1]),
                .valid_out(valid_out_mul),
                .data_out(MAC_signal_out[i])
            );
        end
    endgenerate 

    logic [N-1:0] [SAMPLE_WIDTH-1:0] sample_buffer;

    always_ff @(posedge clk) begin
        if (reset) begin 
            data_out <= 0;
            valid_out <= 0;
            state <= setup;
        end else if (valid_in) begin
            sample_buffer <= {sample_buffer[N-2:0], data_in};
            sample_count <= sample_count + 1;
            if (sample_count > TAPS) begin 
                
        end 
    end


endmodule