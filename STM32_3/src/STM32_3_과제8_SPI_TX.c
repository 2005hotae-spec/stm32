/*
 * STM32_3 과제8 · MCU SPI 송신 (기본 템플릿)
 * 매뉴얼(docs/STM32_3.md) "MCU 송신 측 · 기본 템플릿 사용" 원문 그대로.
 * ece2_474_routine.c 의 polling_routine() 을 이 코드로 교체한다.
 * 타이머·PWM·UART 인터럽트 시작은 이 실습에 필요하지 않다.
 *
 * 용도: 과제8(MCU 송신 파형 확인), 과제9(마스터 보드), 과제10(MCU->FPGA 송신 측)에서
 *       동일 코드를 그대로 사용한다.
 */

void polling_routine(void)
{
    static uint32_t last_ms = 0;
    uint32_t now_ms = HAL_GetTick();
    if (now_ms - last_ms < 1000U) return;
    last_ms = now_ms;

    uint8_t tx = 0x55;
    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port,
                      SPI_CS_ece2_Pin, GPIO_PIN_RESET);
    HAL_StatusTypeDef result =
        HAL_SPI_Transmit(&hspi1, &tx, 1U, 100U);
    HAL_GPIO_WritePin(SPI_CS_ece2_GPIO_Port,
                      SPI_CS_ece2_Pin, GPIO_PIN_SET);

    printf("TX=%02X, result=%d\r\n",
           (unsigned int)tx, (int)result);
}

/* 과제8 진행 시 tx 값을 0x55, 0xA5, 0x00, 0xFF 로 바꿔가며 비교한다. */
