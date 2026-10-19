/*
 * STM32_1_과제3 · STM32_0_과제1을 ISR(인터럽트) 기반으로 재현
 *
 * Core/Src/ece2_474_routine.c에서 아래 순서로 수정한다.
 *   1) 파일 상단, 함수들 바깥에 두 ISR이 함께 쓰는 간격 변수를 선언한다.
 *   2) polling_routine()의 내용을 전부 지워 빈 함수로 되돌린다
 *      (STM32_0_과제1/과제2 때 넣었던 폴링 코드는 이제 쓰지 않는다).
 *   3) button_isr_p7()과 tim6_isr_p4()를 아래 내용으로 교체한다.
 *   4) ece2_474_init()에서 HAL_TIM_Base_Start_IT(&htim6); 줄의 주석(//)을 해제한다.
 *
 * 동작 요약
 *   - 버튼(PC13)을 누르는 순간, 그 디바운스까지 EXTI 인터럽트(button_isr_p7)가
 *     한 번만 처리해 간격을 1->2->4->8->1초로 순환시킨다.
 *   - TIM6는 100 ms마다 tim6_isr_p4()를 호출한다(우선순위 4, 버튼보다 높음).
 *     이 함수가 호출된 횟수를 세어, 선택된 간격만큼 쌓이면 내장 LED(PA5)를 토글한다.
 *   - polling_routine()은 더 이상 버튼이나 시간을 다루지 않는다 — 모든 처리가
 *     ISR 안에서 끝난다.
 */

/* ========== ①: 파일 상단, 다른 함수들보다 위(또는 #include 바로 아래)에 추가 ========== */

/* button_isr_p7()과 tim6_isr_p4()가 함께 참조하는 "현재 선택된 간격"을
 * TIM6 틱(100 ms) 개수로 저장한다. 1000/2000/4000/8000 ms는 각각
 * 10/20/40/80 틱이다. 두 ISR이 서로 다른 우선순위에서 이 값을 읽고 쓰므로
 * volatile을 붙인다 (컴파일러가 최적화로 값을 캐시하지 않도록).
 */
static volatile uint32_t s_interval_steps = 10U;  /* 10 * 100ms = 1000ms, 시작값 */

/* ========== ②: polling_routine()은 빈 함수로 되돌린다 ========== */
/*
void polling_routine(void)
{
}
*/

/* ========== ③: 아래 두 함수로 기존 button_isr_p7 / tim6_isr_p4를 교체 ========== */

/* 1. 사용자 버튼 PC13을 눌렀을 때 호출됩니다. 우선순위: 7. */
static void button_isr_p7(void)
{
    static uint32_t last_ms = 0;
    uint32_t now_ms = HAL_GetTick();

    /* 200 ms 디바운스: 접점 떨림으로 인한 중복 호출을 무시한다. */
    if (now_ms - last_ms >= 200U)
    {
        last_ms = now_ms;

        if (s_interval_steps >= 80U)
        {
            s_interval_steps = 10U;             /* 8초 -> 다시 1초 */
        }
        else
        {
            s_interval_steps = s_interval_steps * 2U;  /* 1->2->4->8초 */
        }
    }
}

/* 2. TIM6를 인터럽트 방식으로 시작하면 100 ms마다 호출됩니다. 우선순위: 4. */
static void tim6_isr_p4(void)
{
    static uint32_t tick_count = 0;

    if (++tick_count >= s_interval_steps)
    {
        tick_count = 0;
        HAL_GPIO_TogglePin(LED_ece2_GPIO_Port, LED_ece2_Pin);
    }
}

/* ========== ④: ece2_474_init() 안에서 아래 줄의 주석을 해제 ========== */
/*
    HAL_TIM_Base_Start_IT(&htim6);
*/
