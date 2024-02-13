`timescale 1ns / 1ps
`default_nettype none

module polyphase_half_band_tb;
    paramater N = 16; // Size of input signal
    parameter N_f = 16; // Number of frequencies

    signed [N_f:0] frequencies; 
    signed [15:0] input_vector [N]; 

    // Compare these two 
    signed [15:0] expected_out [N];
    signed [15:0] received [$]; 

    always begin
        #5; 
        clk_in = !clk_in;
    end

    initial begin 
        for (i = 0; i < N; i++) begin 
            for (f = 0; f < N_f; f++) begin 
                // can be convered to some function eventually 
                input_vector[i] += 2**16 * $floor($cos(2 * $pi * i frequencies[f]) / N); 
                // check treshold, add only if its in the passband
                if (2**16 * $floor($cos(2 * $pi * i frequencies[f]) / N) < frequncies[f]) begin 
                    expected_out[i] += 2**16 * $floor($cos(2 * $pi * i frequencies[f]) / N); 
                end
                expected_out; 
            end
        end             
        reset <= 1;
        repeat(50) @(posedge clk)  
        reset <= 0;
    end  
    
    int n; 
    always @(posedge clk) begin 
        if (valid_in) begin 
            n++;
            data_in <= input_vector[n];
        end 
    end 

    always @(posedge clk) begin 
        if (reset) begin 
            valid <= 0;
        end else begin
            valid <= $urandom();
        end 
    end

endmodule
`default_nettype wire