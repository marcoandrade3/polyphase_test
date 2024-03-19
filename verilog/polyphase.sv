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
    input wire[SAMPLE_WIDTH-1:0] data_in, 
    output reg valid_out,
    output reg[SAMPLE_WIDTH-1:0] data_out
);    

    multiply_accumulator multiply_accumulator_0 (
        .clk(clk),
        .reset(reset),
        .signal_1(multiply_accumulator_signal_1),
        .signal_2(multiply_accumulator_signal_2),
        .signal_3(multiply_accumulator_signal_3),
        .signal_4(multiply_accumulator_signal_4),
        .valid_out(valid_out),
        .data_out(multiply_accumulator_signal_out)
    );

    reg [SAMPLE_WIDTH-1:0] sample_buffer[N-1:0];
    reg [SAMPLE_WIDTH-1:0] sample_count;

    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_1;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_2;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_3;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_4;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_out;

    // out[0] = h[0] * in[0] + h[2] * x[-2] + h[4] * x[-4] + h[6] * x[-6] + h[8] * x[-8] + h[10] * x[-10] + h[12] * x[-12] + h[14] * x[-14] + h[16] * x[-16] + h[18] * x[-18] + h[20] * x[-20] + h[22] * x[-22] + h[24] * x[-24] + h[26] * x[-26] + h[28] * x[-28] + h[30] * x[-30] + h[32] * x[-32] + h[34] * x[-34] + h[36] * x[-36] + h[38] * x[-38] + h[40] * x[-40] + h[42] * x[-42] + h[44] * x[-44] + h[46] * x[-46] + h[48] * x[-48] + h[50] * x[-50] + h[52] * x[-52] + h[54] * x[-54] + h[56] * x[-56]    
    // out[1] = h[0] * in[2] + h[2] * x[0] + h[4] * x[-2] + h[6] * x[-4] + h[8] * x[-6] + h[10] * x[-8] + h[12] * x[-10] + h[14] * x[-12] + h[16] * x[-14] + h[18] * x[-16] + h[20] * x[-18] + h[22] * x[-20] + h[24] * x[-22] + h[26] * x[-24] + h[28] * x[-26] + h[30] * x[-28] + h[32] * x[-30] + h[34] * x[-32] + h[36] * x[-34] + h[38] * x[-36] + h[40] * x[-38] + h[42] * x[-40] + h[44] * x[-42] + h[46] * x[-44] + h[48] * x[-46] + h[50] * x[-48] + h[52] * x[-50] + h[54] * x[-52] + h[56] * x[-54] + h[58] * x[-56]
    // out[2] = h[0] * in[4] + h[2] * x[2] + h[4] * x[0] + h[6] * x[-2] + h[8] * x[-4] + h[10] * x[-6] + h[12] * x[-8] + h[14] * x[-10] + h[16] * x[-12] + h[18] * x[-14] + h[20] * x[-16] + h[22] * x[-18] + h[24] * x[-20] + h[26] * x[-22] + h[28] * x[-24] + h[30] * x[-26] + h[32] * x[-28] + h[34] * x[-30] + h[36] * x[-32] + h[38] * x[-34] + h[40] * x[-36] + h[42] * x[-38] + h[44] * x[-40] + h[46] * x[-42] + h[48] * x[-44] + h[50] * x[-46] + h[52] * x[-48] + h[54] * x[-50] + h[56] * x[-52] + h[58] * x[-54] + h[60] * x[-56]

    // using multiply accumulator, calculates each of these. 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_counter <= 0;
            data_out <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            for (i = N-1; i > 0; i = i - 1) begin
                sample_buffer[i] <= sample_buffer[i-1];
            end
            sample_buffer[0] <= data_in;

            multiply_accumulator_signal_1 <= data_in; 
            multiply_accumulator_signal_3 <= FIR_Coefficients[sample_count];
            multiply_accumulator_signal_4 <= multiply_accumulator_signal_out;

            if (sample_count == TAPS) begin
                data_out <= multiply_accumulator_signal_out;
                multiply_accumulator_signal_1 <= 0;
                multiply_accumulator_signal_3 <= 0;
                multiply_accumulator_signal_4 <= 0;
                sample_count <= 0;
                valid_out <= 1;
            end else begin 
                sample_count <= sample_count + 1;
            end
        end
    end 

endmodule