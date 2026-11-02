`timescale 1ns/1ps
// 과제10 (MCU->FPGA) + 과제12 (FPGA->FPGA 수신 측):
//  SPI 로 받은 바이트를 LED[7:0] 에 표시하고, 같은 바이트를 UART(9600 8N1)로 PC에 보낸다.
module stm32_3_spi_rx #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD   = 9_600
) (
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire       spi_sck,
    input  wire       spi_mosi,
    input  wire       spi_cs_n,
    output wire       uart_txd,
    output wire [7:0] led
);
    localparam integer DIV = (CLK_HZ + BAUD/2) / BAUD;
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       tx_ready;
    reg        tx_valid;
    reg  [7:0] tx_data;
    reg  [7:0] pend_data;
    reg        pend;
    reg  [7:0] last_data;

    spi_slave_rx u_spi (
        .clk(clk_50mhz), .rst_p(rst_p), .sck(spi_sck), .mosi(spi_mosi),
        .cs_n(spi_cs_n), .data(rx_data), .valid(rx_valid));

    uart_tx #(.DIV(DIV)) u_tx (
        .clk(clk_50mhz), .rst_p(rst_p), .valid(tx_valid), .data(tx_data),
        .ready(tx_ready), .tx(uart_txd));

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            tx_valid <= 1'b0; tx_data <= 8'h00; pend_data <= 8'h00;
            pend <= 1'b0; last_data <= 8'h00;
        end else begin
            tx_valid <= 1'b0;
            if (rx_valid) begin
                last_data <= rx_data;
                pend_data <= rx_data;
                pend      <= 1'b1;
            end
            if (pend && tx_ready && !tx_valid) begin
                tx_data  <= pend_data;
                tx_valid <= 1'b1;
                if (!rx_valid) pend <= 1'b0;
            end
        end
    end
    assign led = last_data;
endmodule
