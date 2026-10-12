/*
 * STM32_0_과제2 · 버튼으로 외부 LED(PB0) 간격 변경
 *
 * 매뉴얼 지시대로 "과제1 코드를 수정"한 것이다 — 과제1을 보드에서 먼저
 * 확인한 뒤, 이 코드로 polling_routine() 전체를 다시 바꿔 넣는다.
 * (과제1과 과제2를 동시에 돌리는 게 아니라, 하나의 polling_routine()을
 *  교체해 가며 순서대로 확인한다 — 매뉴얼의 "과제1 확인 후 과제2로 진행"
 *  문장과 일치한다.)
 *
 * 회로 연결 (매뉴얼 그대로)
 *   PB0 -> 저항(330 Ω~1 kΩ) -> LED 긴 다리(+)
 *   LED 짧은 다리(-) -> 보드 GND
 *
 * 코드 변경점: LED_ece2_Pin / LED_ece2_GPIO_Port 를
 *             GPIO_OUT1_ece2_Pin / GPIO_OUT1_ece2_GPIO_Port (PB0) 로 교체.
 *             PB1을 쓰려면 GPIO_OUT2_ece2_Pin / GPIO_OUT2_ece2_GPIO_Port 로
 *             바꾸면 된다 (main.h에 정의된 이름, 실제 값은 그대로 사용).
 */
void polling_routine(void)
{
    static uint32_t last_ms = 0;
    static GPIO_PinState led_state = GPIO_PIN_RESET;

    static GPIO_PinState previous = GPIO_PIN_RESET;
    static uint32_t last_press_ms = 0;

    static uint32_t interval_ms = 1000U;

    uint32_t now_ms = HAL_GetTick();
    GPIO_PinState current = HAL_GPIO_ReadPin(BUTTON_ece2_GPIO_Port, BUTTON_ece2_Pin);

    if (current == GPIO_PIN_SET && previous == GPIO_PIN_RESET
        && now_ms - last_press_ms >= 200U)
    {
        last_press_ms = now_ms;

        if (interval_ms >= 8000U)
        {
            interval_ms = 1000U;
        }
        else
        {
            interval_ms = interval_ms * 2U;
        }
    }
    previous = current;

    if (now_ms - last_ms >= interval_ms)
    {
        last_ms = now_ms;
        led_state = (led_state == GPIO_PIN_RESET)
                    ? GPIO_PIN_SET : GPIO_PIN_RESET;
        /* 유일한 변경점: 내장 LED(PA5) 대신 외부 LED(PB0)로 출력 */
        HAL_GPIO_WritePin(GPIO_OUT1_ece2_GPIO_Port, GPIO_OUT1_ece2_Pin, led_state);
    }
}
