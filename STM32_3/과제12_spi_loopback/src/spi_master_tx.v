`timescale 1ns/1ps
// SPI Mode 0 master transmitter: CPOL=0, CPHA=0, 8 bit, MSB first, CS active low.
// SCK 주파수 = CLK / (2*HALF).  CLK=50MHz, HALF=50 이면 500kHz (과제 조건 1MHz 이하).
// start 를 1클록 주면 data 를 한 바이트 송신한다. MOSI는 SCK 하강 에지에 바뀌고 상승 에지에 안정.
module spi_master_tx #(
    parameter integer HALF = 50
) (
    input  wire       clk,
    input  wire       rst_p,
    input  wire       start,
    input  wire [7:0] data,
    output wire       busy,
    output reg        sck,
    output reg        mosi,
    output reg        cs_n
);
    localparam [2:0] S_IDLE = 3'd0, S_SETUP = 3'd1, S_HIGH = 3'd2, S_LOW = 3'd3;
    reg [2:0] state;
    reg [7:0] sh;
    reg [3:0] bitno;
    integer   timer;
    assign busy = (state != S_IDLE);

    always @(posedge clk) begin
        if (rst_p) begin
            state <= S_IDLE; sh <= 8'h00; bitno <= 4'd0; timer <= 0;
            sck <= 1'b0; mosi <= 1'b0; cs_n <= 1'b1;
        end else begin
            case (state)
                S_IDLE: begin
                    sck <= 1'b0; mosi <= 1'b0; cs_n <= 1'b1;
                    if (start) begin
                        sh <= data; mosi <= data[7]; cs_n <= 1'b0;
                        bitno <= 4'd0; timer <= HALF - 1; state <= S_SETUP;
                    end
                end
                S_SETUP: begin                       // CS 하강 후 첫 SCK 상승 전 준비 시간
                    if (timer != 0) timer <= timer - 1;
                    else begin sck <= 1'b1; timer <= HALF - 1; state <= S_HIGH; end
                end
                S_HIGH: begin                        // SCK=1, 슬레이브가 샘플링
                    if (timer != 0) timer <= timer - 1;
                    else begin
                        sck <= 1'b0; timer <= HALF - 1; state <= S_LOW;
                        if (bitno != 4'd7) begin
                            sh   <= {sh[6:0], 1'b0};
                            mosi <= sh[6];           // 다음 비트
                        end
                    end
                end
                S_LOW: begin                         // SCK=0, 데이터 안정화
                    if (timer != 0) timer <= timer - 1;
                    else if (bitno == 4'd7) begin
                        cs_n <= 1'b1; mosi <= 1'b0; state <= S_IDLE;
                    end else begin
                        bitno <= bitno + 4'd1; sck <= 1'b1;
                        timer <= HALF - 1; state <= S_HIGH;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
