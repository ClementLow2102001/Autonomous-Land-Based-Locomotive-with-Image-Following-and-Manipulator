/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
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
UART_HandleTypeDef huart1;
UART_HandleTypeDef huart2;
UART_HandleTypeDef huart3;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_USART3_UART_Init(void);
static void MX_USART1_UART_Init(void);
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
  MX_USART2_UART_Init();
  MX_USART3_UART_Init();
  MX_USART1_UART_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1){
//	  GetVersion();
//	  GetResolution();
//	  SetCameraBrightness(125);
	  GetBlocks(1, 3);
	  HAL_Delay(320);
  }

  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */

void GetBlocks(int sig, int blocks){
	uint8_t tx_Block[6] = {174, 193, 32, 2, sig, blocks};
	uint8_t rx_Block[48] = {0};
	uint8_t command[5] = {0x7A, 0, 16, 0, 0x7B};
	int checksum = 0;
	int Xpos = 0, Width = 0;
//	int Height = 0;

	HAL_UART_Transmit(&huart1, tx_Block, sizeof(tx_Block), 100);
	HAL_UART_Receive (&huart1, rx_Block, sizeof(rx_Block), 100);
		if (rx_Block[0] == 175 && rx_Block[1] == 193 && rx_Block[7]*16*16 + rx_Block[6] == 1){
			for(int i = 6; i < rx_Block[3]+6; i++){
				checksum += rx_Block[i];
			}
			if(checksum == rx_Block[5]*16*16 + rx_Block[4] && rx_Block[3] == 14){
				//Used to transmit to P1 to show data
				//HAL_UART_Transmit(&huart3, rx_Block, rx_Block[3]+6, 200);

				Xpos   = rx_Block[9]*16*16 + rx_Block[8];
				Width  = rx_Block[13]*16*16 + rx_Block[12];
			//	Height = rx_Block[15]*16*16 + rx_Block[14];

				if(Xpos > 168 && (Width < 168 && Width > 128)){
					command[1] = 4;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Xpos < 128 && (Width < 168 && Width > 128)){
					command[1] = 3;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Width < 128 && (Xpos > 128 && Xpos < 168) ){
					command[1] = 1;
					command[2] = 40-Width/4;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Width > 168 && (Xpos > 128 && Xpos < 168)){
					command[1] = 2;
					command[2] = Width/10+16;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Width < 128 && Xpos > 168){
					command[1] = 8;
					command[2] = 40-Width/4;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Width > 168 && Xpos > 168){
					command[1] = 10;
					command[2] = Width/10+16;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Width < 128 && Xpos < 128){
					command[1] = 7;
					command[2] = 40-Width/4;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else if(Width > 168 && Xpos < 128){
					command[1] = 9;
					command[2] = Width/10+16;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}else{
					command[1] = 11;
					command[3] = (command[2]^command[1])^0x7F;
					HAL_UART_Transmit(&huart3, command, sizeof(command), 100);
				}
			}
		}
}

void SetCameraBrightness(int bright){
	uint8_t tx_CameraBrightness[5] = {174, 193, 16, 1, bright};
	uint8_t rx_CameraBrightness[10];
	int checksum = 0;

	HAL_UART_Transmit(&huart1, tx_CameraBrightness, sizeof(tx_CameraBrightness), 100);
	HAL_UART_Receive (&huart1, rx_CameraBrightness, sizeof(rx_CameraBrightness), 100);

	if (rx_CameraBrightness[0] == 175 && rx_CameraBrightness[1] == 193){
		for(int i = 6; i < 10; i++){
			checksum += rx_CameraBrightness[i];
		}
		if(checksum == rx_CameraBrightness[5]*16*16 + rx_CameraBrightness[4]){
			for(int i = 0; i < 10; i += 4){
					HAL_UART_Transmit(&huart3, &rx_CameraBrightness[i], 4, 100);
					HAL_Delay(20);
			}
		}
	}

	HAL_Delay(5000);
}
void GetResolution(){
	uint8_t  tx_Resolution[5] = {0xAE, 0xC1, 12, 1, 0};
	uint8_t  rx_Resolution[10];
	int checksum = 0;

	HAL_UART_Transmit(&huart1, tx_Resolution, sizeof(tx_Resolution), 100);
	HAL_UART_Receive (&huart1, rx_Resolution, sizeof(rx_Resolution), 100);

	if (rx_Resolution[0] == 175 && rx_Resolution[1] == 193){
		for(int i = 6; i < 10; i++){
			checksum += rx_Resolution[i];
		}
		if(checksum == (rx_Resolution[5]*16*16 + rx_Resolution[4])){
			for(int i = 0; i < 10; i += 4){
					HAL_UART_Transmit(&huart3, &rx_Resolution[i], 4, 100);
					HAL_Delay(20);
			}
		}
	}
	HAL_Delay(5000);
}

void GetVersion(){
	uint8_t  tx_Version[4] = {0xAE, 0xC1, 0x0E, 0x00};
	uint8_t  rx_Version[22];
	int checksum = 0;

	HAL_UART_Transmit(&huart1, tx_Version, sizeof(tx_Version), 100);
	HAL_UART_Receive (&huart1, rx_Version, sizeof(rx_Version), 100);

	if (rx_Version[0] == 175 && rx_Version[1] == 193){
		for(int i = 6; i < 22; i++){
			checksum += rx_Version[i];
		}
		if(checksum == (rx_Version[5]*16*16 + rx_Version[4])){
			for(int i = 0; i < 22; i += 4){
				HAL_UART_Transmit(&huart3, &rx_Version[i], 4, 100);
				HAL_Delay(20);
			}
		}
	}

	HAL_Delay(5000);
}

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
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART1_UART_Init(void)
{

  /* USER CODE BEGIN USART1_Init 0 */

  /* USER CODE END USART1_Init 0 */

  /* USER CODE BEGIN USART1_Init 1 */

  /* USER CODE END USART1_Init 1 */
  huart1.Instance = USART1;
  huart1.Init.BaudRate = 19200;
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART1_Init 2 */

  /* USER CODE END USART1_Init 2 */

}

/**
  * @brief USART2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART2_UART_Init(void)
{

  /* USER CODE BEGIN USART2_Init 0 */

  /* USER CODE END USART2_Init 0 */

  /* USER CODE BEGIN USART2_Init 1 */

  /* USER CODE END USART2_Init 1 */
  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart2) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART2_Init 2 */

  /* USER CODE END USART2_Init 2 */

}

/**
  * @brief USART3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART3_UART_Init(void)
{

  /* USER CODE BEGIN USART3_Init 0 */

  /* USER CODE END USART3_Init 0 */

  /* USER CODE BEGIN USART3_Init 1 */

  /* USER CODE END USART3_Init 1 */
  huart3.Instance = USART3;
  huart3.Init.BaudRate = 115200;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart3) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART3_Init 2 */

  /* USER CODE END USART3_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(LD2_GPIO_Port, LD2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : B1_Pin */
  GPIO_InitStruct.Pin = B1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(B1_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : LD2_Pin */
  GPIO_InitStruct.Pin = LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(LD2_GPIO_Port, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(EXTI15_10_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

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

