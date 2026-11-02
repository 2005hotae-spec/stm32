`timescale 1ns/1ps

module servo_board #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer DEBOUNCE_CYCLES = CLK_HZ / 100
) (
    input wire clk_50mhz,
    input wire rst_p,
    input wire left_button,
    input wire right_button,
    output wire servo
);
    wire left_pulse, right_pulse;
    button_onepulse #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) u_left (
        .clk_50mhz(clk_50mhz), .rst_p(rst_p),
        .button(left_button), .pulse(left_pulse)
    );
    button_onepulse #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) u_right (
        .clk_50mhz(clk_50mhz), .rst_p(rst_p),
        .button(right_button), .pulse(right_pulse)
    );
    servo_ctrl #(.CLK_HZ(CLK_HZ)) u_ctrl (
        .clk_50mhz(clk_50mhz), .rst_p(rst_p),
        .left_pulse(left_pulse), .right_pulse(right_pulse), .servo(servo)
    );
endmodule
