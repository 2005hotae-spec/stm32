# STM32_3 · SPI로 MCU와 FPGA 연결 (LAB7, 2026.11.02 수업, 과제8~12)

매뉴얼: `Glaysia/ece2_474` 저장소 `docs/STM32_3.md`. Mode 0(CPOL=0, CPHA=0), 8비트,
MSB 우선, MOSI만 사용(MISO 미사용)으로 통일.

## 현재 상태 — 실험 전(설계 단계)

이 커밋은 **실험 전 레포트** 시점 기준이다.

- **설계 완료**: FPGA 쪽 3개 모듈(과제10 슬레이브 수신, 과제11 마스터 송신,
  과제12 송수신 결합)과 테스트벤치를 모두 작성했다.
- **시뮬레이션: 아직 미검증.** 테스트벤치(`sim/tb_*.sv`)는 작성됐지만, 이 세션과
  본인 PC 양쪽 모두에서 아직 실행해보지 않았다 — 실행 결과(PASS/FAIL 로그)는
  없다. 실제 랩 전까지 본인 PC(VS Code + Icarus Verilog)로 직접 돌려 확인할
  예정이다.
- **XDC 핀: 미완성(TODO).** `과제10_spi_rx/constraints`, `과제11_spi_tx/constraints`의
  `spi_sck`/`spi_mosi`/`spi_cs_n` 3핀은 주석 처리된 TODO 상태로 남겨뒀다. 실제
  보드 커넥터 핀은 매뉴얼의 FPGA 연결표와 장비 핀맵을 확인해 랩 당일 채울
  예정이다(과제10·11은 자기 조의 MCU-FPGA만 연결, 과제12는 지정된 조끼리
  FPGA-FPGA 연결이므로 핀 배정 전에 역할·배선을 다시 확인해야 한다).
- MCU C 코드(`src/`)는 매뉴얼 제공 템플릿을 그대로 사용했다 — 과제8/9/10/11
  어디서도 MCU 쪽을 직접 작성하지 않는다(매뉴얼이 "Verilog 정답 코드는 제공하지
  않는다"고 명시한 FPGA 쪽과 대비된다).

## 폴더 구성

```
src/
  STM32_3_과제8_SPI_TX.c      <- MCU 송신 템플릿(과제8·9마스터·10 MCU측 공용)
  STM32_3_과제9_11_SPI_RX.c   <- MCU 슬레이브 수신 템플릿(과제9슬레이브·11 MCU측 공용)

과제10_spi_rx/     <- FPGA SPI 슬레이브 수신 (MCU -> FPGA)
  src/spi_slave_rx.v         최상위 아래 수신 로직(CS 동기화, SCK 상승 에지 샘플링)
  src/stm32_3_spi_rx.v       최상위: 받은 바이트 -> LED + UART(9600) 출력
  src/uart.v                 uart_rx/uart_tx (이전 랩과 동일 모듈 재사용)
  sim/tb_spi_rx.sv           TB가 MCU 마스터 역할, LED·UART 결과 검증
  constraints/*.xdc          clk/rst/led/uart_txd만 배정, spi_* 3핀 TODO

과제11_spi_tx/     <- FPGA SPI 마스터 송신 (FPGA -> MCU)
  src/spi_master_tx.v        1초마다 1바이트 송신, SCK<=1MHz
  src/stm32_3_spi_tx.v       최상위: INIT=0xA5부터 1씩 증가, LED에 마지막 송신값
  sim/tb_spi_tx.sv           TB가 MCU 슬레이브 역할, 비트순서·주파수·CS 구간 검증
  constraints/*.xdc          clk/rst/led만 배정, spi_* 3핀 TODO

과제12_spi_loopback/  <- FPGA -> FPGA 송수신 결합 시뮬레이션(보드 2대 가정)
  src/*                      과제10·11 소스를 그대로 합침
  sim/tb_spi_loopback.sv     서로 다른(비동기) 클록의 두 FPGA를 SCK/MOSI/CS로
                             직결해 수신측 UART 출력이 송신값과 일치하는지 검증
```

## 검증 계획

1. 각 폴더의 `tb_*.sv`를 Icarus Verilog로 돌려 PASS 로그를 확보한다
   (`STM32_3_SPI_RX_PASS`, `STM32_3_SPI_TX_PASS`, `STM32_3_SPI_LOOP_PASS`).
2. XDC의 spi_sck/spi_mosi/spi_cs_n 3핀을 실제 핀맵으로 채운다.
3. 랩 당일 과제8(오실로스코프)→과제9(MCU-MCU)→과제10(MCU→FPGA)→과제11
   (FPGA→MCU)→과제12(FPGA→FPGA) 순서로 진행하며 보드 시연 증거를 추가한다.
