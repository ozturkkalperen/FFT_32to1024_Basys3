//==============================================================================
// UART Transmitter Module
// Author: Auto-generated for Basys 3 FPGA
// Description: Transmits 8-bit data via UART at 115200 baud rate
//              Configuration: 8 data bits, 1 stop bit, no parity
//==============================================================================

module uart_tx (
    input  wire       clk,           // 100 MHz system clock
    input  wire       rst_n,         // Active low reset
    input  wire [7:0] i_data,        // 8-bit data to transmit
    input  wire       i_data_valid,  // Data valid signal
    output reg        o_uart_tx,     // UART TX line
    output reg        o_busy         // Busy signal (transmission in progress)
);

    // UART Parameters for 115200 baud at 100MHz clock
    // Baud rate = 115200
    // Clock cycles per bit = 100MHz / 115200 = 868.055... ≈ 868
    localparam CLKS_PER_BIT = 868;
    localparam BIT_COUNTER_WIDTH = 10; // log2(868) ≈ 10 bits
    
    // UART Frame: 1 start bit + 8 data bits + 1 stop bit = 10 bits total
    localparam IDLE_STATE     = 3'b000;
    localparam START_BIT      = 3'b001;
    localparam DATA_BITS      = 3'b010;
    localparam STOP_BIT       = 3'b011;
    localparam CLEANUP        = 3'b100;

    // Internal registers
    reg [2:0]                    state;
    reg [BIT_COUNTER_WIDTH-1:0]  clk_counter;
    reg [2:0]                    bit_index;
    reg [7:0]                    tx_data;

    //==========================================================================
    // UART Transmitter State Machine
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE_STATE;
            o_uart_tx   <= 1'b1;        // UART idle state is high
            o_busy      <= 1'b0;
            clk_counter <= 0;
            bit_index   <= 0;
            tx_data     <= 8'h00;
        end else begin
            case (state)
                IDLE_STATE: begin
                    o_uart_tx   <= 1'b1;   // Keep line high when idle
                    o_busy      <= 1'b0;
                    clk_counter <= 0;
                    bit_index   <= 0;
                    
                    if (i_data_valid) begin
                        tx_data <= i_data;
                        o_busy  <= 1'b1;
                        state   <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    o_uart_tx <= 1'b0;     // Start bit is low
                    
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end else begin
                        clk_counter <= 0;
                        state       <= DATA_BITS;
                    end
                end
                
                DATA_BITS: begin
                    o_uart_tx <= tx_data[bit_index];  // Send data bit (LSB first)
                    
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end else begin
                        clk_counter <= 0;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT: begin
                    o_uart_tx <= 1'b1;     // Stop bit is high
                    
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end else begin
                        clk_counter <= 0;
                        state       <= CLEANUP;
                    end
                end
                
                CLEANUP: begin
                    o_busy <= 1'b0;
                    state  <= IDLE_STATE;
                end
                
                default: begin
                    state <= IDLE_STATE;
                end
            endcase
        end
    end

endmodule