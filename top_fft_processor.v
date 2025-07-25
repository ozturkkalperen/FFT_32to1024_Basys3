`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: top_fft_processor
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: Top-level module for configurable FFT processor
//              Integrates FFT IP, data generator, UART, and 7-segment display
// 
//////////////////////////////////////////////////////////////////////////////////

module top_fft_processor (
    input wire clk,              // 100MHz system clock
    input wire rst_n,            // Active low reset (from btnC)
    input wire [4:0] sw,         // Switches for FFT size selection
    output wire [3:0] anode,     // 7-segment anodes
    output wire [6:0] segment,   // 7-segment segments
    output wire uart_tx_pin      // UART transmit pin
);

    // FSM States
    localparam CONFIG_FFT = 4'd0;
    localparam SEND_DATA_TO_FFT = 4'd1;
    localparam WAIT_FFT_RESULT = 4'd2;
    localparam PROCESS_RESULTS = 4'd3;
    localparam SEND_UART_DATA = 4'd4;
    
    // Internal signals
    reg [3:0] state;
    reg [10:0] fft_size;
    reg [4:0] fft_log_size;
    
    // Data generator signals
    wire [15:0] gen_data_real, gen_data_imag;
    wire gen_data_valid, gen_last;
    reg gen_enable;
    
    // FFT IP signals (these would connect to actual FFT IP)
    reg [15:0] fft_data_real, fft_data_imag;
    reg fft_data_valid, fft_data_last;
    wire [15:0] fft_out_real, fft_out_imag;
    wire fft_out_valid, fft_out_last;
    reg fft_config_valid;
    reg [7:0] fft_config_data;
    
    // Magnitude calculator signals
    wire [16:0] magnitude;
    wire magnitude_valid;
    
    // Peak detector signals
    wire [16:0] peak_magnitude;
    wire [10:0] peak_index;
    wire peak_detection_complete;
    reg start_peak_detection;
    
    // UART signals
    wire [7:0] uart_tx_data;
    wire uart_tx_start, uart_tx_done, uart_tx_busy;
    
    // UART data sender signals
    reg start_uart_send;
    wire uart_send_complete;
    
    // 7-segment display
    wire [15:0] display_value;
    
    // Result storage for UART transmission
    reg [15:0] result_buffer_real [0:1023];
    reg [15:0] result_buffer_imag [0:1023];
    reg [10:0] result_counter;
    reg [10:0] uart_counter;
    
    // Calculate FFT size from switches
    always @(*) begin
        fft_log_size = sw + 5;  // sw=0 -> 5 (32 points), sw=5 -> 10 (1024 points)
        fft_size = 1 << fft_log_size;
    end
    
    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= CONFIG_FFT;
            gen_enable <= 1'b0;
            fft_config_valid <= 1'b0;
            fft_config_data <= 8'd0;
            fft_data_valid <= 1'b0;
            fft_data_real <= 16'd0;
            fft_data_imag <= 16'd0;
            fft_data_last <= 1'b0;
            start_peak_detection <= 1'b0;
            start_uart_send <= 1'b0;
            result_counter <= 11'd0;
            uart_counter <= 11'd0;
        end else begin
            case (state)
                CONFIG_FFT: begin
                    gen_enable <= 1'b0;
                    start_peak_detection <= 1'b0;
                    start_uart_send <= 1'b0;
                    result_counter <= 11'd0;
                    uart_counter <= 11'd0;
                    
                    // Configure FFT IP (simplified - actual IP would need specific config format)
                    fft_config_data <= fft_log_size;
                    fft_config_valid <= 1'b1;
                    
                    state <= SEND_DATA_TO_FFT;
                end
                
                SEND_DATA_TO_FFT: begin
                    fft_config_valid <= 1'b0;
                    gen_enable <= 1'b1;
                    
                    // Forward data from generator to FFT
                    fft_data_real <= gen_data_real;
                    fft_data_imag <= gen_data_imag;
                    fft_data_valid <= gen_data_valid;
                    fft_data_last <= gen_last;
                    
                    if (gen_last && gen_data_valid) begin
                        gen_enable <= 1'b0;
                        state <= WAIT_FFT_RESULT;
                    end
                end
                
                WAIT_FFT_RESULT: begin
                    fft_data_valid <= 1'b0;
                    fft_data_last <= 1'b0;
                    
                    if (fft_out_valid) begin
                        state <= PROCESS_RESULTS;
                        start_peak_detection <= 1'b1;
                    end
                end
                
                PROCESS_RESULTS: begin
                    start_peak_detection <= 1'b0;
                    
                    // Store FFT results for UART transmission
                    if (fft_out_valid && result_counter < fft_size) begin
                        result_buffer_real[result_counter] <= fft_out_real;
                        result_buffer_imag[result_counter] <= fft_out_imag;
                        result_counter <= result_counter + 1;
                    end
                    
                    // Check if all results processed and peak detection complete
                    if (peak_detection_complete && result_counter >= fft_size) begin
                        start_uart_send <= 1'b1;
                        state <= SEND_UART_DATA;
                    end
                end
                
                SEND_UART_DATA: begin
                    start_uart_send <= 1'b0;
                    
                    if (uart_send_complete) begin
                        state <= CONFIG_FFT;  // Loop back for continuous operation
                    end
                end
                
                default: state <= CONFIG_FFT;
            endcase
        end
    end
    
    // Assign display value to peak index
    assign display_value = {5'd0, peak_index};
    
    // Module instantiations
    data_generator data_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(gen_enable),
        .fft_size(fft_size),
        .o_data_real(gen_data_real),
        .o_data_imag(gen_data_imag),
        .o_data_valid(gen_data_valid),
        .o_last(gen_last)
    );
    
    // Note: Actual FFT IP would be instantiated here
    // For simulation, we'll create a simple passthrough
    assign fft_out_real = fft_data_real;
    assign fft_out_imag = fft_data_imag;
    assign fft_out_valid = fft_data_valid;
    assign fft_out_last = fft_data_last;
    
    magnitude_calculator mag_calc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .real_in(fft_out_real),
        .imag_in(fft_out_imag),
        .valid_in(fft_out_valid),
        .magnitude_out(magnitude),
        .valid_out(magnitude_valid)
    );
    
    peak_detector peak_det_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start_detection(start_peak_detection),
        .magnitude_in(magnitude),
        .magnitude_valid(magnitude_valid),
        .fft_size(fft_size),
        .peak_magnitude(peak_magnitude),
        .peak_index(peak_index),
        .detection_complete(peak_detection_complete)
    );
    
    uart_tx uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_pin(uart_tx_pin),
        .tx_busy(uart_tx_busy),
        .tx_done(uart_tx_done)
    );
    
    uart_data_sender uart_sender_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start_send(start_uart_send),
        .real_data(result_buffer_real[uart_counter]),
        .imag_data(result_buffer_imag[uart_counter]),
        .data_valid(uart_counter < fft_size),
        .fft_size(fft_size),
        .uart_tx_data(uart_tx_data),
        .uart_tx_start(uart_tx_start),
        .uart_tx_done(uart_tx_done),
        .uart_tx_busy(uart_tx_busy),
        .send_complete(uart_send_complete)
    );
    
    seven_segment_driver seg_display_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_display_value(display_value),
        .o_anode(anode),
        .o_segment(segment)
    );

endmodule