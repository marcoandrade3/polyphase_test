`timescale 1ns / 1ps
`default_nettype none

module multiply_accumulator #(    
    parameter integer SAMPLE_WIDTH = 16,  
    parameter integer N = 31, 
    parameter integer M = 2
)(    
    input wire clk,
    input wire reset,
    input wire[SAMPLE_WIDTH-1:0] signal_1,
    input wire[SAMPLE_WIDTH-1:0] signal_2,
    input wire[SAMPLE_WIDTH-1:0] signal_3,
    input wire[SAMPLE_WIDTH-1:0] signal_4,
    output reg valid_out,
    output reg[SAMPLE_WIDTH-1:0] data_out
);  
    enum {IDLE, FIRST_ADDER, MULTIPLIER, SECOND_ADDER} state;
    logic [SAMPLE_WIDTH-1:0] first_result; 
    logic [SAMPLE_WIDTH-1:0] second_result;
    logic [SAMPLE_WIDTH-1:0] third_result;
    always_ff @(clk)  begin
        if (reset) begin 
            data_out <= 0;
            valid_out <= 0;
            state <= IDLE;
            first_result <= 0;
            second_result <= 0;
            third_result <= 0;
        end else if (valid_in) begin
            case (state)
                IDLE: begin
                    valid_out <= 0;
                    state <= FIRST_ADDER;
                end
                FIRST_ADDER: begin
                    first_result <= signal_1 + signal_2;
                end
                MULTIPLIER: begin
                    second_result <= first_result * signal_3;
                end
                SECOND_ADDER: begin
                    third_result <= second_result + signal_4;
                    data_out <= third_result;
                    valid_out <= 1;
                    state <= IDLE;
                end
            endcase
        end 

    end

endmodule
