//==============================================================================
// Top Level Module for Basys 3 128-Tap FIR Filter with UART Control
// Author: Auto-generated for Basys 3 FPGA
// Description: Main control module integrating test signal generator, 
//              FIR filter IP, and UART transmitter with FSM control
//==============================================================================

module top_module (
    input  wire        clk,           // 100 MHz system clock
    input  wire        rst_n,         // Active low reset
    input  wire        sw0,           // Switch to select test signal (0=5MHz, 1=20MHz)
    output wire        uart_tx_pin    // UART TX output pin
);

    // FSM States
    localparam IDLE             = 3'b000;
    localparam GENERATE_DATA    = 3'b001;
    localparam SEND_INPUT_LOW   = 3'b010;
    localparam SEND_INPUT_HIGH  = 3'b011;
    localparam WAIT_FIR_OUTPUT  = 3'b100;
    localparam SEND_OUTPUT_LOW  = 3'b101;
    localparam SEND_OUTPUT_HIGH = 3'b110;

    // FSM registers
    reg [2:0] current_state, next_state;
    
    // Internal signals
    wire [15:0] test_data;
    wire        test_data_valid;
    wire [15:0] fir_output_data;
    wire        fir_output_valid;
    wire        fir_input_ready;
    
    // UART signals
    reg  [7:0]  uart_data;
    reg         uart_data_valid;
    wire        uart_busy;
    
    // Data storage registers
    reg [15:0] input_data_reg;
    reg [15:0] output_data_reg;
    reg        data_captured;

    //==========================================================================
    // Test Signal Generator Instance
    //==========================================================================
    test_signal_generator u_test_gen (
        .clk            (clk),
        .rst_n          (rst_n),
        .enable         (current_state == GENERATE_DATA),
        .freq_select    (sw0),          // 0=5MHz, 1=20MHz
        .o_data         (test_data),
        .o_data_valid   (test_data_valid)
    );

    //==========================================================================
    // FIR Filter IP Instance (AXI4-Stream Interface)
    // Note: This should be replaced with actual Vivado FIR Compiler IP
    //==========================================================================
    fir_compiler_0 u_fir_filter (
        .aclk                   (clk),
        .aresetn                (rst_n),
        
        // Input AXI4-Stream
        .s_axis_data_tvalid     (test_data_valid && (current_state == GENERATE_DATA)),
        .s_axis_data_tready     (fir_input_ready),
        .s_axis_data_tdata      (test_data),
        
        // Output AXI4-Stream  
        .m_axis_data_tvalid     (fir_output_valid),
        .m_axis_data_tdata      (fir_output_data)
    );

    //==========================================================================
    // UART Transmitter Instance
    //==========================================================================
    uart_tx u_uart_tx (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_data         (uart_data),
        .i_data_valid   (uart_data_valid),
        .o_uart_tx      (uart_tx_pin),
        .o_busy         (uart_busy)
    );

    //==========================================================================
    // FSM Sequential Logic
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    //==========================================================================
    // FSM Combinational Logic
    //==========================================================================
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                next_state = GENERATE_DATA;
            end
            
            GENERATE_DATA: begin
                if (test_data_valid && fir_input_ready) begin
                    next_state = SEND_INPUT_LOW;
                end
            end
            
            SEND_INPUT_LOW: begin
                if (!uart_busy) begin
                    next_state = SEND_INPUT_HIGH;
                end
            end
            
            SEND_INPUT_HIGH: begin
                if (!uart_busy) begin
                    next_state = WAIT_FIR_OUTPUT;
                end
            end
            
            WAIT_FIR_OUTPUT: begin
                if (fir_output_valid) begin
                    next_state = SEND_OUTPUT_LOW;
                end
            end
            
            SEND_OUTPUT_LOW: begin
                if (!uart_busy) begin
                    next_state = SEND_OUTPUT_HIGH;
                end
            end
            
            SEND_OUTPUT_HIGH: begin
                if (!uart_busy) begin
                    next_state = GENERATE_DATA;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    //==========================================================================
    // Data Capture and UART Control Logic
    //==========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_data_reg  <= 16'h0000;
            output_data_reg <= 16'h0000;
            uart_data       <= 8'h00;
            uart_data_valid <= 1'b0;
            data_captured   <= 1'b0;
        end else begin
            uart_data_valid <= 1'b0; // Default
            
            case (current_state)
                GENERATE_DATA: begin
                    if (test_data_valid && fir_input_ready && !data_captured) begin
                        input_data_reg <= test_data;
                        data_captured  <= 1'b1;
                    end
                end
                
                SEND_INPUT_LOW: begin
                    if (!uart_busy && !uart_data_valid) begin
                        uart_data       <= input_data_reg[7:0];   // Low byte
                        uart_data_valid <= 1'b1;
                    end
                end
                
                SEND_INPUT_HIGH: begin
                    if (!uart_busy && !uart_data_valid) begin
                        uart_data       <= input_data_reg[15:8];  // High byte
                        uart_data_valid <= 1'b1;
                    end
                end
                
                WAIT_FIR_OUTPUT: begin
                    if (fir_output_valid) begin
                        output_data_reg <= fir_output_data;
                    end
                end
                
                SEND_OUTPUT_LOW: begin
                    if (!uart_busy && !uart_data_valid) begin
                        uart_data       <= output_data_reg[7:0];  // Low byte
                        uart_data_valid <= 1'b1;
                    end
                end
                
                SEND_OUTPUT_HIGH: begin
                    if (!uart_busy && !uart_data_valid) begin
                        uart_data       <= output_data_reg[15:8]; // High byte
                        uart_data_valid <= 1'b1;
                        data_captured   <= 1'b0; // Reset for next cycle
                    end
                end
            endcase
        end
    end

endmodule