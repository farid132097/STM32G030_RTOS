
/*

  File          : kernel.S
  Author        : MD. Faridul Islam (faridmdislam@gmail.com)
  Description   : ARM Cortex M0+ kernel for bare-metal RTOS
  Created       : Sep 02, 2025, 09:30 PM
  Last Modified : Oct 14, 2025, 16:02 PM
	
*/

#ifndef _KERNEL_H_
#define _KERNEL_H_

void    Kernel_Init(void);
void    Kernel_Start_Tasks(void);
void    Kernel_Task_Create(void (*func)(void), uint8_t priority);

void    Kernel_Idle_Task(void);
void    Kernel_Demo_Task0(void);
void    Kernel_Demo_Task1(void);
void    Kernel_Demo_Task2(void);

#endif


