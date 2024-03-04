`timescale 1ns / 1ps 
module golden_model_tb;

    parameter N = 16; 
    parameter N_f = 16; 

    signed [15:0] frequencies[N_f-1:0]; 
    signed [15:0] input_vector[N-1:0]; 

    signed [15:0] expected_out[N-1:0];
    signed [15:0] received[N-1:0]; 

    reg clk_in = 0;
    reg reset;
    reg [15:0] data_in;
    reg valid_in;
    wire [15:0] data_out;
    wire valid_out;

    integer i, f, n = 0; 

    goldenmodel_fir_filter DUT (
        .clk(clk_in),
        .reset(reset),
        .data_in(data_in),
        .valid_in(valid_in),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    always begin
        #5 clk_in = !clk_in;
    end

    initial begin
        reset <= 1; 
        #100; 
        reset <= 0; 
        valid_in <= 0; 

        for (i = 0; i < N; i = i + 1) begin
            input_vector[i] = 0; 
            expected_out[i] = 0; 
        end

        for (i = 0; i < N; i = i + 1) begin 
            for (f = 0; f < N_f; f = f + 1) begin 
                input_vector[i] += 2**16 * $floor($cos(2 * $pi * i * frequencies[f]) / N); 
                if (2**16 * $floor($cos(2 * $pi * i * frequencies[f]) / N) < frequencies[f]) begin 
                    expected_out[i] += 2**16 * $floor($cos(2 * $pi * i * frequencies[f]) / N); 
                end
            end
        end

        for (n = 0; n < N; n = n + 1) begin 
            @(posedge clk_in); 
            valid_in <= 1;
            data_in <= input_vector[n]; 
            #10; 
            valid_in <= 0;
        end
    end  
    
    always @(posedge clk_in) begin 
        if (valid_out) begin 
            received[n] <= data_out; 
        end 
    end

    #1000; 

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

    $finish;

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
