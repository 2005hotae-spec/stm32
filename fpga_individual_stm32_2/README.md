# FPGA 개별 실습 · STM32_2 주차 (서보모터 제어 / SRAM 읽기·쓰기 / DAC)

이 폴더의 Verilog/SystemVerilog 소스는 `Glaysia/ece2_474` 저장소(태그 `v1.1.0`)의
`docs/FPGA_additional.md`에서 그대로 가져온 것이다(변경 없이 옮김).

저장소 문서 자체의 검증 범위 안내(원문 그대로):
> 검증 범위: Icarus Verilog로 8개 테스트벤치가 모두 PASS했다. Vivado 합성·타이밍
> 확인이나 실제 보드 시연은 아직 수행하지 않았다.

이 세션에는 iverilog가 설치되어 있지 않아 직접 재시뮬레이션은 못 했다 — 코드를
한 글자도 바꾸지 않고 그대로 복사했을 뿐이다. 실제 PASS 확인은 본인 PC/보드의
Vivado(또는 iverilog)에서 직접 돌려봐야 한다.

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

## 보드 핀(XDC)은 포함하지 않음 — 반드시 교재에서 확인할 것

`FPGA_additional.md` 원문대로, **이 자료에는 XDC(핀 제약) 파일이 없다.**
보드 핀은 "장비와 함께 제공된 교재"에서 확인해야 한다 — 이건 이 저장소에도,
내가 가진 자료에도 없는 정보라 추측해서 만들 수 없다.

참고로 모듈별 입출력은 다음과 같다 — 교재의 핀맵표에서 어떤 버튼/스위치/LED/
외부 장치 핀이 이 입출력에 해당하는지 본인이 직접 매칭해야 한다.

| 실습 | 주요 입력 | 주요 출력 | 비고 |
|---|---|---|---|
| servo_ctrl | `clk_50mhz`, `rst_p`, `left_pulse`/`right_pulse`(버튼, 한 클록 길이 펄스) | `servo`(서보모터 PWM 신호선) | 폭 1~2ms, 0.1ms 단위, 20ms 프레임 경계에서만 반영 |
| sram | `clk_50mhz` 불필요(비동기) / `ctrl_w`,`ctrl_r`(읽기·쓰기 요청), `address[3:0]`, `data_in[3:0]` | `ram_cs/ram_oe/ram_we`, `ram_address[17:0]`, `ram_data[15:0]`(inout, 외부 SRAM 버스), `led_out[7:0]` | 동시 읽기·쓰기 요청은 무시, 주소 0~15·데이터 하위 4비트만 사용 |
| dac | `clk_50mhz`, `rst_p`, `add_sel`(채널 선택) | `dac_csn/dac_ldacn/dac_wen/dac_a_b`(DAC 제어선), `dac_d[7:0]`(DAC 데이터 버스), `led_out[7:0]` | 내부 `ramp8`이 0→255 반복 값을 자동 생성해 DAC로 내보냄(데모/검증용) |

클록을 사용하는 설계는 전부 `clk_50mhz`(50MHz 보드 클록)와 HIGH 활성 리셋
`rst_p`를 기본 입력으로 쓴다. `sram`은 조합 로직 위주라 클록 입력이 없다.
