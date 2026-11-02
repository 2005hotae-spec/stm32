`timescale 1ns/1ps

module button_onepulse #(
    parameter integer DEBOUNCE_CYCLES = 500_000
) (
    input wire clk_50mhz,
    input wire rst_p,
    input wire button,
    output reg pulse
);
    reg sync1, sync2, stable;
    reg [31:0] count;

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
            stable <= 1'b0;
            count <= 0;
            pulse <= 1'b0;
        end else begin
            sync1 <= button;
            sync2 <= sync1;
            pulse <= 1'b0;
            if (sync2 == stable) begin
                count <= 0;
            end else if (count == DEBOUNCE_CYCLES - 1) begin
                stable <= sync2;
                count <= 0;
                if (sync2)
                    pulse <= 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
