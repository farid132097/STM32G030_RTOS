

#include "stm32g030xx.h"
#include "kernel.h"
#include "tasks.h"
#include "gpio.h"

__attribute__((noreturn)) void Tasks_Task1(void){
	  
	  GPIO_PA1_Init();
	  
	  while(1){
		
		    GPIO_PA1_Set();
		    Kernel_Task_Sleep(500);
			  GPIO_PA1_Clear();
			  Kernel_Task_Sleep(500);
		    
	  }
}

__attribute__((noreturn)) void Tasks_Task2(void){
	  
	  GPIO_PA2_Init();
	  
	  while(1){
		
		    GPIO_PA2_Set();
		    Kernel_Task_Sleep(1000);
			  GPIO_PA2_Clear();
			  Kernel_Task_Sleep(1000);
		    
	  }
}

__attribute__((noreturn)) void Tasks_Task3(void){
	  
	  GPIO_PA3_Init();
	  
	  while(1){
		
		    GPIO_PA3_Set();
		    Kernel_Task_Sleep(2000);
			  GPIO_PA3_Clear();
			  Kernel_Task_Sleep(2000);
		    
	  }
}