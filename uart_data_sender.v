`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: uart_data_sender
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: UART data sender for FFT results
//              Sends 16-bit complex data as 4 bytes (real_high, real_low, imag_high, imag_low)
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_data_sender (
    input wire clk,
    input wire rst_n,
    input wire start_send,
    input wire [15:0] real_data,
    input wire [15:0] imag_data,
    input wire data_valid,
    input wire [10:0] fft_size,
    output reg [7:0] uart_tx_data,
    output reg uart_tx_start,
    input wire uart_tx_done,
    input wire uart_tx_busy,
    output reg send_complete
);

    // State machine states
    localparam IDLE = 3'd0;
    localparam SEND_REAL_HIGH = 3'd1;
    localparam SEND_REAL_LOW = 3'd2;
    localparam SEND_IMAG_HIGH = 3'd3;
    localparam SEND_IMAG_LOW = 3'd4;
    localparam WAIT_NEXT = 3'd5;
    
    // Internal registers
    reg [2:0] state;
    reg [10:0] sample_counter;
    reg [15:0] current_real, current_imag;
    reg sending_active;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            uart_tx_data <= 8'd0;
            uart_tx_start <= 1'b0;
            send_complete <= 1'b0;
            sample_counter <= 11'd0;
            current_real <= 16'd0;
            current_imag <= 16'd0;
            sending_active <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    uart_tx_start <= 1'b0;
                    send_complete <= 1'b0;
                    sample_counter <= 11'd0;
                    
                    if (start_send) begin
                        sending_active <= 1'b1;
                        state <= WAIT_NEXT;
                    end
                end
                
                WAIT_NEXT: begin
                    uart_tx_start <= 1'b0;
                    
                    if (data_valid && sending_active) begin
                        current_real <= real_data;
                        current_imag <= imag_data;
                        state <= SEND_REAL_HIGH;
                    end else if (sample_counter >= fft_size) begin
                        send_complete <= 1'b1;
                        sending_active <= 1'b0;
                        state <= IDLE;
                    end
                end
                
                SEND_REAL_HIGH: begin
                    if (!uart_tx_busy) begin
                        uart_tx_data <= current_real[15:8];
                        uart_tx_start <= 1'b1;
                        state <= SEND_REAL_LOW;
                    end
                end
                
                SEND_REAL_LOW: begin
                    uart_tx_start <= 1'b0;
                    if (uart_tx_done) begin
                        uart_tx_data <= current_real[7:0];
                        uart_tx_start <= 1'b1;
                        state <= SEND_IMAG_HIGH;
                    end
                end
                
                SEND_IMAG_HIGH: begin
                    uart_tx_start <= 1'b0;
                    if (uart_tx_done) begin
                        uart_tx_data <= current_imag[15:8];
                        uart_tx_start <= 1'b1;
                        state <= SEND_IMAG_LOW;
                    end
                end
                
                SEND_IMAG_LOW: begin
                    uart_tx_start <= 1'b0;
                    if (uart_tx_done) begin
                        uart_tx_data <= current_imag[7:0];
                        uart_tx_start <= 1'b1;
                        sample_counter <= sample_counter + 1;
                        state <= WAIT_NEXT;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule