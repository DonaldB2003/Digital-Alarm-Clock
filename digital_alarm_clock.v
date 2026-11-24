`timescale 1ns/1ps
// Top-level. Buttons should be debounced/synchronized outside this module.
module digital_alarm_clock #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer SCAN_DIV = 50_000
) (
    input wire clk, input wire rst_n,
    input wire set_time, input wire inc_hour, input wire inc_min,
    input wire set_alarm, input wire inc_alarm_hour, input wire inc_alarm_min,
    input wire alarm_enable, input wire alarm_ack, input wire show_alarm,
    output wire alarm_out,
    output wire [6:0] seg_n, output wire [3:0] digit_n, output wire dp_n
);
    wire tick_1hz;
    wire [4:0] hours, alarm_hours;
    wire [5:0] minutes, seconds, alarm_minutes;
    clock_divider #(.CLK_HZ(CLK_HZ)) u_divider
      (.clk(clk), .rst_n(rst_n), .tick_1hz(tick_1hz));
    time_counter u_time
      (.clk(clk), .rst_n(rst_n), .tick_1hz(tick_1hz), .set_time(set_time),
       .inc_hour(inc_hour), .inc_min(inc_min), .hours(hours),
       .minutes(minutes), .seconds(seconds));
    alarm_controller u_alarm
      (.clk(clk), .rst_n(rst_n), .hours(hours), .minutes(minutes),
       .set_alarm(set_alarm), .inc_alarm_hour(inc_alarm_hour),
       .inc_alarm_min(inc_alarm_min), .alarm_enable(alarm_enable),
       .alarm_ack(alarm_ack), .alarm_hours(alarm_hours),
       .alarm_minutes(alarm_minutes), .alarm_active(alarm_out));
    seven_seg_driver #(.SCAN_DIV(SCAN_DIV)) u_display
      (.clk(clk), .rst_n(rst_n), .hours(hours), .minutes(minutes),
       .alarm_hours(alarm_hours), .alarm_minutes(alarm_minutes),
       .show_alarm(show_alarm), .seg_n(seg_n), .digit_n(digit_n), .dp_n(dp_n));
endmodule
