
/*

  File          : kernel.h
  Author        : MD. Faridul Islam (faridmdislam@gmail.com)
  Description   : ARM Cortex M0+ kernel for bare-metal RTOS
  Created       : Sep 02, 2025, 09:30 PM
  Last Modified : Nov 11, 2025, 06:44 PM
	
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


