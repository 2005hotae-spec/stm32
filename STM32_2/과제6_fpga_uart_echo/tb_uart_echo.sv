`timescale 1ns/1ps

module tb_uart_echo;
localparam integer DIV=8;
reg clk_50mhz=0,rst_p=1,uart_rxd=1;
wire uart_txd;
wire[7:0]led;
integer checks=0,i;
reg[7:0]observed;

always #10 clk_50mhz=~clk_50mhz;
lab3_uart_echo #(.CLK_HZ(1600),.BAUD(200))dut(.clk_50mhz(clk_50mhz),.rst_p(rst_p),.uart_rxd(uart_rxd),.uart_txd(uart_txd),.led(led));

task send_byte(input[7:0]v);
begin
    uart_rxd=0;
    repeat(DIV)@(posedge clk_50mhz);
    for(i=0;i<8;i=i+1)begin
        uart_rxd=v[i];
        repeat(DIV)@(posedge clk_50mhz);
    end
    uart_rxd=1;
    repeat(DIV)@(posedge clk_50mhz);
end
endtask task receive_byte(input[7:0]e);
begin
    observed=0;
    @(negedge uart_txd);
    repeat(DIV+DIV/2)@(posedge clk_50mhz);
    for(i=0;i<8;i=i+1)begin
        observed[i]=uart_txd;
        repeat(DIV)@(posedge clk_50mhz);
    end
    if(observed!==e)$fatal(1);
    if(led!==e)$fatal(1);
    checks=checks+1;
    repeat(DIV)@(posedge clk_50mhz);
end
endtask initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb_uart_echo);
    repeat(4)@(posedge clk_50mhz);
    rst_p=0;
    fork send_byte(8'h31);
    receive_byte(8'h31);
    join fork send_byte(8'h41);
    receive_byte(8'h41);
    join fork send_byte(8'h61);
    receive_byte(8'h61);
    join if(dut.rx_framing_error)$fatal(1);
    $display("LAB6_TASK6_UART_ECHO_PASS checks=%0d",checks);
    $finish;
end

initial begin
    #50000;
    $fatal(1,"timeout");
end

endmodule
