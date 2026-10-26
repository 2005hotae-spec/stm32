`timescale 1ns/1ps
module tb;
    reg clk = 0, rst = 1, rx = 1;
    always #5 clk = ~clk;

    // 시뮬레이션을 빠르게 하려고 CLK_HZ/BAUD를 줄여 CLKS_PER_BIT=4로 만든다.
    wire led;
    uart_led_ctrl #(.CLK_HZ(40), .BAUD(10)) dut (
        .clk_50mhz(clk), .rst_p(rst), .uart_rx(rx), .led_out(led)
    );

    localparam CLKS_PER_BIT = 4;

    task send_byte(input [7:0] b);
        integer i;
        begin
            rx = 1'b0;                              // 시작비트
            repeat (CLKS_PER_BIT) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin
                rx = b[i];                           // LSB 먼저
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            rx = 1'b1;                               // 정지비트
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    initial begin
        repeat (4) @(posedge clk);
        rst = 0;
        repeat (4) @(posedge clk);

        if (led !== 1'b0) $fatal(1, "reset state");

        send_byte(8'h31); #1;                        // '1' -> on
        if (led !== 1'b1) $fatal(1, "'1' should turn LED on");

        send_byte(8'h41); #1;                        // 'A' -> hold
        if (led !== 1'b1) $fatal(1, "unknown byte should hold state");

        send_byte(8'h32); #1;                        // '2' -> toggle
        if (led !== 1'b0) $fatal(1, "'2' should toggle LED off");

        send_byte(8'h32); #1;                        // '2' -> toggle again
        if (led !== 1'b1) $fatal(1, "'2' should toggle LED on");

        send_byte(8'h30); #1;                        // '0' -> off
        if (led !== 1'b0) $fatal(1, "'0' should turn LED off");

        $display("PASS uart_led_ctrl: on/off/toggle/hold via UART command byte");
        $finish;
    end
    initial begin #100000; $fatal(1, "timeout"); end
endmodule
