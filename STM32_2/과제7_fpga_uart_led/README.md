# STM32_2_과제7 · UART 명령으로 FPGA LED 제어 (실사용 버전)

이 폴더의 최종 코드는 `task7_uart_led.v` + `uart.v`(uart_rx/uart_tx)다.
VS Code + Icarus Verilog(VaporView)로 직접 시뮬레이션해 PASS를 확인했고
(`evidence/simulation.log`), 실제 XDC(`constraints/task7_uart_led.xdc`)로
보드 핀도 배정했다.

## draft_v1_미사용/ 폴더에 대해

`draft_v1_미사용/`은 이전에 iverilog 없이 작성했던 1차 버전
(uart_rx.v/led_cmd_decoder.v/uart_led_ctrl.v)이다. 명령 해석 로직은
같지만 **UART TX(수신 바이트를 그대로 되돌려 보내는 echo) 기능이 없었다.**
실제로 보드에 올려 쓴 버전은 TX echo까지 포함한 `task7_uart_led.v`이므로,
1차 버전은 참고용으로만 남겨두고 레포트·보드 구현은 이 폴더 최상위
버전을 기준으로 한다.

## 명령표

| 받은 문자 | LED 동작 |
|---|---|
| `0` (0x30) | 끄기 |
| `1` (0x31) | 켜기 |
| `2` (0x32) | 반전 |
| 그 외 | 유지 |

받은 바이트는 LED 제어와 별개로 `uart_txd`를 통해 그대로 되돌려 보낸다
(echo) — MCU/PC 쪽에서 FPGA가 정말 그 바이트를 받았는지 확인할 수 있다.

## 검증

Icarus Verilog로 `tb_task7_uart_led.sv`를 직접 실행해 8개 명령
시퀀스(1,1,2,2,A,0,2,0)에 대해 LED 상태와 echo 바이트가 모두 일치하는
`LAB6_TASK7_UART_LED_PASS checks=8`를 확인했다 (`evidence/simulation.log`).

## 핀 배정 (XDC)

- `clk_50mhz` → B6, `rst_p` → K4
- `uart_rxd` → G10 (MCU PC10과 점퍼선으로 연결하는 확장 GPIO)
- `uart_txd` → F6 (보드 내장 USB-UART, 기존 LAB3 그대로)
- `led[7:0]` → 보드 LED_D1~D8
