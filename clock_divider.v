`timescale 1ns/1ps
// Generates a one-clock-wide enable pulse. No derived/gated clock is used.
module clock_divider #(
    parameter integer CLK_HZ = 50_000_000
) (
    input  wire clk,
    input  wire rst_n,
    output reg  tick_1hz
);
    localparam integer DIVISOR = (CLK_HZ < 1) ? 1 : CLK_HZ;
    localparam integer CW = (DIVISOR <= 2) ? 1 : $clog2(DIVISOR);
    reg [CW-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count   <= {CW{1'b0}};
            tick_1hz <= 1'b0;
        end else if (count == DIVISOR-1) begin
            count   <= {CW{1'b0}};
            tick_1hz <= 1'b1;
        end else begin
            count   <= count + 1'b1;
            tick_1hz <= 1'b0;
        end
    end
endmodule
