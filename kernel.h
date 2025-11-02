
/*

  File          : kernel.S
  Author        : MD. Faridul Islam (faridmdislam@gmail.com)
  Description   : ARM Cortex M0+ kernel for bare-metal RTOS
  Created       : Sep 02, 2025, 09:30 PM
  Last Modified : Oct 14, 2025, 16:02 PM
	
*/

#ifndef _KERNEL_H_
#define _KERNEL_H_

void    Kernel_Task_Params_Init(void);
void    Kernel_Systick_Init(void);
void    Kernel_Init(void);
void    Kernel_Task_Create(void);

#endif


