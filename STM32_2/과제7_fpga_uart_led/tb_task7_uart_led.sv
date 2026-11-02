`timescale 1ns/1ps

module tb_task7_uart_led;
    localparam integer DIV = 8;
    reg clk_50mhz = 0, rst_p = 1, uart_rxd = 1;
    wire uart_txd;
    wire [7:0] led;
    integer checks = 0, i;
    reg [7:0] observed;

    always #10 clk_50mhz = ~clk_50mhz;
    task7_uart_led #(.CLK_HZ(1600), .BAUD(200)) dut (
        .clk_50mhz(clk_50mhz), .rst_p(rst_p), .uart_rxd(uart_rxd),
        .uart_txd(uart_txd), .led(led)
    );

    task send_byte(input [7:0] value);
        begin
            uart_rxd = 0;
            repeat (DIV) @(posedge clk_50mhz);
            for (i = 0; i < 8; i = i + 1) begin
                uart_rxd = value[i];
                repeat (DIV) @(posedge clk_50mhz);
            end
            uart_rxd = 1;
            repeat (DIV) @(posedge clk_50mhz);
        end
    endtask

    task receive_byte(input [7:0] expected);
        begin
            observed = 0;
            @(negedge uart_txd);
            repeat (DIV + DIV / 2) @(posedge clk_50mhz);
            for (i = 0; i < 8; i = i + 1) begin
                observed[i] = uart_txd;
                repeat (DIV) @(posedge clk_50mhz);
            end
            if (observed !== expected)
                $fatal(1, "echo mismatch: received=%02h expected=%02h", observed, expected);
            repeat (DIV) @(posedge clk_50mhz);
        end
    endtask

    task check_command(input [7:0] command, input [7:0] expected_led);
        begin
            fork
                send_byte(command);
                receive_byte(command);
            join
            if (led !== expected_led)
                $fatal(1, "LED mismatch: command=%02h led=%02h expected=%02h", command, led, expected_led);
            if (dut.rx_framing_error)
                $fatal(1, "UART framing error");
            checks = checks + 1;
            $display("PASS command=%c (0x%02h) led=%0d echo=0x%02h", command, command, led[0], observed);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_task7_uart_led);
        repeat (4) @(posedge clk_50mhz);
        rst_p = 0;
        if (led !== 8'h00) $fatal(1, "reset LED state mismatch");
        check_command("1", 8'h01);
        check_command("1", 8'h01);
        check_command("2", 8'h00);
        check_command("2", 8'h01);
        check_command("A", 8'h01);
        check_command("0", 8'h00);
        check_command("2", 8'h01);
        check_command("0", 8'h00);
        $display("LAB6_TASK7_UART_LED_PASS checks=%0d", checks);
        $finish;
    end

    initial begin
        #50000;
        $fatal(1, "timeout");
    end
endmodule
