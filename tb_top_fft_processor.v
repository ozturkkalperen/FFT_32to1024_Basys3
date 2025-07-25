`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: tb_top_fft_processor
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: Testbench for top-level FFT processor
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_top_fft_processor;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg [4:0] sw;
    wire [3:0] anode;
    wire [6:0] segment;
    wire uart_tx_pin;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period = 100MHz
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        rst_n = 0;
        sw = 5'b00000;  // Start with 32-point FFT
        
        // Wait for a few clock cycles
        #100;
        
        // Release reset
        rst_n = 1;
        
        // Test 32-point FFT
        $display("Testing 32-point FFT (sw = 00000)");
        sw = 5'b00000;
        #50000;  // Wait for processing
        
        // Test 64-point FFT
        $display("Testing 64-point FFT (sw = 00001)");
        sw = 5'b00001;
        #100000;  // Wait for processing
        
        // Test 128-point FFT
        $display("Testing 128-point FFT (sw = 00010)");
        sw = 5'b00010;
        #200000;  // Wait for processing
        
        // Test 1024-point FFT
        $display("Testing 1024-point FFT (sw = 00101)");
        sw = 5'b00101;
        #1000000;  // Wait for processing
        
        // End simulation
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time: %0t, Reset: %b, SW: %b, Anode: %b, Segment: %b, UART: %b", 
                 $time, rst_n, sw, anode, segment, uart_tx_pin);
    end
    
    // Instantiate the Unit Under Test (UUT)
    top_fft_processor uut (
        .clk(clk),
        .rst_n(rst_n),
        .sw(sw),
        .anode(anode),
        .segment(segment),
        .uart_tx_pin(uart_tx_pin)
    );
    
    // Optional: UART monitor to capture transmitted data
    reg [7:0] uart_byte;
    reg [3:0] uart_bit_count;
    reg uart_receiving;
    reg [15:0] uart_baud_counter;
    
    // Simple UART receiver for monitoring
    always @(posedge clk) begin
        if (!rst_n) begin
            uart_receiving <= 0;
            uart_bit_count <= 0;
            uart_baud_counter <= 0;
            uart_byte <= 0;
        end else begin
            if (!uart_receiving && !uart_tx_pin) begin
                // Start bit detected
                uart_receiving <= 1;
                uart_bit_count <= 0;
                uart_baud_counter <= 0;
                uart_byte <= 0;
            end else if (uart_receiving) begin
                uart_baud_counter <= uart_baud_counter + 1;
                
                if (uart_baud_counter == 868) begin  // Baud rate divider
                    uart_baud_counter <= 0;
                    
                    if (uart_bit_count < 8) begin
                        uart_byte[uart_bit_count] <= uart_tx_pin;
                        uart_bit_count <= uart_bit_count + 1;
                    end else begin
                        // Stop bit
                        uart_receiving <= 0;
                        $display("UART received byte: 0x%02h (%d)", uart_byte, uart_byte);
                    end
                end
            end
        end
    end

endmodule