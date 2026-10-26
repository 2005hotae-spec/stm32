/*
 * STM32_2_과제5 · PC와 MCU 입출력 확인 (FPGA 연결 불필요)
 *
 * Core/Src/ece2_474_routine.c의 polling_routine()을 아래 내용으로 교체한다.
 * (파일 상단 #include, ece2_474_init(), 각 isr_pN() / HAL_*_Callback은
 *  STM32_0/1 때처럼 그대로 둔다 — 이번에도 polling_routine()만 바꾼다.)
 *
 * PC Serial Monitor 설정: 9600, 8비트, 패리티 없음(None), 정지비트 1.
 * 한 문자만 보낼 때는 Serial Monitor의 "보내기" 줄바꿈 설정을 반드시
 * 없음(None)으로 해야 한다 — 줄바꿈이 섞이면 문자가 2개 들어간 것처럼
 * 처리된다.
 *
 * 확인할 것: '1', 'A', 'a'를 각각 보내면 0x31, 0x41, 0x61이 출력되는지.
 */
void polling_routine(void)
{
    int ch = getchar();  /* 입력이 올 때까지 여기서 기다린다 (blocking). */

    if (ch != EOF)
    {
        uint8_t byte = (uint8_t)ch;
        /* 문자와 그 바이트 값을 16진수로 함께 출력 */
        printf("받은 문자: %c (0x%02X)\r\n", byte, byte);
    }
}
