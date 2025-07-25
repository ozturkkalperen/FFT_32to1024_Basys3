`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: data_generator
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: Test data generator for FFT processor
//              Generates square wave in Q8.8 fixed-point format
// 
//////////////////////////////////////////////////////////////////////////////////

module data_generator (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [10:0] fft_size,  // 2^5 to 2^10 (32 to 1024)
    output reg [15:0] o_data_real,
    output reg [15:0] o_data_imag,
    output reg o_data_valid,
    output reg o_last
);

    // Q8.8 format constants
    localparam [15:0] POSITIVE_ONE = 16'h0100;  // +1.0 in Q8.8
    localparam [15:0] NEGATIVE_ONE = 16'hFF00;  // -1.0 in Q8.8
    localparam [15:0] ZERO = 16'h0000;          // 0.0 in Q8.8
    
    // Internal registers
    reg [10:0] sample_counter;
    reg [10:0] half_period;
    reg data_phase;  // 0 for positive, 1 for negative
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_data_real <= ZERO;
            o_data_imag <= ZERO;
            o_data_valid <= 1'b0;
            o_last <= 1'b0;
            sample_counter <= 11'd0;
            half_period <= 11'd8;  // Default for 32-point FFT
            data_phase <= 1'b0;
        end else if (enable) begin
            // Calculate half period based on FFT size (divide by 4 for square wave)
            half_period <= fft_size >> 2;
            
            if (sample_counter < fft_size) begin
                o_data_valid <= 1'b1;
                o_data_imag <= ZERO;  // Always zero for real input
                
                // Generate square wave
                if (sample_counter < half_period) begin
                    o_data_real <= POSITIVE_ONE;
                end else if (sample_counter < (half_period << 1)) begin
                    o_data_real <= NEGATIVE_ONE;
                end else if (sample_counter < (half_period + (half_period << 1))) begin
                    o_data_real <= POSITIVE_ONE;
                end else begin
                    o_data_real <= NEGATIVE_ONE;
                end
                
                // Check if this is the last sample
                if (sample_counter == fft_size - 1) begin
                    o_last <= 1'b1;
                end else begin
                    o_last <= 1'b0;
                end
                
                sample_counter <= sample_counter + 1;
            end else begin
                o_data_valid <= 1'b0;
                o_last <= 1'b0;
                sample_counter <= 11'd0;
            end
        end else begin
            o_data_valid <= 1'b0;
            o_last <= 1'b0;
            sample_counter <= 11'd0;
        end
    end

endmodule