
/*

   File          : kernel.h
   Author        : MD. Faridul Islam (faridmdislam@gmail.com)
	 Source        : https://github.com/farid132097/STM32G030_RTOS
   Description   : ARM Cortex M0+ kernel for bare-metal RTOS
   Created       : Sep 02, 2025, 09:30 PM
   Last Modified : May 07, 2026, 02:48 PM
	
*/




#ifndef  _KERNEL_H_
#define  _KERNEL_H_

#include "stdint.h"




void     Kernel_Init(void);
void     Kernel_Start_Tasks(void);
void     Kernel_Task_Create(void (*func)(void), uint32_t priority);
void     Kernel_Idle_Task(void);
void     Kernel_Task_Sleep(uint32_t val);
uint32_t Kernel_Tick_SS32_Get(void);
uint64_t Kernel_Tick_SS64_Get(void);
uint32_t Kernel_Tick_S_Get(void);
void     Kernel_Timeout_Set(uint32_t val);
uint32_t Kernel_Is_Timeout(void);
uint32_t Kernel_CPU_Usage_Get(void);



#endif


