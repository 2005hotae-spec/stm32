/*
 * STM32_2_과제6 · MCU에서 FPGA로 보낸 값 확인
 *
 * 흐름: PC → VCP → MCU → 점퍼선 → FPGA → USB-UART → PC
 *
 * 매뉴얼 원문: "위의 MCU 송신 예제를 사용해 PC에서 받은 한 바이트를
 * UART3로 FPGA에 전달한다." — 즉 MCU 쪽 C 코드는 과제5와 달리 새로
 * 짜는 게 아니라, 매뉴얼에 '제공 코드'로 이미 나온 예제를 그대로 쓰는
 * 것이 과제6의 정답이다 (MCU 핀 설정도 제공된 그대로 사용).
 *
 * 이번 과제에서 실제로 손대야 하는 건 C 코드가 아니라 ★FPGA 프로젝트의
 * XDC★ 다:
 *   1. MCU PC10(TX)을 연결할 FPGA 확장 GPIO 핀을 장비 핀맵에서 고른다.
 *   2. 자기 FPGA 프로젝트의 UART 수신 모듈 RX 입력을 그 핀으로 바꾸고,
 *      XDC의 RX PACKAGE_PIN을 그 핀 번호로 수정한다 (LVCMOS33).
 *   3. FPGA TX(F6, 보드 USB-UART)는 그대로 둬도 된다.
 *   4. XDC 수정 후 FPGA 비트스트림을 다시 만들어 보드에 올린다.
 *   5. MCU PC10 → FPGA RX, 그리고 양쪽 GND를 점퍼선으로 연결한다.
 *
 * 확인 방법: PC에는 MCU(VCP)와 FPGA(USB-UART)가 서로 다른 COM 포트로
 * 나타난다. 두 포트를 각각 열어서, MCU 포트로 문자를 보내고 FPGA 포트에서
 * 같은 문자가 나오는지 비교한다. (MCU 쪽 "전송 결과: 0" 출력만으로는
 * 수신 성공을 확인한 게 아니다 — 반드시 FPGA 쪽 출력을 봐야 한다.)
 *
 * Core/Src/ece2_474_routine.c의 polling_routine()을 아래로 교체한다.
 * huart3는 ece2_474.h에 이미 extern 선언돼 있어 추가 선언이 필요 없다.
 */
void polling_routine(void)
{
    int ch = getchar();

    if (ch != EOF)
    {
        uint8_t data = (uint8_t)ch;
        HAL_StatusTypeDef result =
            HAL_UART_Transmit(&huart3, &data, 1U, 100U);

        printf("전송 결과: %d\r\n", (int)result);
        /* 0 = HAL_OK. 과제5에서 쓰던 16진수 출력도 참고용으로 같이 남긴다. */
        printf("보낸 바이트: 0x%02X\r\n", data);
    }
}
