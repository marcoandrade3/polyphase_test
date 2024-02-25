`timescale 1ns / 1ps // Define simulation time units and resolution
module golden_model_tb;

    parameter N = 16; // Size of input signal
    parameter N_f = 16; // Number of frequencies

    // Correction: Define frequencies as an array with correct dimensions
    signed [15:0] frequencies[N_f-1:0]; 
    signed [15:0] input_vector[N-1:0]; // Correct dimensions

    // Correctly define expected_out and received arrays
    signed [15:0] expected_out[N-1:0];
    signed [15:0] received[N-1:0]; 

    // Declaration of clk_in, reset, data_in, valid_in, and other signals needed for the DUT interface
    reg clk_in = 0;
    reg reset;
    reg [15:0] data_in;
    reg valid_in;
    wire [15:0] data_out;
    wire valid_out;

    integer i, f, n = 0; // Declare loop variables and n for indexing input_vector

    // Instantiate the Device Under Test (DUT)
    goldenmodel_fir_filter DUT (
        .clk(clk_in),
        .reset(reset),
        .data_in(data_in),
        .valid_in(valid_in),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    // Clock generation
    always begin
        #5 clk_in = !clk_in; // 100 MHz clock
    end

    initial begin
        reset <= 1; // Assert reset
        #100; // Wait 100ns for global reset
        reset <= 0; // Deassert reset
        valid_in <= 0; // Ensure valid_in is initially low

        // Initialize frequencies and input_vector
        for (i = 0; i < N; i = i + 1) begin
            input_vector[i] = 0; // Initialize input_vector
            expected_out[i] = 0; // Initialize expected_out
        end

        for (i = 0; i < N; i = i + 1) begin 
            for (f = 0; f < N_f; f = f + 1) begin 
                input_vector[i] += 2**16 * $floor($cos(2 * $pi * i * frequencies[f]) / N); 
                if (2**16 * $floor($cos(2 * $pi * i * frequencies[f]) / N) < frequencies[f]) begin 
                    expected_out[i] += 2**16 * $floor($cos(2 * $pi * i * frequencies[f]) / N); 
                end
            end
        end

        // Simulation of input signals
        for (n = 0; n < N; n = n + 1) begin 
            @(posedge clk_in); // Wait for the next clock edge
            valid_in <= 1; // Signal that valid data is being sent
            data_in <= input_vector[n]; // Send the next value
            #10; // Wait for a bit before changing valid_in back
            valid_in <= 0; // Ensure only one valid data per cycle
        end
    end  
    
    // Capture output data
    always @(posedge clk_in) begin 
        if (valid_out) begin 
            received[n] <= data_out; // Store received data
        end 
    end

    #1000; // Adjust delay as needed to ensure all inputs are processed

    // Compare received and expected outputs
    integer mismatches = 0;
    for (i = 0; i < N; i = i + 1) begin
        if (abs(received[i] - expected_out[i]) > THRESHOLD) begin
            $display("Mismatch at index %d: Expected %d, Received %d", i, expected_out[i], received[i]);
            mismatches = mismatches + 1;
        end
    end

    if (mismatches == 0) begin
        $display("All outputs match within the threshold.");
    end else begin
        $display("Detected %d mismatches.", mismatches);
    end

    $finish; // End simulation

// Function to calculate absolute value
function automatic int abs;
    input int value;
    begin
        if (value < 0)
            abs = -value;
        else
            abs = value;
    end
endfunction

endmodule
