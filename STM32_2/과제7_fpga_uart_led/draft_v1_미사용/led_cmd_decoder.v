`timescale 1ns/1ps
// 수신한 바이트를 STM32_2_과제7 명령표대로 해석해 LED 상태를 바꾼다.
//   '0'(0x30) -> 끄기, '1'(0x31) -> 켜기, '2'(0x32) -> 반전, 그 외 -> 유지
module led_cmd_decoder (
    input  wire clk,
    input  wire rst_p,
    input  wire [7:0] rx_byte,
    input  wire rx_valid,
    output reg  led
);
    always @(posedge clk) begin
        if (rst_p)
            led <= 1'b0;
        else if (rx_valid) begin
            case (rx_byte)
                8'h30: led <= 1'b0;
                8'h31: led <= 1'b1;
                8'h32: led <= ~led;
                default: led <= led;
            endcase
        end
    end
endmodule
