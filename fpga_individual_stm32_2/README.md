# FPGA 개별 실습 · STM32_2 주차 (서보모터 제어 / SRAM 읽기·쓰기 / DAC)

이 폴더의 Verilog/SystemVerilog 소스는 `Glaysia/ece2_474` 저장소(태그 `v1.1.0`)의
`docs/FPGA_additional.md`에서 그대로 가져온 것이다(변경 없이 옮김).

저장소 문서 자체의 검증 범위 안내(원문 그대로):
> 검증 범위: Icarus Verilog로 8개 테스트벤치가 모두 PASS했다. Vivado 합성·타이밍
> 확인이나 실제 보드 시연은 아직 수행하지 않았다.

이 세션에는 iverilog가 설치되어 있지 않아 직접 재시뮬레이션은 못 했지만,
**본인 PC(VS Code + Icarus Verilog + VaporView)로 직접 돌려 세 실습
모두 PASS를 확인했다.** 각 폴더의 `evidence/simulation.log`(PASS 로그 원문)와
`evidence/wave.png`(파형 스크린샷)가 그 증거다. `constraints/*.xdc`도 장비
핀맵(Xilinx S7 Pin Map.xlsx) 기준으로 실제 작성해 추가했다.

**실제 보드 합성·동작 확인도 완료했다.** 각 폴더의 `evidence/board_demo.mp4`가
실물 보드 시연 영상이다.
- `servo/evidence/board_demo.mp4`: KEY01/KEY03 버튼으로 서보 암이 좌우로
  회전하는 것을 확인.
- `sram/evidence/board_demo.mp4`: DIP 스위치로 주소·데이터를 설정하고
  KEY01(쓰기)/KEY02(읽기)를 눌러 LED_D1~8에 읽은 값이 그대로 나오는 것을 확인.
- `dac/evidence/board_demo.mp4`: `ramp8`이 0~255 값을 자동으로 계속 바꾸며
  LED_D1~8(= `dac_d`)에 그 값이 실시간으로 반영되는 것을 확인(버튼 조작 불필요).

## 폴더 구성

```
servo_ctrl/
  servo_ctrl.v        <- 보드에 올릴 최상위 모듈
  servo_position.v    <- 버튼 입력 -> 목표 펄스 폭(µs) 결정
  servo_pwm.v          <- 20ms 프레임에 맞춘 PWM 펄스 생성
  tb_servo.sv           <- 시뮬레이션 전용 테스트벤치

sram/
  sram.v              <- 보드에 올릴 최상위 모듈
  sram_bus_control.v   <- 읽기/쓰기 신호 -> cs/oe/we 제어
  tb_sram.sv            <- 시뮬레이션 전용 테스트벤치(비동기 SRAM 모델 포함)

dac/
  dac.v               <- 보드에 올릴 최상위 모듈
  dac_parallel8.v      <- 값과 채널을 받아 병렬 DAC 쓰기 펄스 생성
  ramp8.v               <- 0~255 반복 램프 값 생성(테스트/데모용)
  tb_dac.sv             <- 시뮬레이션 전용 테스트벤치
```

## 사용 방법

1. **시뮬레이션**: 각 폴더의 `.v` 설계 파일 전체 + `tb_*.sv`를 시뮬레이션
   프로젝트에 추가하고, 시뮬레이션 최상위를 `tb`로 지정해 실행한다.
   `PASS ...` 메시지를 확인한다. (세 실습 모두 테스트벤치 모듈 이름이 `tb`로
   동일하므로 한 번에 한 실습씩만 올린다.)
2. **보드 시연**: `tb_*.sv`를 빼고, 각 폴더의 설계 `.v` 파일만 합성 프로젝트에
   추가한다. 최상위 모듈은 `servo_ctrl` / `sram` / `dac`다.

## 보드 핀(XDC) — 실제 작성 완료

각 폴더의 `constraints/*.xdc`에 Xilinx S7 Pin Map.xlsx 기준 실제 핀을
배정했다. 서보는 KEY01/KEY03(좌우 버튼)·KEY02(리셋), SRAM은 KEY01/KEY02(쓰기/읽기)·
DIP_SW1~8(주소/데이터)·LED_D1~8·SRAM_A/D/CSN/OEN/WEN, DAC는 KEY01(리셋)·
DIP_SW1(채널)·DAC_CSN/LDACN/WRN/A_B/D0~7·LED_D1~8로 연결했다. 서보는 보드
버튼을 바로 쓰기 위해 `servo_board.v`(최상위) + `button_onepulse.v`(디바운스·
원샷 펄스화)를 추가해 `servo_ctrl`을 감쌌다.

참고로 모듈별 입출력은 다음과 같다.

| 실습 | 주요 입력 | 주요 출력 | 비고 |
|---|---|---|---|
| servo_ctrl | `clk_50mhz`, `rst_p`, `left_pulse`/`right_pulse`(버튼, 한 클록 길이 펄스) | `servo`(서보모터 PWM 신호선) | 폭 1~2ms, 0.1ms 단위, 20ms 프레임 경계에서만 반영 |
| sram | `clk_50mhz` 불필요(비동기) / `ctrl_w`,`ctrl_r`(읽기·쓰기 요청), `address[3:0]`, `data_in[3:0]` | `ram_cs/ram_oe/ram_we`, `ram_address[17:0]`, `ram_data[15:0]`(inout, 외부 SRAM 버스), `led_out[7:0]` | 동시 읽기·쓰기 요청은 무시, 주소 0~15·데이터 하위 4비트만 사용 |
| dac | `clk_50mhz`, `rst_p`, `add_sel`(채널 선택) | `dac_csn/dac_ldacn/dac_wen/dac_a_b`(DAC 제어선), `dac_d[7:0]`(DAC 데이터 버스), `led_out[7:0]` | 내부 `ramp8`이 0→255 반복 값을 자동 생성해 DAC로 내보냄(데모/검증용) |

클록을 사용하는 설계는 전부 `clk_50mhz`(50MHz 보드 클록)와 HIGH 활성 리셋
`rst_p`를 기본 입력으로 쓴다. `sram`은 조합 로직 위주라 클록 입력이 없다.
