
#include "stm32g030xx.h"
#include "kernel.h"
#include "gpio.h"



int main(void){
	
	Delay();
	GPIO_Init();
	//Kernel_Task_Params_Init();
	Kernel_Systick_Init();
	
	while(1){
		
		
	}
	
}


