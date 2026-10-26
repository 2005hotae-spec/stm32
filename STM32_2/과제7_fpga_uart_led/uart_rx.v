`timescale 1ns/1ps
// 9600bps 8N1 UART 수신기. 한 바이트를 완전히 받으면 valid를 한 클록 동안 1로 만든다.
// CLKS_PER_BIT = 클록 주파수 / 보레이트 (50MHz, 9600bps 기준 약 5208).
module uart_rx #(parameter CLKS_PER_BIT = 5208) (
    input  wire clk,
    input  wire rst_p,
    input  wire rx,
    output reg  [7:0] data,
    output reg  valid
);
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOPBIT = 2'd3;

    reg [1:0]  state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  data_buf = 0;

    always @(posedge clk) begin
        if (rst_p) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx == 1'b0)             // 라인은 평소 HIGH, 시작비트는 LOW
                        state <= START;
                end
                START: begin
                    // 시작비트 한가운데에서 다시 확인해 잡음을 걸러낸다.
                    if (clk_count == (CLKS_PER_BIT/2)) begin
                        clk_count <= 0;
                        state <= (rx == 1'b0) ? DATA : IDLE;
                    end else
                        clk_count <= clk_count + 1'b1;
                end
                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        data_buf[bit_index] <= rx;   // LSB 먼저
                        if (bit_index == 3'd7)
                            state <= STOPBIT;
                        else
                            bit_index <= bit_index + 1'b1;
                    end else
                        clk_count <= clk_count + 1'b1;
                end
                STOPBIT: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        data  <= data_buf;
                        valid <= 1'b1;
                        state <= IDLE;
                    end else
                        clk_count <= clk_count + 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
