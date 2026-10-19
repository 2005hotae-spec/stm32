# FPGA 개별 실습 · STM32_1 주차 (피아노 / 신호등 제어 / ADC)

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
piano/
  piano.v            <- 보드에 올릴 최상위 모듈
  note_select.v      <- 버튼 입력 -> 음 주파수 선택
  square_tone.v       <- 사각파(소리) 생성
  tb_piano.sv         <- 시뮬레이션 전용 테스트벤치

traffic/
  traffic.v           <- 보드에 올릴 최상위 모듈
  second_tick.v        <- 1초 tick과 점멸 기준 신호
  traffic_sequence.v   <- 방향·단계 시퀀스
  traffic_lights.v     <- LED 출력 결정
  tb_traffic.sv        <- 시뮬레이션 전용 테스트벤치

adc/
  adc.v               <- 보드에 올릴 최상위 모듈
  adc_command.v        <- 채널 선택 명령 생성
  serial_frame16.v      <- 16비트 직렬 송수신(SPI 유사)
  tb_adc.sv            <- 시뮬레이션 전용 테스트벤치
```

## 사용 방법

1. **시뮬레이션**: 각 폴더의 `.v` 설계 파일 전체 + `tb_*.sv`를 시뮬레이션
   프로젝트에 추가하고, 시뮬레이션 최상위를 `tb`로 지정해 실행한다.
   `PASS ...` 메시지를 확인한다. (세 실습 모두 테스트벤치 모듈 이름이 `tb`로
   동일하므로 한 번에 한 실습씩만 올린다.)
2. **보드 시연**: `tb_*.sv`를 빼고, 각 폴더의 설계 `.v` 파일만 합성 프로젝트에
   추가한다. 최상위 모듈은 `piano` / `traffic` / `adc`다.

## 보드 핀(XDC)은 포함하지 않음 — 반드시 교재에서 확인할 것

`FPGA_additional.md` 원문대로, **이 자료에는 XDC(핀 제약) 파일이 없다.**
보드 핀은 "장비와 함께 제공된 교재"에서 확인해야 한다 — 이건 이 저장소에도,
내가 가진 자료에도 없는 정보라 추측해서 만들 수 없다.

참고로 모듈별 입출력은 다음과 같다 — 교재의 핀맵표에서 어떤 버튼/스위치/LED/
핀이 이 입출력에 해당하는지 본인이 직접 매칭해야 한다.

| 실습 | 주요 입력 | 주요 출력 | 비고 |
|---|---|---|---|
| piano | `clk_50mhz`, `rst_p`, `key[7:0]`(버튼 8개, HIGH 활성, 안정된 신호) | `piezo`(압전 스피커) | 여러 키 동시 입력 시 무음 |
| traffic | `clk_50mhz`, `rst_p`, `flicker`(점멸 모드 전환 입력) | `led_red/yellow/green/left/walk_red/walk_green`(각 4비트, 4방향) | 출력 1=논리적 켜짐, 실제 LED 극성은 보드 연결 시 맞춰야 함 |
| adc | `clk_50mhz`, `rst_p`, `add_sel[2:0]`(채널 선택), `adc_dout`(ADC MISO) | `adc_sclk/adc_ncs/adc_din`(SPI 유사 제어선), `sample[11:0]`, `data_valid`, `led_out[7:0]` | 실제 ADC 칩과의 SPI 연결은 장비 핀맵 참고, TB는 디지털 직렬 응답만 모델링 |

클록을 사용하는 설계는 전부 `clk_50mhz`(50MHz 보드 클록)와 HIGH 활성 리셋
`rst_p`를 기본 입력으로 쓴다.
