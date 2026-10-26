`timescale 1ns/1ps
// 외부 병렬 8비트 DAC에 0~255 램프 값을 내보내는 top 모듈
module dac(
    input wire clk_50mhz,rst_p,
    output wire [7:0] dac_data,
    output wire dac_wr
);
    wire [7:0] value;
    ramp8 u_ramp(clk_50mhz,rst_p,value);
    dac_parallel8 u_dac(clk_50mhz,rst_p,value,dac_data,dac_wr);
endmodule
