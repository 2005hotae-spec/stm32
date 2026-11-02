`timescale 1ns/1ps
// 과제7 최상위 모듈: UART 수신 + 명령 해석 + LED 출력을 연결한다.
// 기존 LAB3 UART 에코 프로젝트가 이미 있다면, 그 프로젝트의 수신기를
// 재사용하고 led_cmd_decoder만 가져다 붙여도 된다 — 이 파일은 처음부터
// 새로 구성할 때 쓰는 완결형 버전이다.
module uart_led_ctrl #(
    parameter CLK_HZ = 50_000_000,
    parameter BAUD   = 9600
) (
    input  wire clk_50mhz,
    input  wire rst_p,
    input  wire uart_rx,
    output wire led_out
);
    localparam CLKS_PER_BIT = CLK_HZ / BAUD;

    wire [7:0] rx_byte;
    wire       rx_valid;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk_50mhz), .rst_p(rst_p), .rx(uart_rx),
        .data(rx_byte), .valid(rx_valid)
    );

    led_cmd_decoder u_decode (
        .clk(clk_50mhz), .rst_p(rst_p),
        .rx_byte(rx_byte), .rx_valid(rx_valid),
        .led(led_out)
    );
endmodule
