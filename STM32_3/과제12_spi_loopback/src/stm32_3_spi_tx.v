`timescale 1ns/1ps
// 과제11 (FPGA->MCU) / 과제12 (FPGA->FPGA 송신 측):
//  INTERVAL 클록(기본 1초)마다 SPI 로 1바이트를 보낸다. 값은 INIT 부터 1씩 증가 (A5, A6, A7, ...).
//  LED[7:0] 에는 마지막으로 보낸 값이 표시된다.
module stm32_3_spi_tx #(
    parameter integer CLK_HZ   = 50_000_000,
    parameter integer HALF     = 50,                 // SCK = CLK/(2*HALF) = 500kHz
    parameter integer INTERVAL = 50_000_000,         // 1초 (과제11: 1초마다 한 바이트)
    parameter [7:0]   INIT     = 8'hA5
) (
    input  wire       clk_50mhz,
    input  wire       rst_p,
    output wire       spi_sck,
    output wire       spi_mosi,
    output wire       spi_cs_n,
    output wire [7:0] led
);
    reg  [7:0] tx_byte;
    reg  [7:0] last_sent;
    reg        start;
    integer    wait_cnt;
    wire       busy;

    spi_master_tx #(.HALF(HALF)) u_spi (
        .clk(clk_50mhz), .rst_p(rst_p), .start(start), .data(last_sent),
        .busy(busy), .sck(spi_sck), .mosi(spi_mosi), .cs_n(spi_cs_n));

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            tx_byte <= INIT; last_sent <= INIT; start <= 1'b0; wait_cnt <= 0;
        end else begin
            start <= 1'b0;
            if (wait_cnt < INTERVAL) wait_cnt <= wait_cnt + 1;
            else if (!busy && !start) begin
                start     <= 1'b1;
                last_sent <= tx_byte;
                tx_byte   <= tx_byte + 8'd1;
                wait_cnt  <= 0;
            end
        end
    end
    assign led = last_sent;
endmodule
