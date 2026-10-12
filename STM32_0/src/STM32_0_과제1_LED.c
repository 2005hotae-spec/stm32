/*
 * STM32_0_과제1 · 버튼으로 내장 LED(PA5) 간격 변경
 *
 * 이 코드를 Core/Src/ece2_474_routine.c의 기존 polling_routine() 전체와
 * 통째로 바꿔 넣는다. 같은 이름의 함수를 추가로 만들지 않는다.
 * (파일 상단의 #include "ece2_474.h" / #include "main.h" 와
 *  ece2_474_init(), 각 *_isr_pN() 함수, 맨 아래 3개의 HAL_* Callback 함수는
 *  건드리지 않고 그대로 둔다 — 이 블록은 polling_routine() 본문만 교체한다.)
 *
 * 동작 요약
 *  - 버튼(PC13)을 누르는 순간(HIGH 진입 edge)마다 간격이
 *    1000 -> 2000 -> 4000 -> 8000 -> 1000 ms 순서로 바뀐다.
 *  - 버튼을 누르지 않아도 PA5 LED는 현재 간격으로 계속 깜빡인다.
 *  - 버튼을 계속 누르고 있어도(200 ms 디바운스) 간격은 한 번만 바뀐다.
 *
 * 제공 예제 1(1초 간격 LED)과 제공 예제 2(버튼 토글)의 패턴을 그대로 가져와
 * 합쳤다. 두 예제 모두 static 변수로 "마지막 시각"을 기억하는 방식이었으므로,
 * 여기서는 간격 자체를 담는 static 변수(interval_ms)를 하나 더 추가했다.
 */
void polling_routine(void)
{
    /* LED 깜빡임용 상태 (제공 예제 1과 동일한 역할) */
    static uint32_t last_ms = 0;
    static GPIO_PinState led_state = GPIO_PIN_RESET;

    /* 버튼 간격 변경용 상태 (제공 예제 2와 동일한 역할) */
    static GPIO_PinState previous = GPIO_PIN_RESET;
    static uint32_t last_press_ms = 0;

    /* 과제1에서 새로 추가하는 변수: 현재 LED 변경 간격(ms) */
    static uint32_t interval_ms = 1000U;

    uint32_t now_ms = HAL_GetTick();
    GPIO_PinState current = HAL_GPIO_ReadPin(BUTTON_ece2_GPIO_Port, BUTTON_ece2_Pin);

    /* 1) 버튼이 눌리는 순간(현재 SET, 이전 RESET)을 검출해 간격만 바꾼다.
     *    LED 상태(led_state) 자체는 여기서 건드리지 않는다 — 다음 블록의
     *    주기 조건에 따라 알아서 바뀌게 둔다.
     */
    if (current == GPIO_PIN_SET && previous == GPIO_PIN_RESET
        && now_ms - last_press_ms >= 200U)
    {
        last_press_ms = now_ms;

        if (interval_ms >= 8000U)
        {
            interval_ms = 1000U;       /* 8초 다음은 다시 1초로 순환 */
        }
        else
        {
            interval_ms = interval_ms * 2U;  /* 1->2->4->8초 */
        }
    }
    previous = current;

    /* 2) 선택된 interval_ms가 지날 때마다 LED를 토글한다.
     *    버튼을 누르지 않아도 이 블록은 계속 실행되어 LED가 계속 깜빡인다.
     */
    if (now_ms - last_ms >= interval_ms)
    {
        last_ms = now_ms;
        led_state = (led_state == GPIO_PIN_RESET)
                    ? GPIO_PIN_SET : GPIO_PIN_RESET;
        HAL_GPIO_WritePin(LED_ece2_GPIO_Port, LED_ece2_Pin, led_state);
    }
}
