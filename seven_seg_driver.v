`timescale 1ns/1ps
// Four-digit multiplexed, active-low seven-segment display, digit order HH:MM.
module seven_seg_driver #(
    parameter integer SCAN_DIV = 50_000
) (
    input wire clk, input wire rst_n,
    input wire [4:0] hours, input wire [5:0] minutes,
    input wire [4:0] alarm_hours, input wire [5:0] alarm_minutes,
    input wire show_alarm,
    output reg [6:0] seg_n, output reg [3:0] digit_n, output wire dp_n
);
    localparam integer SW = (SCAN_DIV <= 2) ? 1 : $clog2(SCAN_DIV);
    reg [SW-1:0] scan_count;
    reg [1:0] digit;
    reg [3:0] value;
    wire [4:0] disp_h = show_alarm ? alarm_hours : hours;
    wire [5:0] disp_m = show_alarm ? alarm_minutes : minutes;
    wire [3:0] h_tens = disp_h / 10;
    wire [3:0] h_ones = disp_h % 10;
    wire [3:0] m_tens = disp_m / 10;
    wire [3:0] m_ones = disp_m % 10;
    assign dp_n = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin scan_count <= 0; digit <= 0; end
        else if (scan_count == SCAN_DIV-1) begin
            scan_count <= 0; digit <= digit + 1'b1;
        end else scan_count <= scan_count + 1'b1;
    end

    always @* begin
        digit_n = 4'b1111; value = 0;
        case (digit)
            2'd0: begin digit_n = 4'b1110; value = m_ones; end
            2'd1: begin digit_n = 4'b1101; value = m_tens; end
            2'd2: begin digit_n = 4'b1011; value = h_ones; end
            2'd3: begin digit_n = 4'b0111; value = h_tens; end
        endcase
        case (value) // abcdefg, active low
            0: seg_n=7'b0000001; 1: seg_n=7'b1001111;
            2: seg_n=7'b0010010; 3: seg_n=7'b0000110;
            4: seg_n=7'b1001100; 5: seg_n=7'b0100100;
            6: seg_n=7'b0100000; 7: seg_n=7'b0001111;
            8: seg_n=7'b0000000; 9: seg_n=7'b0000100;
            default: seg_n=7'b1111111;
        endcase
    end
endmodule
