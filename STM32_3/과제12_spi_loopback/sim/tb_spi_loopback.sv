`timescale 1ns/1ps
// 과제12 FPGA->FPGA: 송신 보드(tx)와 수신 보드(rx)를 SCK/MOSI/CS 3선으로 직결하고
// 수신 보드 UART 출력이 A5, A6, A7 인지 확인한다.
module tb_spi_loopback;
    reg clk_a = 0, clk_b = 0, rst_p = 1;
    wire sck, mosi, cs_n, uart_txd;
    wire [7:0] led_tx, led_rx;
    always #10 clk_a = ~clk_a;
    always #10.7 clk_b = ~clk_b;                 // 두 보드 클록은 서로 비동기

    stm32_3_spi_tx #(.HALF(25), .INTERVAL(1500)) tx_board (
        .clk_50mhz(clk_a), .rst_p(rst_p), .spi_sck(sck), .spi_mosi(mosi),
        .spi_cs_n(cs_n), .led(led_tx));
    stm32_3_spi_rx #(.BAUD(1_000_000)) rx_board (
        .clk_50mhz(clk_b), .rst_p(rst_p), .spi_sck(sck), .spi_mosi(mosi),
        .spi_cs_n(cs_n), .uart_txd(uart_txd), .led(led_rx));

    wire [7:0] u_data; wire u_valid, u_ferr;
    uart_rx #(.DIV(50)) mon (.clk(clk_b), .rst_p(rst_p), .rx(uart_txd),
        .data(u_data), .valid(u_valid), .framing_error(u_ferr));

    integer errors = 0, checks = 0, n = 0;
    always @(posedge clk_b) if (u_ferr) begin errors = errors + 1; $display("FAIL: framing"); end
    always @(posedge clk_b) if (u_valid) begin
        checks = checks + 1;
        if (u_data !== (8'hA5 + n)) begin
            errors = errors + 1;
            $display("FAIL: uart byte %0d got %h expected %h", n, u_data, 8'hA5 + n);
        end
        n = n + 1;
    end
    initial begin
        #200 rst_p = 0;
        wait (n == 4);
        #1000;
        checks = checks + 1;
        if (led_rx !== (8'hA5 + 3)) begin errors = errors + 1; $display("FAIL: led_rx=%h", led_rx); end
        if (errors == 0) $display("STM32_3_SPI_LOOP_PASS checks=%0d", checks);
        else             $display("STM32_3_SPI_LOOP_FAIL errors=%0d", errors);
        $finish;
    end
    initial begin #600000; $display("STM32_3_SPI_LOOP_FAIL timeout"); $finish; end
endmodule
