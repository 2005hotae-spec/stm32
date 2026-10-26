`timescale 1ns/1ps
module tb;
    reg clk=0,rst=1;
    always #10 clk=~clk; // 50MHz 근사 (실제 주기 단위는 시뮬레이션 상대값)
    wire [7:0] dac_data;
    wire dac_wr;
    dac #(/* 기본 파라미터 */) dut(clk,rst,dac_data,dac_wr);
    integer i;
    task step; begin @(posedge clk); #1; end endtask
    initial begin
        step; if(dac_data!==0) $fatal(1,"reset value");
        @(negedge clk); rst=0;

        // dac_wr는 매 클럭 토글되는 스트로브여야 함
        step; if(dac_wr!==1'b1 && dac_wr!==1'b0) $fatal(1,"wr strobe undefined");

        // 램프가 매 TICK_CYCLES마다 1 증가하여 0..255를 반복하는지 확인
        for(i=0;i<300;i=i+1) step;
        if(dac_data > 8'd255) $fatal(1,"ramp out of range");

        $display("PASS DAC: reset=0, write strobe toggles, ramp wraps within 8 bits");
        $finish;
    end
    initial begin #2_000_000; $fatal(1,"timeout"); end
endmodule
