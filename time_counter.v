`timescale 1ns/1ps
// 24-hour time counter. Adjustment inputs advance the selected field by one.
module time_counter (
    input wire clk, input wire rst_n, input wire tick_1hz,
    input wire set_time, input wire inc_hour, input wire inc_min,
    output reg [4:0] hours, output reg [5:0] minutes, output reg [5:0] seconds
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hours <= 0; minutes <= 0; seconds <= 0;
        end else if (set_time && inc_hour) begin
            hours <= (hours == 23) ? 0 : hours + 1'b1;
        end else if (set_time && inc_min) begin
            minutes <= (minutes == 59) ? 0 : minutes + 1'b1;
        end else if (tick_1hz) begin
            if (seconds == 59) begin
                seconds <= 0;
                if (minutes == 59) begin
                    minutes <= 0;
                    hours <= (hours == 23) ? 0 : hours + 1'b1;
                end else minutes <= minutes + 1'b1;
            end else seconds <= seconds + 1'b1;
        end
    end
endmodule
