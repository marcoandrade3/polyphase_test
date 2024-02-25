`timescale 1ns / 1ps
`default_nettype none

module goldenmodel_fir_filter(
    input wire sampling_rate;
    input wire reset;
    input wire [15:0] data_in;
    input wire valid_in;
    output wire [15:0] data_out;
    output wire valid_out;
);
    
    parameter N = 16; // Size of input signal
    parameter M = 31; // Size of filter

    // defines coefficient
    reg signed [15:0] FIR_Coefficients[1:2][31:0] = {
    { 16'sd 5, 16'sd 0, 16'sd -17, 16'sd 0, 16'sd 44, 16'sd 0, 16'sd -96, 16'sd 0,
      16'sd 187, 16'sd 0, 16'sd -335, 16'sd 0, 16'sd 565, 16'sd 0, 16'sd -906,
      16'sd 0, 16'sd 1401, 16'sd 0, 16'sd -2112, 16'sd 0, 16'sd 3145, 16'sd 0,
      16'sd -4723, 16'sd 0, 16'sd 7415, 16'sd 0, 16'sd -13331, 16'sd 0, 16'sd 41526 },
    { 16'sd 5, 16'sd 0, 16'sd -17, 16'sd 0, 16'sd 44, 16'sd 0, 16'sd -96, 16'sd 0,
      16'sd 187, 16'sd 0, 16'sd -335, 16'sd 0, 16'sd 565, 16'sd 0, 16'sd -906,
      16'sd 0, 16'sd 1401, 16'sd 0, 16'sd -2112, 16'sd 0, 16'sd 3145, 16'sd 0,
      16'sd -4723, 16'sd 0, 16'sd 7415, 16'sd 0, 16'sd -13331, 16'sd 0, 16'sd 41526 }
    };

    parameter signed [15:0] Center_Tap = 16'sd 65536;

    // Local variables
    logic [15:0] temp[N+M-1];
    integer i, j;

    // Initialize temporary variable
    initial begin
        for (i = 0; i < N+M-1; i = i + 1) begin
            temp[i] = 16'b0; // Initialize to zero
        end
    end

    // Convolution computation
    always_comb begin
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < M; j = j + 1) begin
                temp[i+j] = temp[i+j] + data_in[i] * FIR_Coefficients[j];
            end
        end
    end

    // Assign convolution result to output signal
    always_ff @(posedge clk or posedge rst) begin
        if (reset) begin
            for (i = 0; i < N+M-1; i = i + 1) begin
                data_out[i] <= 16'b0; // Reset to zero on reset
            end
        end else begin
            for (i = 0; i < N+M-1; i = i + 1) begin
                data_out[i] <= temp[i];
            end
            if $size(data_out) == 16 begin 
                valid_out <= 1;
            end 
        end
    end

endmodule

`default_nettype wire