
#include "stm32g030xx.h"
#include "kernel.h"
#include "gpio.h"



int main(void){
	
	Delay();
	GPIO_Init();
	Kernel_Init();
	Kernel_Task_Create(Kernel_Demo_Task0, 0);
	Kernel_Task_Create(Kernel_Demo_Task1, 1);
	Kernel_Task_Create(Kernel_Demo_Task2, 2);
	Kernel_Start_Tasks();
	
	while(1){
		
		
	}
	
}


