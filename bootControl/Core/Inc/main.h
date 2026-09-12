/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
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

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32f1xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define PWRBTN_EXT_Pin GPIO_PIN_13
#define PWRBTN_EXT_GPIO_Port GPIOC
#define RSTBTN_EXT_Pin GPIO_PIN_14
#define RSTBTN_EXT_GPIO_Port GPIOC
#define SUS_S5_Pin GPIO_PIN_0
#define SUS_S5_GPIO_Port GPIOA
#define SUS_S3_Pin GPIO_PIN_1
#define SUS_S3_GPIO_Port GPIOA
#define PWR_OK_X86_Pin GPIO_PIN_2
#define PWR_OK_X86_GPIO_Port GPIOA
#define PWR_BTN_X86_Pin GPIO_PIN_3
#define PWR_BTN_X86_GPIO_Port GPIOA
#define WDT_Pin GPIO_PIN_4
#define WDT_GPIO_Port GPIOA
#define RESET_X86_Pin GPIO_PIN_5
#define RESET_X86_GPIO_Port GPIOA
#define GPI0_COME_Pin GPIO_PIN_6
#define GPI0_COME_GPIO_Port GPIOA
#define GPI1_COME_Pin GPIO_PIN_7
#define GPI1_COME_GPIO_Port GPIOA
#define PWRGOOD_RFSOC_Pin GPIO_PIN_0
#define PWRGOOD_RFSOC_GPIO_Port GPIOB
#define PS_DONE_Pin GPIO_PIN_1
#define PS_DONE_GPIO_Port GPIOB
#define RESETN_RFSOC_Pin GPIO_PIN_2
#define RESETN_RFSOC_GPIO_Port GPIOB
#define LED1_FRONTPANEL_PWR_Pin GPIO_PIN_10
#define LED1_FRONTPANEL_PWR_GPIO_Port GPIOB
#define LED2_FRONTPANEL_PWR_Pin GPIO_PIN_11
#define LED2_FRONTPANEL_PWR_GPIO_Port GPIOB
#define LED3_FRONTPANEL_PWR_Pin GPIO_PIN_12
#define LED3_FRONTPANEL_PWR_GPIO_Port GPIOB
#define LED4_FRONTPANEL_PWR_Pin GPIO_PIN_13
#define LED4_FRONTPANEL_PWR_GPIO_Port GPIOB
#define LED5_FRONTPANEL_PWR_Pin GPIO_PIN_14
#define LED5_FRONTPANEL_PWR_GPIO_Port GPIOB
#define LED6_FRONTPANEL_PWR_Pin GPIO_PIN_15
#define LED6_FRONTPANEL_PWR_GPIO_Port GPIOB
#define GPO0_COME_Pin GPIO_PIN_8
#define GPO0_COME_GPIO_Port GPIOA
#define GPO1_COME_Pin GPIO_PIN_9
#define GPO1_COME_GPIO_Port GPIOA
#define T_ALARM_PWR_Pin GPIO_PIN_10
#define T_ALARM_PWR_GPIO_Port GPIOA
#define RUN_PWR_X86_Pin GPIO_PIN_11
#define RUN_PWR_X86_GPIO_Port GPIOA
#define RUN_PWR_RFSOC_Pin GPIO_PIN_12
#define RUN_PWR_RFSOC_GPIO_Port GPIOA
#define PS_PROG_B_Pin GPIO_PIN_5
#define PS_PROG_B_GPIO_Port GPIOB

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
