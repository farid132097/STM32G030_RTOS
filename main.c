
#include "stm32g030xx.h"
#include "kernel.h"
#include "gpio.h"

int main(void){
	
	//Kernel_Systick_Init();
	GPIO_Init();
	
	while(1){
		
		GPIO_High();
		Delay();
		GPIO_Low();
		Delay();
		
		//GPIO_Toggle();
		//Delay();
		
	}
	
}


