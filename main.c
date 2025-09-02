
#include "stm32g030xx.h"
#include "kernel.h"
#include "gpio.h"

int main(void){
	
	Kernel_Systick_Init();
	GPIO_Init();
	GPIO_Toggle();
	
	while(1){
		
		//GPIO_Toggle();
		//Delay();
		
	}
	
}


