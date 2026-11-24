`timescale 1ns/1ps
module alarm_controller (
    input wire clk, input wire rst_n,
    input wire [4:0] hours, input wire [5:0] minutes,
    input wire set_alarm, input wire inc_alarm_hour, input wire inc_alarm_min,
    input wire alarm_enable, input wire alarm_ack,
    output reg [4:0] alarm_hours, output reg [5:0] alarm_minutes,
    output reg alarm_active
);
    reg match_seen;
    wire time_matches = (hours == alarm_hours) && (minutes == alarm_minutes);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alarm_hours <= 0; alarm_minutes <= 0;
            alarm_active <= 0; match_seen <= 0;
        end else begin
            if (set_alarm && inc_alarm_hour)
                alarm_hours <= (alarm_hours == 23) ? 0 : alarm_hours + 1'b1;
            else if (set_alarm && inc_alarm_min)
                alarm_minutes <= (alarm_minutes == 59) ? 0 : alarm_minutes + 1'b1;

            // Trigger once upon entering the matching minute; acknowledgement
            // silences it until the clock leaves that minute.
            if (!time_matches) match_seen <= 0;
            else if (alarm_enable && !match_seen) begin
                alarm_active <= 1;
                match_seen <= 1;
            end
            if (alarm_ack || !alarm_enable) alarm_active <= 0;
        end
    end
endmodule
