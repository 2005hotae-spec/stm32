/*
 * STM32_3 과제9(슬레이브 보드)·과제11(MCU 수신 측) · MCU SPI1 슬레이브 수신
 * 매뉴얼(docs/STM32_3.md) "MCU 수신 측 · SPI1 슬레이브로 변경" 원문 그대로.
 * main.c / CubeMX는 수정하지 않는다. 송신 측은 과제8 템플릿(기본 마스터 설정)을 그대로 쓴다.
 * 수신 측 장치 선택 입력은 PA4(SPI1 NSS)이며, 송신 측 PB6와는 다른 핀이다.
 */

/* ece2_474_routine.c 의 include 아래, 함수 밖에 추가 */
#define SPI_NSS_RX_ece2_Pin       GPIO_PIN_4
#define SPI_NSS_RX_ece2_GPIO_Port GPIOA

/* 수신 측 ece2_474_init() 교체 */
void ece2_474_init(void)
{
    if (HAL_SPI_DeInit(&hspi1) != HAL_OK)
        Error_Handler();

    hspi1.Init.Mode = SPI_MODE_SLAVE;
    hspi1.Init.NSS = SPI_NSS_HARD_INPUT;
    if (HAL_SPI_Init(&hspi1) != HAL_OK)
        Error_Handler();

    GPIO_InitTypeDef gpio = {0};
    gpio.Pin = SPI_NSS_RX_ece2_Pin;
    gpio.Mode = GPIO_MODE_AF_PP;
    gpio.Pull = GPIO_PULLUP;
    gpio.Speed = GPIO_SPEED_FREQ_LOW;
    gpio.Alternate = GPIO_AF5_SPI1;
    HAL_GPIO_Init(SPI_NSS_RX_ece2_GPIO_Port, &gpio);
}

/* 수신 측 polling_routine() 교체 */
void polling_routine(void)
{
    uint8_t rx = 0;
    HAL_StatusTypeDef result =
        HAL_SPI_Receive(&hspi1, &rx, 1U, 2000U);
    if (result == HAL_OK)
    {
        printf("RX=%02X\r\n", (unsigned int)rx);
    }
    else if (result == HAL_TIMEOUT)
    {
        printf("RX timeout: check sender, SCK, MOSI, CS and GND\r\n");
    }
    else
    {
        printf("RX error=%d\r\n", (int)result);
    }
}

/*
 * 수신 측을 먼저 실행해 입력을 기다리게 하고 송신 측(또는 FPGA)을 실행한다.
 * 2초 동안 수신하지 못하면 RX timeout 메시지가 출력된다.
 * 수신 결과는 기존 9600 VCP UART + Serial Monitor로 확인한다.
 *
 * 용도: 과제9(슬레이브 보드), 과제11(MCU가 FPGA로부터 수신)에서 동일 코드를 그대로 사용한다.
 */
