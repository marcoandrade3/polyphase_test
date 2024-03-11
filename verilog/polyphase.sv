`timescale 1ns / 1ps
`default_nettype none

module polyphase_halfband_fir #(
    parameter integer SAMPLE_WIDTH = 16,  // Bit width of samples
    parameter integer N = 31,  // Total number of taps in the FIR filter, should be odd
    parameter integer M = 2    // Decimation factor, fixed to 2 for half-band FIR
)(
    input wire clk,
    input wire reset,
    input wire valid_in,  // Indicates valid input sample
    input wire[SAMPLE_WIDTH-1:0] data_in,  // Input sample
    output reg valid_out,  // Indicates valid output sample
    output reg[SAMPLE_WIDTH-1:0] data_out  // Output sample
);

    // Adjust N to fit the golden model FIR filter's size, making it half since we're decimating by 2
    localparam integer PHASE_TAPS = (N+1)/2; // Number of non-zero taps per phase, considering half-band properties
    // Define the coefficients for each phase based on the golden model FIR's coefficients, skipping zeros
    localparam signed [SAMPLE_WIDTH-1:0] coeffs_phase0[0:PHASE_TAPS-1] = '{
        16'sd 5, 16'sd -17, 16'sd 44, 16'sd -96, 16'sd 187,
        16'sd -335, 16'sd 565, 16'sd -906, 16'sd 1401, 16'sd -2112,
        16'sd 3145, 16'sd -4723, 16'sd 7415, 16'sd -13331, 16'sd 32767 // Half of the center tap, assuming symmetric and center tap doubled
    };
    localparam signed [SAMPLE_WIDTH-1:0] coeffs_phase1[0:PHASE_TAPS-1] = '{
        16'sd 5, 16'sd -17, 16'sd 44, 16'sd -96, 16'sd 187,
        16'sd -335, 16'sd 565, 16'sd -906, 16'sd 1401, 16'sd -2112,
        16'sd 3145, 16'sd -4723, 16'sd 7415, 16'sd -13331, 16'sd 32767 // Same as phase0 for a symmetric filter
    };

    // Buffers to store incoming samples for each phase
    reg signed [SAMPLE_WIDTH-1:0] sample_buffer_phase0[0:PHASE_TAPS-1];
    reg signed [SAMPLE_WIDTH-1:0] sample_buffer_phase1[0:PHASE_TAPS-1];

    // Sample counter to manage phases
    reg phase_counter = 0;

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic for buffers, counters, and outputs
            for (i = 0; i < PHASE_TAPS; i = i + 1) begin
                sample_buffer_phase0[i] <= 0;
                sample_buffer_phase1[i] <= 0;
            end
            phase_counter <= 0;
            data_out <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            // Shift buffers to make room for the new sample
            for (i = PHASE_TAPS-1; i > 0; i = i - 1) begin
                if (phase_counter == 0) sample_buffer_phase0[i] <= sample_buffer_phase0[i-1];
                else sample_buffer_phase1[i] <= sample_buffer_phase1[i-1];
            end
             // Load new sample into appropriate buffer based on phase
            if (phase_counter == 0) sample_buffer_phase0[0] <= data_in;
            else sample_buffer_phase1[0] <= data_in;

            // Toggle phase counter
            phase_counter <= phase_counter + 1;
            if (phase_counter >= M-1) phase_counter <= 0;

            // Perform polyphase FIR filtering only when the corresponding phase is filled
            if (phase_counter == 0) begin
                 // Initialize the output accumulators for each phase to zero at the start
                signed [2*SAMPLE_WIDTH-1:0] accumulator_phase0 = 0;
                signed [2*SAMPLE_WIDTH-1:0] accumulator_phase1 = 0;

                // Accumulate the filtered result for phase 0
                for (i = 0; i < PHASE_TAPS; i = i + 1) begin
                    accumulator_phase0 = accumulator_phase0 + sample_buffer_phase0[i] * coeffs_phase0[i];
                end

                // Accumulate the filtered result for phase 1, only if it's time to process phase 1
                if (phase_counter == 1) begin
                    for (i = 0; i < PHASE_TAPS; i = i + 1) begin
                        accumulator_phase1 = accumulator_phase1 + sample_buffer_phase1[i] * coeffs_phase1[i];
                    end
                end

                // Output logic: choose which phase to output based on phase_counter
                if (phase_counter == 0) begin
                    // Output from phase 0, and mark the output as valid
                    data_out <= accumulator_phase0[SAMPLE_WIDTH-1:0]; // Downcast to original sample width
                    valid_out <= 1'b1;
                end else begin
                    // Output from phase 1, and mark the output as valid
                    data_out <= accumulator_phase1[SAMPLE_WIDTH-1:0]; // Downcast to original sample width
                    valid_out <= 1'b1;
                end
            end else begin
                // When there's no valid input, mark output as not valid
                valid_out <= 1'b0;
            end
        end
    end

endmodule