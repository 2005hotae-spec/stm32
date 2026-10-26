`timescale 1ns/1ps
// 입력 8비트 값을 그대로 병렬 DAC 데이터 버스로 내보내고, 매 클럭마다
// 쓰기 스트로브(dac_wr)를 1클럭 폭으로 토글하여 DAC가 새 값을 래치하게 함
module dac_parallel8(
    input wire clk_50mhz,rst_p,
    input wire [7:0] value,
    output reg [7:0] dac_data,
    output reg dac_wr
);
    reg wr_toggle;
    always @(posedge clk_50mhz) begin
        if(rst_p) begin
            dac_data<=8'b0;
            dac_wr<=1'b0;
            wr_toggle<=1'b0;
        end
        else begin
            dac_data<=value;
            wr_toggle<=~wr_toggle;
            dac_wr<=wr_toggle; // 1클럭 하이 / 1클럭 로우로 반복되는 스트로브
        end
    end
endmodule
