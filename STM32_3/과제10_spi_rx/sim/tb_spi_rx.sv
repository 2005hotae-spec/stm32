`timescale 1ns/1ps
// 과제10/12 수신 회로 검증: MCU(마스터) 역할을 TB가 하고, LED 와 UART 출력이 일치하는지 확인.
// SCK 1MHz (주기 1000ns), BAUD 는 시뮬레이션용으로 1,000,000 사용 (DIV=50).
module tb_spi_rx;
    reg clk_50mhz = 0, rst_p = 1;
    reg spi_sck = 0, spi_mosi = 0, spi_cs_n = 1;
    wire uart_txd;
    wire [7:0] led;
    always #10 clk_50mhz = ~clk_50mhz;

    stm32_3_spi_rx #(.CLK_HZ(50_000_000), .BAUD(1_000_000)) dut (
        .clk_50mhz(clk_50mhz), .rst_p(rst_p), .spi_sck(spi_sck),
        .spi_mosi(spi_mosi), .spi_cs_n(spi_cs_n), .uart_txd(uart_txd), .led(led));

    wire [7:0] u_data; wire u_valid, u_ferr;
    uart_rx #(.DIV(50)) mon (.clk(clk_50mhz), .rst_p(rst_p), .rx(uart_txd),
        .data(u_data), .valid(u_valid), .framing_error(u_ferr));

    integer errors = 0, checks = 0, n_uart = 0;
    reg [7:0] exp_uart [0:3];
    reg [7:0] got_uart [0:3];

    always @(posedge clk_50mhz) if (u_valid) begin
        if (n_uart < 4) got_uart[n_uart] = u_data;
        n_uart = n_uart + 1;
    end
    always @(posedge clk_50mhz) if (u_ferr) begin
        errors = errors + 1; $display("FAIL: uart framing error");
    end

    task spi_send(input [7:0] b, input integer nbits);
        integer i;
        begin
            spi_cs_n = 0; #500;
            for (i = 7; i > 7 - nbits; i = i - 1) begin
                spi_mosi = b[i]; #500;
                spi_sck = 1;     #500;
                spi_sck = 0;
            end
            #500; spi_cs_n = 1; spi_mosi = 0; #2000;
        end
    endtask

    task expect_led(input [7:0] e);
        begin
            checks = checks + 1;
            if (led !== e) begin
                errors = errors + 1;
                $display("FAIL: led=%h expected=%h", led, e);
            end
        end
    endtask

    initial begin
        exp_uart[0] = 8'hA5; exp_uart[1] = 8'h3C; exp_uart[2] = 8'h81; exp_uart[3] = 8'hFF;
        #200 rst_p = 0; #1000;
        expect_led(8'h00);
        spi_send(8'hA5, 8); #200; expect_led(8'hA5);
        #12000;                                   // UART 한 프레임(10us) 대기
        spi_send(8'h3C, 8); #200; expect_led(8'h3C);
        #12000;
        spi_send(8'hFF, 3); #200; expect_led(8'h3C);   // 3비트만 보내고 CS 해제 -> 무시되어야 함
        spi_send(8'h81, 8); #200; expect_led(8'h81);   // 이후 정상 바이트는 정렬 유지
        #14000;
        if (n_uart !== 3) begin
            errors = errors + 1; $display("FAIL: uart bytes=%0d expected=3", n_uart);
        end
        begin : cmp
            integer k;
            for (k = 0; k < 3; k = k + 1) begin
                checks = checks + 1;
                if (got_uart[k] !== exp_uart[k]) begin
                    errors = errors + 1;
                    $display("FAIL: uart[%0d]=%h expected=%h", k, got_uart[k], exp_uart[k]);
                end
            end
        end
        if (errors == 0) $display("STM32_3_SPI_RX_PASS checks=%0d", checks);
        else             $display("STM32_3_SPI_RX_FAIL errors=%0d", errors);
        $finish;
    end
    initial begin #400000; $display("STM32_3_SPI_RX_FAIL timeout"); $finish; end
endmodule
