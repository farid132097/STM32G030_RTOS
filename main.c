
#include "stm32g030xx.h"
#include "kernel.h"
#include "tasks.h"


int main(void){
	
	Kernel_Init();
	Kernel_Task_Create(Tasks_Task1, 3);
	Kernel_Task_Create(Tasks_Task2, 0);
	Kernel_Task_Create(Tasks_Task3, 2);
	Kernel_Start_Tasks();
	
	while(1){
		
		
	}
	
}


