
#include "stm32g030xx.h"
#include "kernel.h"


int main(void){
	
	GPIO_Init();
	GPIO_Toggle();
	
	while(1){
		
		GPIO_Toggle();
		Delay();
		
	}
	
}


