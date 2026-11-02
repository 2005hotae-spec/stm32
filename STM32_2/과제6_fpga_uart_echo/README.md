# STM32_2_과제6 · FPGA 쪽 UART 에코 프로젝트 (실사용)

과제6은 매뉴얼이 명시한 대로 MCU C 코드는 새로 만들지 않고, FPGA 쪽은
기존 LAB3 UART 에코 프로젝트(`lab3_uart_echo.v` + `uart.v`)를 그대로
재사용했다. 바뀐 건 XDC의 RX 핀뿐이다 — `constraints/lab3_uart_echo.xdc`에서
`uart_rxd`를 G10(MCU PC10과 점퍼선으로 연결하는 확장 GPIO)으로 재배정했고,
`uart_txd`(F6, 보드 내장 USB-UART)는 그대로 뒀다.

## 검증

Icarus Verilog로 `tb_uart_echo.sv`를 직접 실행해
`LAB6_TASK6_UART_ECHO_PASS checks=3`를 확인했다 (`evidence/simulation.log`).
MCU 쪽은 `STM32_2/evidence/task6_ece2_474_routine.c`를 실제 빌드해
`task6_build.png`(빌드 성공, exit code 0)로 확인했다.

**실제 보드 통신도 성공했다.** `evidence/board_demo.mp4`에서 NUCLEO 보드가
점퍼선으로 FPGA 확장 헤더(G10, `uart_rxd`)에 연결된 상태로 MCU→FPGA UART
통신이 실제로 이루어지는 것을 확인했다(이 영상은 과제7 데모와 같은 연결·같은
MCU 송신 코드를 쓰며, FPGA 쪽엔 당시 과제7용 `task7_uart_led` 설계가 올라가
있었다 — LED 제어 전에 먼저 바이트를 수신해야 하므로 과제6과 동일한 통신
경로가 그대로 쓰인다).
