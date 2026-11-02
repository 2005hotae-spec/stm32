`timescale 1ns/1ps
// SPI Mode 0 slave receiver: CPOL=0, CPHA=0, 8 bit, MSB first, CS active low.
// 50MHz 시스템 클록으로 SCK/MOSI/CS를 동기화한 뒤 SCK 상승 에지에서 MOSI를 샘플링한다.
// SCK는 시스템 클록보다 충분히 느려야 한다 (1MHz 이하이면 50MHz의 1/50).
module spi_slave_rx (
    input  wire       clk,
    input  wire       rst_p,
    input  wire       sck,
    input  wire       mosi,
    input  wire       cs_n,
    output reg  [7:0] data,
    output reg        valid      // 1클록 펄스: 8비트 수신 완료
);
    (* ASYNC_REG="TRUE" *) reg [2:0] sck_q;
    (* ASYNC_REG="TRUE" *) reg [2:0] mosi_q;
    (* ASYNC_REG="TRUE" *) reg [2:0] cs_q;
    reg [7:0] shift;
    reg [3:0] cnt;
    wire sck_rise = (sck_q[2:1] == 2'b01);
    wire cs_idle  = cs_q[1];
    wire mosi_s   = mosi_q[1];

    always @(posedge clk) begin
        if (rst_p) begin
            sck_q <= 3'b000; mosi_q <= 3'b000; cs_q <= 3'b111;
            shift <= 8'h00; cnt <= 4'd0; data <= 8'h00; valid <= 1'b0;
        end else begin
            sck_q  <= {sck_q[1:0],  sck};
            mosi_q <= {mosi_q[1:0], mosi};
            cs_q   <= {cs_q[1:0],   cs_n};
            valid  <= 1'b0;
            if (cs_idle) begin
                cnt <= 4'd0;                    // CS가 올라가면 중간에 끊긴 바이트는 버린다
            end else if (sck_rise) begin
                shift <= {shift[6:0], mosi_s};
                if (cnt == 4'd7) begin
                    data  <= {shift[6:0], mosi_s};
                    valid <= 1'b1;
                    cnt   <= 4'd0;
                end else begin
                    cnt <= cnt + 4'd1;
                end
            end
        end
    end
endmodule
