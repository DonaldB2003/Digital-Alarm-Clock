`timescale 1ns/1ps
module tb_digital_alarm_clock;
    reg clk=0, rst_n=0;
    reg set_time=0, inc_hour=0, inc_min=0;
    reg set_alarm=0, inc_alarm_hour=0, inc_alarm_min=0;
    reg alarm_enable=0, alarm_ack=0, show_alarm=0;
    wire alarm_out; wire [6:0] seg_n; wire [3:0] digit_n; wire dp_n;
    digital_alarm_clock #(.CLK_HZ(4), .SCAN_DIV(2)) dut (.*);
    always #5 clk=~clk;

    task clocks(input integer n); repeat(n) @(posedge clk); endtask
    task press_time_hour; begin
      @(negedge clk); set_time=1; inc_hour=1;
      @(negedge clk); inc_hour=0; set_time=0;
    end endtask
    task press_time_min; begin
      @(negedge clk); set_time=1; inc_min=1;
      @(negedge clk); inc_min=0; set_time=0;
    end endtask
    task press_alarm_min; begin
      @(negedge clk); set_alarm=1; inc_alarm_min=1;
      @(negedge clk); inc_alarm_min=0; set_alarm=0;
    end endtask

    initial begin
      clocks(2); rst_n=1; clocks(1);
      if (dut.hours!==0 || dut.minutes!==0 || dut.seconds!==0) $fatal(1,"reset failed");
      // Verify minute adjustment wraps at 59 (exercise via hierarchical setup).
      @(negedge clk); force dut.u_time.minutes=59; release dut.u_time.minutes;
      press_time_min();
      if (dut.minutes!==0) $fatal(1,"minute wrap failed");
      // Set alarm to 00:01 and advance clock to that minute.
      press_alarm_min(); alarm_enable=1;
      @(negedge clk); force dut.u_time.minutes=0; release dut.u_time.minutes;
      clocks(4*60+2);
      if (dut.minutes!==1 || !alarm_out) $fatal(1,"alarm did not trigger at 00:01");
      alarm_ack=1; @(negedge clk); alarm_ack=0;
      if (alarm_out) $fatal(1,"alarm acknowledge failed");
      if (seg_n===7'bxxxxxxx || digit_n===4'bxxxx) $fatal(1,"display unknown");
      $display("PASS: reset, minute wrap, alarm trigger/acknowledge, display outputs");
      $finish;
    end
    initial begin #200000; $fatal(1,"testbench timeout"); end
endmodule
