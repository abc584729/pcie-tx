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
#define HARD_OFF_BTN_MS       4000    /* PWRBTN# hold that forces the x86 off */
#define HOST_STOP_TIMEOUT_MS  6000    /* max wait for SUS_S3# to drop */
#define RFSOC_QUIESCE_MS      100     /* let PROG_B settle before cutting power */

/* Written by whichever task owns the transition, read by SoftOffTask on
   every poll -- volatile because the Release build compiles with -Os. */
volatile pwr_state_t g_pwr_state = PWR_ST_OFF;
volatile uint8_t is_wdt_detect_enabled = 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
void PowerOnTask_init(void const * argument);
void KeyMonitorTask_init(void const * argument);
void HardOffTask_init(void const * argument);
void SoftOffTask_init(void const * argument);

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

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
  /* Infinite loop */
  for(;;)
  {
	  osEvent evt = osSignalWait(0x01, osWaitForever);
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

		  g_pwr_state = PWR_ST_UP;

		  /* Enable External Power Supply */
		  HAL_GPIO_WritePin(GPIOA, RUN_PWR_X86_Pin, GPIO_PIN_SET);

		  /* Wait for 1 second ???*/
		  //osDelay(WAIT_EXTERNAL_POWER_ON);

		  HAL_GPIO_WritePin(GPIOA, RESET_X86_Pin, GPIO_PIN_SET);

	  	  /* Entering RFSOC Power up sequence */
	  	  /* Power RFSOC */
	  	  HAL_GPIO_WritePin(RUN_PWR_RFSOC_GPIO_Port, RUN_PWR_RFSOC_Pin, GPIO_PIN_SET);

	  	  /* Wait until RFSOC Power good */
	  	  while(HAL_GPIO_ReadPin(PWRGOOD_RFSOC_GPIO_Port, PWRGOOD_RFSOC_Pin) != GPIO_PIN_SET)
	  	  {
	  		    osDelay(1);
	  	  }

	  	  /* RFSOC Power good */
	  	  HAL_GPIO_WritePin(GPIOB, LED1_FRONTPANEL_PWR_Pin, GPIO_PIN_SET);

	  	  /* Release PROG_B first. The power-down sequences assert it to
	  	     clear the PL, so it has to be de-asserted before the reset is
	  	     released or the PL stays unconfigured. */
	  	  HAL_GPIO_WritePin(PS_PROG_B_GPIO_Port, PS_PROG_B_Pin, GPIO_PIN_SET);

	  	  /* Release RFSOC Reset to enable Power On Reset*/
	  	  HAL_GPIO_WritePin(RESETN_RFSOC_GPIO_Port, RESETN_RFSOC_Pin, GPIO_PIN_SET);

	  	  /* Wait until PS Done */
	  	  while(HAL_GPIO_ReadPin(PS_DONE_GPIO_Port, PS_DONE_Pin) != GPIO_PIN_SET)
	  	  {
	  		    osDelay(100);
	  	  }

	  	  /* When PS DONE, Turn on LED 6 */
	  	  HAL_GPIO_WritePin(GPIOB, LED6_FRONTPANEL_PWR_Pin, GPIO_PIN_SET);

	  	  /* Wait PL initialization */
//	  	  osDelay(PL_INITIALIZATION_TIME);


	  	  /* Entering X86 Power up sequence */
	  	  /* Push X86 Power Button for 1s*/
	  	  HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_RESET);
	  	  osDelay(BTN_PRESS_TIME);
	  	  HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_SET);

	  	  /* Wait until SUS_S3_Pin is released */
	  	  while(HAL_GPIO_ReadPin(GPIOA, SUS_S3_Pin) != GPIO_PIN_SET)
	  	  {
	  		  osDelay(10);
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
	  }
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
	uint16_t wait_time = 0;

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

			/* Ask the x86 to shut down itself. The RFSOC must stay alive for
			   the whole of this 4s, otherwise the x86 is left running with an
			   already dead PCIe endpoint. */
			HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_RESET);
			osDelay(HARD_OFF_BTN_MS);
			HAL_GPIO_WritePin(GPIOA, PWR_BTN_X86_Pin, GPIO_PIN_SET);

			/* Wait until X86 is ready to be shut down, active low */
			while(wait_time <= HOST_STOP_TIMEOUT_MS && HAL_GPIO_ReadPin(SUS_S3_GPIO_Port, SUS_S3_Pin) != GPIO_PIN_RESET)
			{
				osDelay(10);
				wait_time += 10;
			}

			/* Clear time counter */
			wait_time = 0;

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
