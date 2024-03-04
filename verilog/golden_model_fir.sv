`timescale 1ns / 1ps
`default_nettype none

module goldenmodel_fir_filter(
    input wire clk,
    input wire reset,
    input wire [15:0] data_in,
    input wire valid_in,
    output reg [15:0] data_out,
    output reg valid_out
);

parameter N = 16; 
parameter M = 31; 

reg signed [15:0] FIR_Coefficients[0:M-1] = {
    16'sd 5, 16'sd 0, 16'sd -17, 16'sd 0, 16'sd 44, 16'sd 0, 16'sd -96, 16'sd 0,
    16'sd 187, 16'sd 0, 16'sd -335, 16'sd 0, 16'sd 565, 16'sd 0, 16'sd -906,
    16'sd 0, 16'sd 1401, 16'sd 0, 16'sd -2112, 16'sd 0, 16'sd 3145, 16'sd 0,
    16'sd -4723, 16'sd 0, 16'sd 7415, 16'sd 0, 16'sd -13331, 16'sd 0, 16'sd 41526,
    16'sd 0, 16'sd 65536 // Assuming the Center_Tap is the last coefficient
};

reg signed [15:0] sample_buffer[M-1:0];
integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < M; i = i + 1) begin
            sample_buffer[i] <= 0;
        end
        data_out <= 0;
        valid_out <= 0;
    end else if (valid_in) begin
        // Shift the buffer and insert new sample
        for (i = M-1; i > 0; i = i - 1) begin
            sample_buffer[i] <= sample_buffer[i-1];
        end
        sample_buffer[0] <= data_in;

        // Perform FIR filtering
        data_out <= 0; // Reset output for accumulation
        for (i = 0; i < M; i = i + 1) begin
            data_out <= data_out + sample_buffer[i] * FIR_Coefficients[i];
        end
        valid_out <= 1; // Output is valid after processing
    end
end

endmodule