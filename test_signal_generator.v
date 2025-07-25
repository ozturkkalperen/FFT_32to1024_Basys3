//==============================================================================
// Test Signal Generator Module with NCO (Numerically Controlled Oscillator)
// Author: Auto-generated for Basys 3 FPGA
// Description: Generates sine waves at 5MHz (passband) and 20MHz (stopband)
//              for testing the 128-tap FIR low-pass filter
//==============================================================================

module test_signal_generator (
    input  wire        clk,           // 100 MHz system clock
    input  wire        rst_n,         // Active low reset
    input  wire        enable,        // Enable signal from FSM
    input  wire        freq_select,   // 0=5MHz, 1=20MHz
    output reg  [15:0] o_data,        // 16-bit signed output data
    output reg         o_data_valid   // Data valid signal
);

    // NCO Parameters
    // For 100MHz clock:
    // Phase increment = (Target_Freq * 2^32) / Clock_Freq
    // 5MHz:  Phase increment = (5e6 * 2^32) / 100e6 = 214748364.8 ≈ 214748365
    // 20MHz: Phase increment = (20e6 * 2^32) / 100e6 = 858993459.2 ≈ 858993459
    
    localparam PHASE_INC_5MHZ  = 32'd214748365;  // 5MHz phase increment
    localparam PHASE_INC_20MHZ = 32'd858993459;  // 20MHz phase increment
    localparam LUT_DEPTH       = 256;            // 256 samples in sine LUT
    localparam LUT_ADDR_BITS   = 8;              // log2(256) = 8 bits

    // Internal registers
    reg [31:0] phase_accumulator;
    reg [31:0] phase_increment;
    reg [LUT_ADDR_BITS-1:0] lut_address;
    reg [15:0] sine_lut [0:LUT_DEPTH-1];
    reg        data_valid_reg;

    // Initialize sine wave LUT from memory file
    initial begin
        $readmemh("sine_wave.mem", sine_lut);
    end

    //==========================================================================
    // Phase Increment Selection
    //==========================================================================
    always @(*) begin
        if (freq_select) begin
            phase_increment = PHASE_INC_20MHZ;  // 20MHz for stopband test
        end else begin
            phase_increment = PHASE_INC_5MHZ;   // 5MHz for passband test
        end
    end

    //==========================================================================
    // NCO Phase Accumulator
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_accumulator <= 32'h00000000;
        end else if (enable) begin
            phase_accumulator <= phase_accumulator + phase_increment;
        end
    end

    //==========================================================================
    // LUT Address Generation (Use upper 8 bits of phase accumulator)
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lut_address <= 8'h00;
        end else if (enable) begin
            lut_address <= phase_accumulator[31:24]; // Use MSBs for LUT indexing
        end
    end

    //==========================================================================
    // Sine Wave Output Generation
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_data <= 16'h0000;
            data_valid_reg <= 1'b0;
        end else if (enable) begin
            o_data <= sine_lut[lut_address];
            data_valid_reg <= 1'b1;
        end else begin
            data_valid_reg <= 1'b0;
        end
    end

    //==========================================================================
    // Output Valid Signal (Delayed by one clock for LUT read)
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_data_valid <= 1'b0;
        end else begin
            o_data_valid <= data_valid_reg;
        end
    end

endmodule