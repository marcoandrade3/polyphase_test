`timescale 1ns / 1ps
`default_nettype none

module polyphase_halfband_fir #(
    parameter integer SAMPLE_WIDTH = 16,  
    parameter integer N = 31, 
    parameter integer M = 2,
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

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_counter <= 0;
            data_out <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            
        end
    end 

endmodule