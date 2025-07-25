`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: magnitude_calculator
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: Magnitude calculator for complex FFT outputs
//              Uses approximation: magnitude ≈ |real| + |imag|
// 
//////////////////////////////////////////////////////////////////////////////////

module magnitude_calculator (
    input wire clk,
    input wire rst_n,
    input wire [15:0] real_in,
    input wire [15:0] imag_in,
    input wire valid_in,
    output reg [16:0] magnitude_out,
    output reg valid_out
);

    // Pipeline registers for timing
    reg [15:0] abs_real, abs_imag;
    reg valid_stage1;
    
    // Stage 1: Calculate absolute values
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            abs_real <= 16'd0;
            abs_imag <= 16'd0;
            valid_stage1 <= 1'b0;
        end else begin
            valid_stage1 <= valid_in;
            
            // Calculate absolute value of real part
            if (real_in[15]) begin  // Negative number
                abs_real <= ~real_in + 1;
            end else begin
                abs_real <= real_in;
            end
            
            // Calculate absolute value of imaginary part
            if (imag_in[15]) begin  // Negative number
                abs_imag <= ~imag_in + 1;
            end else begin
                abs_imag <= imag_in;
            end
        end
    end
    
    // Stage 2: Add absolute values
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            magnitude_out <= 17'd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_stage1;
            magnitude_out <= {1'b0, abs_real} + {1'b0, abs_imag};
        end
    end

endmodule