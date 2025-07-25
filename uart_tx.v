`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: uart_tx
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: UART Transmitter module
//              115200 baud, 8-N-1 configuration
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_tx (
    input wire clk,           // 100MHz system clock
    input wire rst_n,
    input wire [7:0] tx_data,
    input wire tx_start,
    output reg tx_pin,
    output reg tx_busy,
    output reg tx_done
);

    // UART parameters for 115200 baud at 100MHz
    localparam BAUD_RATE = 115200;
    localparam CLK_FREQ = 100000000;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;  // 868
    
    // State machine states
    localparam IDLE = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT = 3'd3;
    
    // Internal registers
    reg [2:0] state;
    reg [9:0] baud_counter;
    reg [2:0] bit_counter;
    reg [7:0] tx_shift_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_pin <= 1'b1;
            tx_busy <= 1'b0;
            tx_done <= 1'b0;
            baud_counter <= 10'd0;
            bit_counter <= 3'd0;
            tx_shift_reg <= 8'd0;
        end else begin
            tx_done <= 1'b0;  // Clear done flag by default
            
            case (state)
                IDLE: begin
                    tx_pin <= 1'b1;
                    tx_busy <= 1'b0;
                    baud_counter <= 10'd0;
                    bit_counter <= 3'd0;
                    
                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        tx_busy <= 1'b1;
                        state <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    tx_pin <= 1'b0;  // Start bit
                    
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 10'd0;
                        state <= DATA_BITS;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                DATA_BITS: begin
                    tx_pin <= tx_shift_reg[0];
                    
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 10'd0;
                        tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                        
                        if (bit_counter == 3'd7) begin
                            bit_counter <= 3'd0;
                            state <= STOP_BIT;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                STOP_BIT: begin
                    tx_pin <= 1'b1;  // Stop bit
                    
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 10'd0;
                        tx_done <= 1'b1;
                        state <= IDLE;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule