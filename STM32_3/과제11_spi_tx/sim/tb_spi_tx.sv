`timescale 1ns/1ps
// 과제11 송신 회로 검증: TB가 MCU(슬레이브) 역할로 Mode0 샘플링을 수행하고
// MSB first, CS 구간, SCK 유휴 low, 바이트 값(A5, A6, A7)을 확인한다.
module tb_spi_tx;
    reg clk_50mhz = 0, rst_p = 1;
    wire spi_sck, spi_mosi, spi_cs_n;
    wire [7:0] led;
    always #10 clk_50mhz = ~clk_50mhz;

    stm32_3_spi_tx #(.CLK_HZ(50_000_000), .HALF(5), .INTERVAL(100), .INIT(8'hA5)) dut (
        .clk_50mhz(clk_50mhz), .rst_p(rst_p), .spi_sck(spi_sck),
        .spi_mosi(spi_mosi), .spi_cs_n(spi_cs_n), .led(led));

    integer errors = 0, checks = 0, nbytes = 0, nbits = 0;
    reg [7:0] cap = 0;
    reg armed = 0;

    always @(negedge spi_cs_n) if (armed) begin
        nbits = 0;
        checks = checks + 1;
        if (spi_sck !== 1'b0) begin errors = errors + 1; $display("FAIL: SCK not low at CS fall"); end
    end
    always @(posedge spi_sck) if (armed) begin
        if (spi_cs_n !== 1'b0) begin errors = errors + 1; $display("FAIL: SCK edge while CS high"); end
        else begin
            cap = {cap[6:0], spi_mosi};
            nbits = nbits + 1;
            if (nbits == 8) begin
                checks = checks + 1;
                if (cap !== (8'hA5 + nbytes)) begin
                    errors = errors + 1;
                    $display("FAIL: byte %0d got %h expected %h", nbytes, cap, 8'hA5 + nbytes);
                end
                nbytes = nbytes + 1;
            end
        end
    end
    always @(posedge spi_cs_n) if (armed) begin
        checks = checks + 1;
        if (nbits !== 8) begin errors = errors + 1; $display("FAIL: %0d clocks in frame", nbits); end
        if (spi_sck !== 1'b0) begin errors = errors + 1; $display("FAIL: SCK high at CS rise"); end
    end

    initial begin
        #100 rst_p = 0; armed = 1;
        wait (nbytes == 3);
        #500;
        checks = checks + 1;
        if (led !== 8'hA7 && led !== 8'hA8) begin errors = errors + 1; $display("FAIL: led=%h", led); end
        if (errors == 0) $display("STM32_3_SPI_TX_PASS checks=%0d", checks);
        else             $display("STM32_3_SPI_TX_FAIL errors=%0d", errors);
        $finish;
    end
    initial begin #200000; $display("STM32_3_SPI_TX_FAIL timeout"); $finish; end
endmodule
