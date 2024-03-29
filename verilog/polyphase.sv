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
        .valid_out(valid_out_mul),
        .data_out(multiply_accumulator_signal_out)
    );

    reg [SAMPLE_WIDTH-1:0] sample_buffer[N-1:0];
    reg [SAMPLE_WIDTH-1:0] sample_count;

    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_1;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_2;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_3;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_4;
    logic [SAMPLE_WIDTH-1:0] multiply_accumulator_signal_out;
    logic [SAMPLE_WIDTH-1:0] last_input_out;
    logic valid_out_mul;

    
    enum {IDLE, MULTIPLY_ACCUMULATE, HANDLE_RESULTS} state;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 0;
            valid_out <= 0;
            state <= IDLE;
            sample_count <= 0;  
        end else if (valid_in) begin
            case (state)
                IDLE: begin 
                    // we only want odd ones
                    if (sample_count % 2 == 1) begin 
                        for (i = N-1; i > 0; i = i - 1) begin
                            sample_buffer[i] <= sample_buffer[i-1];
                        end
                        sample_buffer[0] <= data_in;
                        multiply_accumulator_signal_1 <= data_in; 
                        multiply_accumulator_signal_3 <= FIR_Coefficients[sample_count];
                        multiply_accumulator_signal_4 <= last_input_out;
                        state <= MULTIPLY_ACCUMULATE;
                    end 
                    valid_out <= 0;
                    data_out <= 0;
                    sample_count <= sample_count + 1;
                end
                MULTIPLY_ACCUMULATE: begin 
                    if (valid_out_mul) begin 
                        state <= HANDLE_RESULTS;
                    end 
                end 
                HANDLE_RESULTS: begin 
                    state <= IDLE;
                    if (sample_count == TAPS) begin
                        data_out <= multiply_accumulator_signal_out;
                        last_input_out <= 0;
                        sample_count <= sample_count - 1;
                        valid_out <= 1;
                    end else begin 
                        last_input_out <= multiply_accumulator_signal_out;
                    end
                end
            endcase 
        end
    end 

endmodule