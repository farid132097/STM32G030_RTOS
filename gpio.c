

#include "stm32g030xx.h"
#include "kernel.h"
#include "gpio.h"

__attribute__((noreturn)) void Task_PA1_Toggle(void){
	
	RCC->IOPENR  |= RCC_IOPENR_GPIOAEN;
	GPIOA->MODER &=~GPIO_MODER_MODE1_Msk;
	GPIOA->MODER |= GPIO_MODER_MODE1_0;
	
	while(1){
		GPIOA->BSRR |= GPIO_BSRR_BS1;
		Kernel_Task_Sleep(100);
		GPIOA->BSRR |= GPIO_BSRR_BR1;
		Kernel_Task_Sleep(100);
	}
}

__attribute__((noreturn)) void Task_PA2_Toggle(void){
	
	RCC->IOPENR  |= RCC_IOPENR_GPIOAEN;
	GPIOA->MODER &=~GPIO_MODER_MODE2_Msk;
	GPIOA->MODER |= GPIO_MODER_MODE2_0;
	
	while(1){
		GPIOA->BSRR |= GPIO_BSRR_BS2;
		Kernel_Task_Sleep(200);
		GPIOA->BSRR |= GPIO_BSRR_BR2;
		Kernel_Task_Sleep(200);
	}
}

__attribute__((noreturn)) void Task_PA3_Toggle(void){
	
	RCC->IOPENR  |= RCC_IOPENR_GPIOAEN;
	GPIOA->MODER &=~GPIO_MODER_MODE3_Msk;
	GPIOA->MODER |= GPIO_MODER_MODE3_0;
	
	while(1){
		GPIOA->BSRR |= GPIO_BSRR_BS3;
		Kernel_Task_Sleep(300);
		GPIOA->BSRR |= GPIO_BSRR_BR3;
		Kernel_Task_Sleep(300);
	}
}


__attribute__((noreturn)) void Task_Dummy(void){
	
	
	while(1){
		
	}
}

