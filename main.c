
#include "stm32g030xx.h"
#include "kernel.h"
#include "gpio.h"


int main(void){
	
	Kernel_Init();
	Kernel_Task_Create(Task_PA1_Toggle, 0);
	Kernel_Task_Create(Task_PA2_Toggle, 1);
	Kernel_Task_Create(Task_PA3_Toggle, 2);
	Kernel_Start_Tasks();
	
	while(1){
		
		
	}
	
}


