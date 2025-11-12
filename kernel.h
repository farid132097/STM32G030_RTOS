
/*

  File          : kernel.h
  Author        : MD. Faridul Islam (faridmdislam@gmail.com)
	Source        : https://github.com/farid132097/STM32G030_RTOS
  Description   : ARM Cortex M0+ kernel for bare-metal RTOS
  Created       : Sep 02, 2025, 09:30 PM
  Last Modified : Nov 12, 2025, 11:59 AM
	
*/

#ifndef  _KERNEL_H_
#define  _KERNEL_H_

#include "stdint.h"

void     Kernel_Init(void);
void     Kernel_Start_Tasks(void);
void     Kernel_Task_Create(void (*func)(void), unsigned char priority);
void     Kernel_Idle_Task(void);
void     Kernel_Task_Sleep(unsigned int val);
uint32_t Kernel_Tick_SS32_Get(void);
uint64_t Kernel_Tick_SS64_Get(void);
uint32_t Kernel_Tick_S_Get(void);
uint32_t Kernel_CPU_Usage_Get(void);

#endif


