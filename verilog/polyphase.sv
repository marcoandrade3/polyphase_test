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
    logic [SAMPLE_WIDTH-1:0] MAC_signal_out [TAPS-1:0];
    logic [TAPS-1:0] MAC_valid_out;
    logic [N-1:0] [SAMPLE_WIDTH-1:0] sample_buffer;

    genvar i 
    generate
        for (int i = 0; i < $floor(TAPS / 2); i = i + 1) begin
            // treated differently to handle no past MAC output
            if (i == 0) begin 
                multiply_accumulator multiply_accumulator (
                    .clk(clk),
                    .reset(reset),
                    .valid_in(valid_in)
                    .signal_1(sample_buffer[0]),
                    .signal_2(0),
                    .signal_3(FIR_Coefficients[0]),
                    .signal_4(0),
                    .valid_out(MAC_valid_out[0]),
                    .data_out(MAC_signal_out[0])
                );
            end 
            multiply_accumulator multiply_accumulator (
                .clk(clk),
                .reset(reset),
                .valid_in(MAC_valid_out[2*(i-1)])
                .signal_1(sample_buffer[2*i]),
                .signal_2(0),
                .signal_3(FIR_Coefficients[2*i]),
                .signal_4(MAC_signal_out[2*(i-1)]),
                .valid_out(MAC_signal_out[2*i]),
                .data_out(MAC_signal_out[2*i])
            );
        end
        // if odd, adds the missing one
        if (TAPS % 2 != 0) begin 
            multiply_accumulator multiply_accumulator (
                .clk(clk),
                .reset(reset),
                .valid_in(MAC_valid_out[TAPS - 2])
                .signal_1(sample_buffer[TAPS - 1]),
                .signal_2(0),
                .signal_3(FIR_Coefficients[TAPS - 1]),
                .signal_4(MAC_signal_out[TAPS - 2]),
                .valid_out(MAC_signal_out[TAPS]),
                .data_out(MAC_signal_out[TAPS])
            );
        end 
    endgenerate 

    always_ff @(posedge clk) begin
        if (reset) begin 
            data_out <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            sample_buffer <= {sample_buffer[N-2:0], data_in};
            sample_count <= sample_count + 1;
            if (sample_count > TAPS && MAC_signal_out[TAPS-1]) begin 
                valid_out <= 1;
            end else begin 
                valid_out <= 0;
            end 
        end 
    end


endmodule