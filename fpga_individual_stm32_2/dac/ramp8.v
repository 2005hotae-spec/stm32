`timescale 1ns/1ps
// 50MHz 클럭을 느리게 분주하여 0~255 램프(톱니파) 값을 만드는 모듈
module ramp8 #(parameter CLK_HZ=50_000_000,parameter STEP_HZ=1000)(
    input wire clk_50mhz,rst_p,
    output reg [7:0] value
);
    localparam TICK_CYCLES=CLK_HZ/STEP_HZ; // 1kHz마다 1씩 증가 (0->255 반복, 약 256ms 주기)
    reg [31:0] tick_count;
    always @(posedge clk_50mhz) begin
        if(rst_p) begin
            tick_count<=0;
            value<=0;
        end
        else if(tick_count==TICK_CYCLES-1) begin
            tick_count<=0;
            value<=value+1; // 255에서 0으로 자연스럽게 래핑됨
        end
        else begin
            tick_count<=tick_count+1;
        end
    end
endmodule
