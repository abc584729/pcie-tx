/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "cmsis_os.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
osThreadId PowerOnTaskHandle;
osThreadId KeyMonitorTaskHandle;
osThreadId HardOffTaskHandle;
osThreadId SoftOffTaskHandle;
/* USER CODE BEGIN PV */
typedef enum
{
    KEY_IDLE = 0,
    KEY_PRESSED
} key_state_t;

typedef struct
{
    key_state_t state;
    uint32_t    press_time;
} key_ctrl_t;

typedef struct
{
    GPIO_PinState last_pin;
    uint32_t      idle_time;
    uint8_t       stable_cnt;
} wdt_ctrl_t;

/* System power state, shared between tasks. Every transition is written
   by the task that owns it. */
typedef enum
{
    PWR_ST_OFF = 0,     /* everything off, waiting for a power-on request */
    PWR_ST_UP,          /* power-up sequence running */
    PWR_ST_ON,          /* up and running */
    PWR_ST_DOWN,        /* power-down sequence running */
    PWR_ST_FAULT        /* power-up sequence failed */
} pwr_state_t;

#define KEY_SCAN_TIME_MS      20

#define PWR_SHORT_MS          100
#define PWR_LONG_MS           4000

#define RST_LONG_MS           1000

#define WDT_TIMEOUT_MS        5000   
#define WDT_STABLE_CNT        2       

/* Power-down sequencing */
#define PWRBTN_GRACEFUL_MS       300  /* short PWRBTN# pulse: ask the OS to stop */
#define GRACEFUL_STOP_TIMEOUT_MS 20000 /* max wait for the OS to shut down by itself */
#define HARD_OFF_BTN_MS       4000    /* PWRBTN# hold that forces the x86 off */
#define HOST_STOP_TIMEOUT_MS  6000    /* max wait for SUS_S3# after the forced hold */
#define RFSOC_QUIESCE_MS      100     /* let PROG_B settle before cutting power */

#define WAIT_PIN_POLL_MS       10     /* poll period for every pin handshake */
#define FAULT_BLINK_MS        250     /* half period of the FAULT indicator */

/* Handshake timeouts. These are STARTING POINTS, not measured values: each
   one has to be confirmed against the real board before they can be
   trusted. See the notes in the plan for how to measure each of them. */
#define RFSOC_DISCHARGE_MS    10000   /* power-down: PWRGOOD_RFSOC high -> low */
#define PRECOND_TIMEOUT_MS     3000   /* power-up backstop, unclean start only */
#define PSU_SETTLE_MS         10000   /* RUN_PWR_X86 high -> PWRGOOD_RFSOC high */
#define RFSOC_RESET_HOLD_MS     200   /* Zynq PS POR minimum pulse width */
#define RFSOC_BOOT_TIMEOUT_MS 30000   /* RESETN_RFSOC release -> PS_DONE high */
#define HOST_S5_TIMEOUT_MS      500   /* power-up: is the module sitting in S5? */
#define HOST_S0_TIMEOUT_MS    15000   /* PWRBTN# press -> SUS_S3# high */

/* Stage numbers for g_last_fail_step. Watch it in the debugger to find out
   which handshake gave up. */
#define STEP_PRECOND              1
#define STEP_RFSOC_PWRGOOD        2
#define STEP_RFSOC_PSDONE         3
#define STEP_HOST_S5              4
#define STEP_HOST_S0              5

/* Written by whichever task owns the transition, read by SoftOffTask on
   every poll -- volatile because the Release build compiles with -Os. */
volatile pwr_state_t g_pwr_state = PWR_ST_OFF;
volatile uint8_t is_wdt_detect_enabled = 0;

/* Set when a power-down could not confirm that the RFSoC rail had
   discharged. The next power-up then checks the preconditions instead of
   trusting that the handshake signals start from their inactive level. */
volatile uint8_t g_pwr_unclean = 0;
volatile uint8_t g_last_fail_step = 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
void PowerOnTask_init(void const * argument);
void KeyMonitorTask_init(void const * argument);
void HardOffTask_init(void const * argument);
void SoftOffTask_init(void const * argument);

/* USER CODE BEGIN PFP */

static uint8_t wait_pin_level(GPIO_TypeDef *port, uint16_t pin,
                              GPIO_PinState want, uint32_t timeout_ms);
static uint8_t wait_pin_high(GPIO_TypeDef *port, uint16_t pin, uint32_t timeout_ms);
static uint8_t wait_pin_low(GPIO_TypeDef *port, uint16_t pin, uint32_t timeout_ms);

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/**
  * @brief  Poll a pin until it reaches a level, giving up after a timeout.
  * @retval 1 = the level was reached, 0 = timed out.
  *
  * A timed-out handshake is never something to spin on: the caller decides
  * what a timeout means. The RFSoC-side stages treat it as a fault and stop
  * the sequence; the two SUS_S3# checks only record it, because whether that
  * signal is readable on this board has not been measured yet.
  */
static uint8_t wait_pin_level(GPIO_TypeDef *port, uint16_t pin,
                              GPIO_PinState want, uint32_t timeout_ms)
{
	uint32_t waited = 0;

	while (HAL_GPIO_ReadPin(port, pin) != want)
	{
		if (waited >= timeout_ms)
		{
			return 0;
		}
		osDelay(WAIT_PIN_POLL_MS);
		waited += WAIT_PIN_POLL_MS;
	}
	return 1;
}

static uint8_t wait_pin_high(GPIO_TypeDef *port, uint16_t pin, uint32_t timeout_ms)
{
	return wait_pin_level(port, pin, GPIO_PIN_SET, timeout_ms);
}

static uint8_t wait_pin_low(GPIO_TypeDef *port, uint16_t pin, uint32_t timeout_ms)
{
	return wait_pin_level(port, pin, GPIO_PIN_RESET, timeout_ms);
}

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* USER CODE BEGIN RTOS_MUTEX */
  /* add mutexes, ... */
  /* USER CODE END RTOS_MUTEX */

  /* USER CODE BEGIN RTOS_SEMAPHORES */
  /* add semaphores, ... */
  /* USER CODE END RTOS_SEMAPHORES */

  /* USER CODE BEGIN RTOS_TIMERS */
  /* start timers, add new ones, ... */
  /* USER CODE END RTOS_TIMERS */

  /* USER CODE BEGIN RTOS_QUEUES */
  /* add queues, ... */
  /* USER CODE END RTOS_QUEUES */

  /* Create the thread(s) */
  /* definition and creation of PowerOnTask */
  osThreadDef(PowerOnTask, PowerOnTask_init, osPriorityNormal, 0, 128);
  PowerOnTaskHandle = osThreadCreate(osThread(PowerOnTask), NULL);

  /* definition and creation of KeyMonitorTask */
  osThreadDef(KeyMonitorTask, KeyMonitorTask_init, osPriorityNormal, 0, 128);
  KeyMonitorTaskHandle = osThreadCreate(osThread(KeyMonitorTask), NULL);

  /* definition and creation of HardOffTask */
  osThreadDef(HardOffTask, HardOffTask_init, osPriorityNormal, 0, 128);
  HardOffTaskHandle = osThreadCreate(osThread(HardOffTask), NULL);

  /* definition and creation of SoftOffTask */
  osThreadDef(SoftOffTask, SoftOffTask_init, osPriorityNormal, 0, 128);
  SoftOffTaskHandle = osThreadCreate(osThread(SoftOffTask), NULL);

  /* USER CODE BEGIN RTOS_THREADS */
  /* add threads, ... */
  /* USER CODE END RTOS_THREADS */

  /* Start scheduler */
  osKernelStart();

  /* We should never get here as control is now taken by the scheduler */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI_DIV2;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL16;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

   /* Active low signals */
  HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_SET);
  HAL_GPIO_WritePin(PWR_BTN_X86_GPIO_Port, PWR_BTN_X86_Pin, GPIO_PIN_SET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, PWR_OK_X86_Pin|RESET_X86_Pin|GPI0_COME_Pin
                          |GPI1_COME_Pin|RUN_PWR_X86_Pin|RUN_PWR_RFSOC_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, RESETN_RFSOC_Pin|LED1_FRONTPANEL_PWR_Pin|LED2_FRONTPANEL_PWR_Pin|LED3_FRONTPANEL_PWR_Pin
                          |LED4_FRONTPANEL_PWR_Pin|LED5_FRONTPANEL_PWR_Pin|LED6_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pins : PWRBTN_EXT_Pin RSTBTN_EXT_Pin */
  GPIO_InitStruct.Pin = PWRBTN_EXT_Pin|RSTBTN_EXT_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pins : SUS_S5_Pin SUS_S3_Pin WDT_Pin GPO0_COME_Pin
                           GPO1_COME_Pin T_ALARM_PWR_Pin */
  GPIO_InitStruct.Pin = SUS_S5_Pin|SUS_S3_Pin|WDT_Pin|GPO0_COME_Pin
                          |GPO1_COME_Pin|T_ALARM_PWR_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PWR_OK_X86_Pin PWR_BTN_X86_Pin RESET_X86_Pin GPI0_COME_Pin
                           GPI1_COME_Pin RUN_PWR_X86_Pin RUN_PWR_RFSOC_Pin */
  GPIO_InitStruct.Pin = PWR_OK_X86_Pin|PWR_BTN_X86_Pin|RESET_X86_Pin|GPI0_COME_Pin
                          |GPI1_COME_Pin|RUN_PWR_X86_Pin|RUN_PWR_RFSOC_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PWRGOOD_RFSOC_Pin PS_DONE_Pin */
  GPIO_InitStruct.Pin = PWRGOOD_RFSOC_Pin|PS_DONE_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : RESETN_RFSOC_Pin LED1_FRONTPANEL_PWR_Pin LED2_FRONTPANEL_PWR_Pin LED3_FRONTPANEL_PWR_Pin
                           LED4_FRONTPANEL_PWR_Pin LED5_FRONTPANEL_PWR_Pin LED6_FRONTPANEL_PWR_Pin PS_PROG_B_Pin */
  GPIO_InitStruct.Pin = RESETN_RFSOC_Pin|LED1_FRONTPANEL_PWR_Pin|LED2_FRONTPANEL_PWR_Pin|LED3_FRONTPANEL_PWR_Pin
                          |LED4_FRONTPANEL_PWR_Pin|LED5_FRONTPANEL_PWR_Pin|LED6_FRONTPANEL_PWR_Pin|PS_PROG_B_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */
/**
* @brief Function implementing the KeyMonitorTask thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE BEGIN Header_KeyMonitorTask_init */
void KeyMonitorTask_init(void const *argument)
{
    key_ctrl_t pwr_key = {KEY_IDLE, 0};
    key_ctrl_t rst_key = {KEY_IDLE, 0};

    wdt_ctrl_t wdt = {
        .last_pin   = GPIO_PIN_RESET,
        .idle_time  = 0,
        .stable_cnt = 0
    };

    for (;;)
    {
        /* ===================== PWR BTN ===================== */
        if (HAL_GPIO_ReadPin(RSTBTN_EXT_GPIO_Port, RSTBTN_EXT_Pin) == GPIO_PIN_RESET)
        {
            if (pwr_key.state == KEY_IDLE)
            {
                pwr_key.state = KEY_PRESSED;
                pwr_key.press_time = 0;
            }
            else
            {
                pwr_key.press_time += KEY_SCAN_TIME_MS;
            }
        }
        else
        {
            if (pwr_key.state == KEY_PRESSED)
            {
                if (pwr_key.press_time >= PWR_LONG_MS)
                    osSignalSet(HardOffTaskHandle, 0x03);
                else if (pwr_key.press_time >= PWR_SHORT_MS)
                    osSignalSet(PowerOnTaskHandle, 0x01);

                pwr_key.state = KEY_IDLE;
                pwr_key.press_time = 0;
            }
        }

        /* ===================== RST BTN ===================== */
        if (HAL_GPIO_ReadPin(PWRBTN_EXT_GPIO_Port, PWRBTN_EXT_Pin) == GPIO_PIN_RESET)
        {
            if (rst_key.state == KEY_IDLE)
            {
                rst_key.state = KEY_PRESSED;
                rst_key.press_time = 0;
            }
            else
            {
                rst_key.press_time += KEY_SCAN_TIME_MS;
            }
        }
        else
        {
            if (rst_key.state == KEY_PRESSED)
            {
                if (rst_key.press_time >= RST_LONG_MS)
                {
//                    /* Reset PS */
//                    HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_RESET);
//                    osDelay(50);
//                    HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_SET);

                    /* Reset X86 */
                    HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);
                    osDelay(50);
                    HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_SET);
                }

                rst_key.state = KEY_IDLE;
                rst_key.press_time = 0;
            }
        }

//        /* ===================== WDT PIN MONITOR ===================== */
//        GPIO_PinState cur_wdt = HAL_GPIO_ReadPin(WDT_GPIO_Port, WDT_Pin);
//        if(is_wdt_detect_enabled)
//        {
//          if (cur_wdt != wdt.last_pin)
//          {
//            wdt.stable_cnt++;
//            if (wdt.stable_cnt >= WDT_STABLE_CNT)
//            {
//                /* Dog is feed */
//                wdt.last_pin  = cur_wdt;
//                wdt.idle_time = 0;
//                wdt.stable_cnt = 0;
//            }
//          }
//          else
//          {
//            wdt.stable_cnt = 0;
//            wdt.idle_time += KEY_SCAN_TIME_MS;
//
//            if (wdt.idle_time >= WDT_TIMEOUT_MS)
//            {
//                /* Watch dog time out, Reset X86 */
//                HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);
//                osDelay(50);
//                HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_SET);
//
//                /* Clear WDT idle time */
//                wdt.idle_time = 0;
//            }
//          }
//        }
//        else
//        {
//            wdt.last_pin = GPIO_PIN_RESET;
//            wdt.idle_time = 0;
//            wdt.stable_cnt = 0;
//        }
        osDelay(KEY_SCAN_TIME_MS);
    }
}
/* USER CODE END Header_KeyMonitorTask_init */
/* USER CODE BEGIN Header_PowerOnTask_init */
/**
  * @brief  Function implementing the PowerOnTask thread.
  * @param  argument: Not used
  * @retval None
  */
/* USER CODE END Header_PowerOnTask_init */
void PowerOnTask_init(void const * argument)
{
  /* USER CODE BEGIN PowerOnTask_init */
  uint32_t PL_INITIALIZATION_TIME = 30000;
  uint32_t BTN_PRESS_TIME = 1000;
  //uint32_t WAIT_EXTERNAL_POWER_ON = 5000;
  uint32_t WAIT_SYS_START = 10000;
  uint8_t fault_blink = 0;
  /* Infinite loop */
  for(;;)
  {
	  osEvent evt;
	  uint32_t wait_ms;

	  /* In FAULT the wait is finite so the panel LED can blink the fault
	     code; the rest of the time block until a key event arrives. */
	  wait_ms = (g_pwr_state == PWR_ST_FAULT) ? FAULT_BLINK_MS : osWaitForever;
	  evt = osSignalWait(0x01, wait_ms);

	  if (g_pwr_state == PWR_ST_FAULT)
	  {
		  fault_blink ^= 1;
		  HAL_GPIO_WritePin(GPIOB, LED4_FRONTPANEL_PWR_Pin,
		                    fault_blink ? GPIO_PIN_SET : GPIO_PIN_RESET);
	  }

	  if (evt.status == osEventSignal)
	  {
		  /* Only a fully powered-off system may be powered up again. A short
		     press while up / powering up / powering down is dropped: without
		     this guard the whole sequence re-runs on a live system, and the
		     1s PWRBTN# pulse further down shuts the running x86 down. */
		  if (g_pwr_state == PWR_ST_ON ||
		      g_pwr_state == PWR_ST_UP ||
		      g_pwr_state == PWR_ST_DOWN)
		  {
			  continue;
		  }

		  g_last_fail_step = 0;
		  HAL_GPIO_WritePin(GPIOB, LED4_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
		  g_pwr_state = PWR_ST_UP;

		  /* The first step is not "apply power", it is "hold every
		     downstream device in reset", so nothing comes up half
		     configured while the rails are still ramping. */
		  HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);
		  HAL_GPIO_WritePin(GPIOA, PWR_OK_X86_Pin, GPIO_PIN_RESET);
		  HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_RESET);
		  HAL_GPIO_WritePin(RESETN_RFSOC_GPIO_Port, RESETN_RFSOC_Pin, GPIO_PIN_RESET);

		  /* Backstop for a power-down that could not confirm the rails had
		     discharged. Normally g_pwr_unclean is 0 and this costs nothing:
		     the power-down paths already waited the discharge out while
		     nobody was watching. Only when that failed do we refuse to
		     trust the handshake signals here. */
		  if (g_pwr_unclean != 0)
		  {
			  if (wait_pin_low(PWRGOOD_RFSOC_GPIO_Port, PWRGOOD_RFSOC_Pin, PRECOND_TIMEOUT_MS) == 0 ||
			      wait_pin_low(PS_DONE_GPIO_Port, PS_DONE_Pin, PRECOND_TIMEOUT_MS) == 0)
			  {
				  g_last_fail_step = STEP_PRECOND;
				  goto power_fail;
			  }
			  g_pwr_unclean = 0;
		  }

		  /* Enable External Power Supply */
		  HAL_GPIO_WritePin(GPIOA, RUN_PWR_X86_Pin, GPIO_PIN_SET);

	  	  /* Entering RFSOC Power up sequence */
	  	  /* Power RFSOC */
	  	  HAL_GPIO_WritePin(RUN_PWR_RFSOC_GPIO_Port, RUN_PWR_RFSOC_Pin, GPIO_PIN_SET);

	  	  /* Wait until RFSOC Power good. This doubles as the PSU ramp wait:
	  	     RUN_PWR_X86 was raised two writes ago with nothing in between,
	  	     so a cold start relies on this loop to cover the ramp. It is
	  	     trustworthy here because the rail is guaranteed to have been
	  	     left discharged -- see g_pwr_unclean above. */
	  	  if (wait_pin_high(PWRGOOD_RFSOC_GPIO_Port, PWRGOOD_RFSOC_Pin, PSU_SETTLE_MS) == 0)
	  	  {
	  		  g_last_fail_step = STEP_RFSOC_PWRGOOD;
	  		  goto power_fail;
	  	  }

	  	  /* RFSOC Power good */
	  	  HAL_GPIO_WritePin(GPIOB, LED1_FRONTPANEL_PWR_Pin, GPIO_PIN_SET);

	  	  /* Hold the reset for a known minimum before releasing it. This is
	  	     what turns "release the reset and hope" into a deterministic
	  	     POR pulse, so that PS_DONE going high below is a real 0->1 edge
	  	     rather than a level that was left over from the last session. */
	  	  osDelay(RFSOC_RESET_HOLD_MS);

	  	  /* Release PROG_B first. The power-down sequences assert it to
	  	     clear the PL, so it has to be de-asserted before the reset is
	  	     released or the PL stays unconfigured. */
	  	  HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_SET);

	  	  /* Release RFSOC Reset to enable Power On Reset*/
	  	  HAL_GPIO_WritePin(RESETN_RFSOC_GPIO_Port, RESETN_RFSOC_Pin, GPIO_PIN_SET);

	  	  /* Wait until PS Done */
	  	  if (wait_pin_high(PS_DONE_GPIO_Port, PS_DONE_Pin, RFSOC_BOOT_TIMEOUT_MS) == 0)
	  	  {
	  		  g_last_fail_step = STEP_RFSOC_PSDONE;
	  		  goto power_fail;
	  	  }

	  	  /* When PS DONE, Turn on LED 6 */
	  	  HAL_GPIO_WritePin(GPIOB, LED6_FRONTPANEL_PWR_Pin, GPIO_PIN_SET);

	  	  /* Wait PL initialization */
//	  	  osDelay(PL_INITIALIZATION_TIME);


	  	  /* Entering X86 Power up sequence */
	  	  /* The module has to be in S5 before the button is pressed. Without
	  	     this, a SUS_S3# left high by the previous session makes the
	  	     wait below pass instantly and PWR_OK_X86 gets asserted before
	  	     the module is actually up. */
	  	  if (wait_pin_low(GPIOA, SUS_S3_Pin, HOST_S5_TIMEOUT_MS) == 0)
	  	  {
	  		  /* Warning only, deliberately not fatal. If SUS_S3# cannot be
	  		     read at all on this board -- GPIO_NOPULL on a net whose
	  		     driver is unpowered -- then failing here would break the
	  		     cold boot that works today. Record the stage and carry on
	  		     the way the old code did; watch g_last_fail_step to find
	  		     out which of the two it actually is. */
	  		  g_last_fail_step = STEP_HOST_S5;
	  	  }

	  	  /* Push X86 Power Button for 1s*/
	  	  HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_RESET);
	  	  osDelay(BTN_PRESS_TIME);
	  	  HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_SET);

	  	  /* Wait until SUS_S3_Pin is released */
	  	  if (wait_pin_high(GPIOA, SUS_S3_Pin, HOST_S0_TIMEOUT_MS) == 0)
	  	  {
	  		  /* Warning only, same reasoning as the S5 check above. The x86
	  		     side is the one that does not lock the system out today, so
	  		     it keeps that behaviour until the signal is measured. */
	  		  g_last_fail_step = STEP_HOST_S0;
	  	  }

	  	  /* Send Power OK Signal to X86 */
	  	  HAL_GPIO_WritePin(GPIOA, PWR_OK_X86_Pin, GPIO_PIN_SET);

	  	  /* X86 BIOS Starts */
	  	  HAL_GPIO_WritePin(GPIOB, LED3_FRONTPANEL_PWR_Pin, GPIO_PIN_SET);

//	  	  HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_RESET);
//	  	  osDelay(30000);
//	  	  HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_SET);

//	      /* Reset X86  */
//	  	  HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_SET);
//	  	  osDelay(50);
//	      HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);

	  	  /* X86 is up: allow soft-off detection */
	  	  g_pwr_state = PWR_ST_ON;

		  /* Wait X86 System Boots */
          osDelay(WAIT_SYS_START);

          /* Enable WDT detection */
          is_wdt_detect_enabled = 1;
		  continue;
	  }

	  continue;

power_fail:
	  /* A power-up stage was not reached in time. Do NOT leave the system
	     half powered: an x86 that POSTs against a PL that never got
	     configured is exactly the "screen comes up, then it hangs"
	     failure this sequence has to avoid. Cut everything and park in
	     FAULT with the front panel LED off; the next press retries. */
	  HAL_GPIO_WritePin(GPIOA, PWR_OK_X86_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(GPIOA, RUN_PWR_X86_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(RESETN_RFSOC_GPIO_Port, RESETN_RFSOC_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(RUN_PWR_RFSOC_GPIO_Port, RUN_PWR_RFSOC_Pin, GPIO_PIN_RESET);

	  HAL_GPIO_WritePin(GPIOB, LED1_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(GPIOB, LED3_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
	  HAL_GPIO_WritePin(GPIOB, LED6_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);

	  is_wdt_detect_enabled = 0;
	  g_pwr_state = PWR_ST_FAULT;
  }
}
/* USER CODE BEGIN Header_HardOffTask_init */
/**
* @brief Function implementing the HardOffTask thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_HardOffTask_init */
void HardOffTask_init(void const * argument)
{
	/* USER CODE BEGIN PowerDownTask_init */
	/* Infinite loop */
	for(;;)
	{
		osEvent evt = osSignalWait(0x03, osWaitForever);
		if (evt.status == osEventSignal)
		{
			/* Power-up order is RFSOC then X86, so power-down has to be the
			   reverse: the x86 stops first, and the RFSOC -- which is the
			   x86's PCIe endpoint -- is the last thing to lose power. */
			g_pwr_state = PWR_ST_DOWN;
			is_wdt_detect_enabled = 0;

			/* Ask the x86 to shut down the polite way first. A short PWRBTN#
			   pulse is a normal power-button event, and the OS answers it with
			   a clean shutdown. Holding the button instead crosses the ATX
			   forced-off threshold (>= 4s), which cuts the rail while the OS is
			   still shutting down -- a guaranteed unclean stop, and that is what
			   leaves the next boot hanging at the desktop.
			   The RFSOC must stay alive for the whole of this, otherwise the x86
			   is left running with an already dead PCIe endpoint. */
			HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_RESET);
			osDelay(PWRBTN_GRACEFUL_MS);
			HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_SET);

			/* SUS_S3# dropping is the module telling us it is in S5, i.e. the
			   OS finished shutting down on its own. */
			if (wait_pin_low(SUS_S3_GPIO_Port, SUS_S3_Pin, GRACEFUL_STOP_TIMEOUT_MS) == 0)
			{
				   /* No answer: the OS is hung. Only now fall back to the 4s hold,
				      which is the ATX override that cuts the power whatever the OS
				      is doing. */
				HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_RESET);
				osDelay(HARD_OFF_BTN_MS);
				HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_SET);

				/* Wait until X86 is ready to be shut down, active low */
				wait_pin_low(SUS_S3_GPIO_Port, SUS_S3_Pin, HOST_STOP_TIMEOUT_MS);
			}

			/* Hold the x86 in reset as well: if it did not stop within the
			   timeout above, this at least stops it issuing PCIe traffic. */
			HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);

			/* Only now let the PCIe endpoint disappear. Clear the PL first
			   (PROG_B is active low) so the link goes down cleanly and the GT
			   lanes are tri-stated, then cut its power. */
			HAL_GPIO_WritePin(RESETN_RFSOC_GPIO_Port, RESETN_RFSOC_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_RESET);
			osDelay(RFSOC_QUIESCE_MS);
			HAL_GPIO_WritePin(RUN_PWR_RFSOC_GPIO_Port, RUN_PWR_RFSOC_Pin, GPIO_PIN_RESET);

			/* Disable X86 PWR OK, then cut external power supply */
			HAL_GPIO_WritePin(GPIOA, PWR_OK_X86_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(RUN_PWR_X86_GPIO_Port, RUN_PWR_X86_Pin, GPIO_PIN_RESET);

			/* Disable LED panel lights*/
			HAL_GPIO_WritePin(GPIOB, LED1_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOB, LED2_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOB, LED3_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOB, LED6_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);

			/* Now wait for the rail to actually collapse before calling it
			   OFF. This wait is free -- the machine is already off and
			   nobody is waiting on it -- and it is what lets the next
			   power-up trust that PWRGOOD_RFSOC starts from low. If the rail
			   does not collapse we remember it and the next power-up checks
			   the preconditions instead of trusting the signal. */
			if (wait_pin_low(PWRGOOD_RFSOC_GPIO_Port, PWRGOOD_RFSOC_Pin, RFSOC_DISCHARGE_MS) == 0)
			{
				g_pwr_unclean = 1;
			}

			g_pwr_state = PWR_ST_OFF;

		}
	}
	/* USER CODE END PowerDownTask_init */
}
/* USER CODE BEGIN Header_SoftOffTask_init */
/**
* @brief Function implementing the SoftOffTask thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_SoftOffTask_init */
void SoftOffTask_init(void const * argument)
{
	/* USER CODE BEGIN WaitSoftOffTask_init */
	/* Infinite loop */
	for(;;)
	{
		/* Wait for X86 Soft off signal, active low */
		if(g_pwr_state == PWR_ST_ON && HAL_GPIO_ReadPin(SUS_S3_GPIO_Port, SUS_S3_Pin) == GPIO_PIN_RESET)
		{
			g_pwr_state = PWR_ST_DOWN;
			is_wdt_detect_enabled = 0;

			/* The x86 has already stopped on its own. Mirror the power-up
			   order as in HardOffTask: stop the x86, clear the PL, cut the
			   RFSOC, then cut the x86. */
			HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOA, PWR_OK_X86_Pin, GPIO_PIN_RESET);

			HAL_GPIO_WritePin(RESETN_RFSOC_GPIO_Port, RESETN_RFSOC_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_RESET);
			osDelay(RFSOC_QUIESCE_MS);
			HAL_GPIO_WritePin(RUN_PWR_RFSOC_GPIO_Port, RUN_PWR_RFSOC_Pin, GPIO_PIN_RESET);

			HAL_GPIO_WritePin(RUN_PWR_X86_GPIO_Port, RUN_PWR_X86_Pin, GPIO_PIN_RESET);

			/* Cut LED panel lights*/
			HAL_GPIO_WritePin(GPIOB, LED1_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOB, LED2_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOB, LED3_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOB, LED6_FRONTPANEL_PWR_Pin, GPIO_PIN_RESET);

			/* Same discharge wait as in HardOffTask: see the comment there. */
			if (wait_pin_low(PWRGOOD_RFSOC_GPIO_Port, PWRGOOD_RFSOC_Pin, RFSOC_DISCHARGE_MS) == 0)
			{
				g_pwr_unclean = 1;
			}

			g_pwr_state = PWR_ST_OFF;
		}
		osDelay(100);
	}
	/* USER CODE END WaitSoftOffTask_init */
}

/**
  * @brief  Period elapsed callback in non blocking mode
  * @note   This function is called  when TIM1 interrupt took place, inside
  * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
  * a global variable "uwTick" used as application time base.
  * @param  htim : TIM handle
  * @retval None
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  /* USER CODE BEGIN Callback 0 */

  /* USER CODE END Callback 0 */
  if (htim->Instance == TIM1)
  {
    HAL_IncTick();
  }
  /* USER CODE BEGIN Callback 1 */

  /* USER CODE END Callback 1 */
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
