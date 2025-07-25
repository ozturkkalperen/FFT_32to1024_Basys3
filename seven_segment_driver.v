`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: seven_segment_driver
// Project Name: Configurable FFT Processor
// Target Devices: Basys 3
// Tool Versions: Vivado 2022.2
// Description: 7-segment display driver for 4-digit display
//              Shows peak frequency index from FFT results
// 
//////////////////////////////////////////////////////////////////////////////////

module seven_segment_driver (
    input wire clk,
    input wire rst_n,
    input wire [15:0] i_display_value,
    output reg [3:0] o_anode,
    output reg [6:0] o_segment
);

    // Clock divider for display refresh (approximately 1kHz refresh rate)
    reg [16:0] clk_div;
    reg [1:0] digit_select;
    
    // BCD conversion registers
    reg [3:0] thousands, hundreds, tens, ones;
    reg [3:0] current_digit;
    
    // Clock divider
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 17'd0;
            digit_select <= 2'd0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == 17'd0) begin
                digit_select <= digit_select + 1;
            end
        end
    end
    
    // Binary to BCD conversion
    always @(*) begin
        thousands = (i_display_value / 1000) % 10;
        hundreds = (i_display_value / 100) % 10;
        tens = (i_display_value / 10) % 10;
        ones = i_display_value % 10;
    end
    
    // Digit multiplexing
    always @(*) begin
        case (digit_select)
            2'd0: begin
                o_anode = 4'b1110;  // Enable rightmost digit
                current_digit = ones;
            end
            2'd1: begin
                o_anode = 4'b1101;  // Enable second digit
                current_digit = tens;
            end
            2'd2: begin
                o_anode = 4'b1011;  // Enable third digit
                current_digit = hundreds;
            end
            2'd3: begin
                o_anode = 4'b0111;  // Enable leftmost digit
                current_digit = thousands;
            end
            default: begin
                o_anode = 4'b1111;  // All off
                current_digit = 4'd0;
            end
        endcase
    end
    
    // 7-segment decoder (common anode, active low)
    always @(*) begin
        case (current_digit)
            4'd0: o_segment = 7'b1000000;  // 0
            4'd1: o_segment = 7'b1111001;  // 1
            4'd2: o_segment = 7'b0100100;  // 2
            4'd3: o_segment = 7'b0110000;  // 3
            4'd4: o_segment = 7'b0011001;  // 4
            4'd5: o_segment = 7'b0010010;  // 5
            4'd6: o_segment = 7'b0000010;  // 6
            4'd7: o_segment = 7'b1111000;  // 7
            4'd8: o_segment = 7'b0000000;  // 8
            4'd9: o_segment = 7'b0010000;  // 9
            default: o_segment = 7'b1111111;  // Blank
        endcase
    end

endmodule