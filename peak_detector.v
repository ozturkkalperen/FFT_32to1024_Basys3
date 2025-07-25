`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: peak_detector
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: Peak detector for finding maximum magnitude and its index
//              from FFT magnitude spectrum
// 
//////////////////////////////////////////////////////////////////////////////////

module peak_detector (
    input wire clk,
    input wire rst_n,
    input wire start_detection,
    input wire [16:0] magnitude_in,
    input wire magnitude_valid,
    input wire [10:0] fft_size,
    output reg [16:0] peak_magnitude,
    output reg [10:0] peak_index,
    output reg detection_complete
);

    // Internal registers
    reg [10:0] sample_counter;
    reg detection_active;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            peak_magnitude <= 17'd0;
            peak_index <= 11'd0;
            sample_counter <= 11'd0;
            detection_active <= 1'b0;
            detection_complete <= 1'b0;
        end else begin
            if (start_detection) begin
                // Initialize peak detection
                peak_magnitude <= 17'd0;
                peak_index <= 11'd0;
                sample_counter <= 11'd0;
                detection_active <= 1'b1;
                detection_complete <= 1'b0;
            end else if (detection_active && magnitude_valid) begin
                // Compare current magnitude with peak
                if (magnitude_in > peak_magnitude) begin
                    peak_magnitude <= magnitude_in;
                    peak_index <= sample_counter;
                end
                
                // Increment sample counter
                sample_counter <= sample_counter + 1;
                
                // Check if we've processed all samples
                if (sample_counter == fft_size - 1) begin
                    detection_active <= 1'b0;
                    detection_complete <= 1'b1;
                end
            end else if (detection_complete) begin
                // Hold the complete signal for one cycle
                detection_complete <= 1'b0;
            end
        end
    end

endmodule