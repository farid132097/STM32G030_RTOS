 
 
 ; File          : kernel.S
 ; Author        : MD. Faridul Islam (faridmdislam@gmail.com)
 ; Description   : ARM Cortex M0+ kernel for bare-metal RTOS
 ; Created       : Sep 02, 2025, 09:30 PM
 ; Last Modified : Oct 14, 2025, 16:02 PM



                      THUMB                                      ;enable thumb mode
				      PRESERVE8                                  ;8 bytes stack alignment
	
                      AREA       |.constdata|, DATA, READONLY

;define necessary address bases (constants)
DEF_CODE_BASE         EQU        0x00000000
DEF_SRAM_BASE         EQU        0x20000000
DEF_PERIPHERAL_BASE   EQU        0x40000000
DEF_FLASH_BASE        EQU        DEF_CODE_BASE       + 0x00000000
DEF_SCS_BASE          EQU        0xE000E010
DEF_APB1_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00000000
DEF_APB2_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00010000
DEF_AHB_BASE          EQU        DEF_PERIPHERAL_BASE + 0x00020000

;define systick related register addresses
DEF_STK_CTRL          EQU        DEF_SCS_BASE        + 0x00000000
DEF_STK_LOAD          EQU        DEF_SCS_BASE        + 0x00000004
DEF_STK_VAL           EQU        DEF_SCS_BASE        + 0x00000008
DEF_STK_CALIB         EQU        DEF_SCS_BASE        + 0x0000000C
	


                      ;RAM area starts
					  AREA       |.data|, DATA, READWRITE, ALIGN=2
					  
				      ;enlist global variables
					  EXPORT     KER_TASK_ID
					  EXPORT     KER_TASK_NTASK
                      EXPORT     KER_TASK_PSP
					  
					  ;assign variables with size
KER_TASK_ID           SPACE      4                                 ;current task id
KER_TASK_NTASK        SPACE      4                                 ;total tasks
KER_TASK_PSP          SPACE      16                                ;PSP of tasks
					  

                      ;code area starts
                      AREA       |.text|, CODE, READONLY
					  
                      ;enlist global functions
					  EXPORT     Kernel_Task_Params_Init
					  EXPORT     Kernel_Systick_Init
				      EXPORT     Kernel_Idle_Task
					  EXPORT     Kernel_Demo_Task0
					  EXPORT     Kernel_Demo_Task1
					  EXPORT     Kernel_Demo_Task2
					  EXPORT     SysTick_Handler
					  IMPORT     GPIO_Toggle
						  



Kernel_Idle_Task
                      ;Idle task, does nothing
					  B          .                                  ;forever loop
                      
					  
Kernel_Demo_Task0
                      ;toggle pin PA1
					  LDR        R0,   =0x50000014                 ;load ODR address
					  LDR        R1,   [R0]                        ;load ODR val
					  LDR        R2,   =1                          ;mask pin number
					  MOVS       R3,   #0x01                       ;assign 1
					  LSLS       R3,   R3, R2                      ;lsl by pin number
					  EORS       R1,   R1, R3                      ;xor bit
					  STR        R1,   [R0]                        ;store val to ODR
					  B          Kernel_Demo_Task0                 ;forever loop
					  
Kernel_Demo_Task1
					  ;toggle pin PA2
					  LDR        R0,   =0x50000014                 ;load ODR address
					  LDR        R1,   [R0]                        ;load ODR val
					  LDR        R2,   =2                          ;mask pin number
					  MOVS       R3,   #0x01                       ;assign 1
					  LSLS       R3,   R3, R2                      ;lsl by pin number
					  EORS       R1,   R1, R3                      ;xor bit
					  STR        R1,   [R0]                        ;store val to ODR
					  B          Kernel_Demo_Task1                 ;forever loop
					  
Kernel_Demo_Task2
					  ;toggle pin PA3
					  LDR        R0,   =0x50000014                 ;load ODR address
					  LDR        R1,   [R0]                        ;load ODR val
					  LDR        R2,   =3                          ;mask pin number
					  MOVS       R3,   #0x01                       ;assign 1
					  LSLS       R3,   R3, R2                      ;lsl by pin number
					  EORS       R1,   R1, R3                      ;xor bit
					  STR        R1,   [R0]                        ;store val to ODR
					  B          Kernel_Demo_Task2                 ;forever loop
                      
					  
Kernel_Task_Params_Init
                      PUSH       {LR}
                      ;set first task_id
                      LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   =0
					  STR        R1,   [R0]                        ;store task_id val
					  ;set number of tasks
					  LDR        R0,   =KER_TASK_NTASK             ;load ntask addr
					  LDR        R1,   =3
					  STR        R1,   [R0]                        ;store nastk val
					  
					  ;task0 stack space init
					  LDR        R0,   =0x20000F00                 ;PSP top
                      SUBS       R0,   #32                         ;make space for R4-R11
                      SUBS       R0,   #32                         ;make space for hardware frame
                      MOVS       R1,   #0
					  ;task0 software stack
					  STR        R1,   [R0, #0]                    ;R4
					  STR        R1,   [R0, #4]                    ;R5
					  STR        R1,   [R0, #8]                    ;R6
					  STR        R1,   [R0, #12]                   ;R7
					  STR        R1,   [R0, #16]                   ;R8
					  STR        R1,   [R0, #20]                   ;R9
					  STR        R1,   [R0, #24]                   ;R10
					  STR        R1,   [R0, #28]                   ;R11
					  ;task0 hardware stack
                      STR        R1,   [R0, #32]                   ;R0
                      STR        R1,   [R0, #36]                   ;R1
                      STR        R1,   [R0, #40]                   ;R2
                      STR        R1,   [R0, #44]                   ;R3
                      STR        R1,   [R0, #48]                   ;R12
                      STR        R1,   [R0, #52]                   ;LR
                      LDR        R1,   =Kernel_Demo_Task0
                      STR        R1,   [R0, #56]                   ;PC
                      LDR        R1,   =0x01000000
                      STR        R1,   [R0, #60]                   ;xPSR (Thumb)
					  LDR        R0,   =0x20000F00                 ;test---------------------------------<<
                      LDR        R1,   =KER_TASK_PSP
                      STR        R0,   [R1]                        ;save PSP
					  
					  
					  ;task1 stack space init
					  LDR        R0,   =0x20000E00                 ;PSP top
                      SUBS       R0,   #32                         ;make space for R4-R11
                      SUBS       R0,   #32                         ;make space for hardware frame
                      MOVS       R1,   #0
					  ;task1 software stack
					  STR        R1,   [R0, #0]                    ;R4
					  STR        R1,   [R0, #4]                    ;R5
					  STR        R1,   [R0, #8]                    ;R6
					  STR        R1,   [R0, #12]                   ;R7
					  STR        R1,   [R0, #16]                   ;R8
					  STR        R1,   [R0, #20]                   ;R9
					  STR        R1,   [R0, #24]                   ;R10
					  STR        R1,   [R0, #28]                   ;R11
					  ;task1 hardware stack
                      STR        R1,   [R0, #32]                   ;R0
                      STR        R1,   [R0, #36]                   ;R1
                      STR        R1,   [R0, #40]                   ;R2
                      STR        R1,   [R0, #44]                   ;R3
                      STR        R1,   [R0, #48]                   ;R12
                      STR        R1,   [R0, #52]                   ;LR
                      LDR        R1,   =Kernel_Demo_Task1
                      STR        R1,   [R0, #56]                   ;PC
                      LDR        R1,   =0x01000000
                      STR        R1,   [R0, #60]                   ;xPSR (Thumb)
                      LDR        R1,   =KER_TASK_PSP
					  ADDS       R1,   #4
                      STR        R0,   [R1]                        ;save PSP
					  
					  ;task2 stack space init
					  LDR        R0,   =0x20000D00                 ;PSP top
                      SUBS       R0,   #32                         ;make space for R4-R11
                      SUBS       R0,   #32                         ;make space for hardware frame
                      MOVS       R1,   #0
					  ;task2 software stack
					  STR        R1,   [R0, #0]                    ;R4
					  STR        R1,   [R0, #4]                    ;R5
					  STR        R1,   [R0, #8]                    ;R6
					  STR        R1,   [R0, #12]                   ;R7
					  STR        R1,   [R0, #16]                   ;R8
					  STR        R1,   [R0, #20]                   ;R9
					  STR        R1,   [R0, #24]                   ;R10
					  STR        R1,   [R0, #28]                   ;R11
					  ;task2 hardware stack
                      STR        R1,   [R0, #32]                   ;R0
                      STR        R1,   [R0, #36]                   ;R1
                      STR        R1,   [R0, #40]                   ;R2
                      STR        R1,   [R0, #44]                   ;R3
                      STR        R1,   [R0, #48]                   ;R12
                      STR        R1,   [R0, #52]                   ;LR
                      LDR        R1,   =Kernel_Demo_Task2
                      STR        R1,   [R0, #56]                   ;PC
                      LDR        R1,   =0x01000000
                      STR        R1,   [R0, #60]                   ;xPSR (Thumb)
                      LDR        R1,   =KER_TASK_PSP
					  ADDS       R1,   #8
                      STR        R0,   [R1]                        ;save PSP
					  
					  POP        {PC}


Kernel_Systick_Init
                      ;PUSH       {LR}                              ;push return address
                      LDR        R0,   =DEF_STK_LOAD               ;load stk_load reg address
					  LDR        R1,   =15999                      ;load val for 1ms
					  STR        R1,   [R0]                        ;set val to reg
					  LDR        R0,   =DEF_STK_VAL                ;load stk_val reg address
					  MOVS       R1,   #0                          ;clear reg
					  STR        R1,   [R0]                        ;clear stk_val reg
					  LDR        R0,   =DEF_STK_CTRL               ;load stk_ctrl reg address
					  MOVS       R1,   #7                          ;mask bit0, bit1 & bit2
					  STR        R1,   [R0]                        ;set val to stk_ctrl
					  
					  ;Setup PSP for main
                      LDR        R0,   =0x20000F00                 ;address of main stack
                      MSR        PSP,  R0                          ;set PSP
                      MRS        R1,   CONTROL
					  LDR        R2,   =2
                      ORRS       R1,   R1, R2                      ;CONTROL.SPSEL = 1 ? use PSP in thread mode
                      MSR        CONTROL, R1                       ;switch to PSP
                      ISB                                          ;instruction barrier
					  B          Kernel_Demo_Task0                 ;call a task
					  
SysTick_Handler
                      ;Hardware pushed (address wise) R0-R3,R12,LR,PC,xPSR
					  ;Software pushed (address wise) R11-R4
                      CPSID      I                                 ;disable interrupts
					  
					  ;push R4-R11 manually
					  MRS        R0,   PSP                         ;load PSP in R0
					  SUBS       R0,   #32                         ;subtract 32 bytes
					  STR        R4,   [R0, #0]                    ;load data
					  STR        R5,   [R0, #4]                    ;load data
					  STR        R6,   [R0, #8]                    ;load data
					  STR        R7,   [R0, #12]                   ;load data
					  MOV        R1,   R8                          ;copy
					  STR        R1,   [R0, #16]                   ;load data
					  MOV        R1,   R9                          ;copy
					  STR        R1,   [R0, #20]                   ;load data
					  MOV        R1,   R10                         ;copy
					  STR        R1,   [R0, #24]                   ;load data
					  MOV        R1,   R11                         ;copy
					  STR        R1,   [R0, #28]                   ;load data
					  MSR        PSP,  R0                          ;update new top of stack
					  
					  ;save PSP to task block area
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R0,   [R0]                        ;load task_id val
					  LSLS       R0,   R0,  #2                     ;left shift 2 times to x4
					  LDR        R1,   =KER_TASK_PSP               ;load task psp addr base
					  ADD        R0,   R0,  R1                     ;calc offset from psp base
					  MRS        R1,   PSP                         ;load PSP in R1
					  STR        R1,   [R0]                        ;set val to reg
					  
					  ;go to next task
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   [R0]                        ;load task_id val
					  ADDS       R1,   R1, #1                      ;add 1
					  LDR        R2,   =KER_TASK_NTASK             ;load ntask addr
					  LDR        R2,   [R2]                        ;load ntask val
					  CMP        R1,   R2                          ;compare R1 with R2
					  BLT        SKIP_WRAP_TASK_ID                 ;task_id<ntask
					  LDR        R1,   =0                          ;roll back
SKIP_WRAP_TASK_ID
                      STR        R1,   [R0]                        ;store task_id
					  
					  
					  
					  ;toggle PA11
					  LDR        R0,   =0x50000014                 ;load ODR address
					  LDR        R1,   [R0]                        ;load ODR val
					  MOVS       R2,   #0x00                       ;pin number
					  MOVS       R3,   #0x01                       ;assign 1
					  LSLS       R3,   R3, R2                      ;lsl by pin number
					  EORS       R1,   R1, R3                      ;xor bit
					  STR        R1,   [R0]                        ;store val to ODR
					  
					  
					  
					  ;load PSP according to the new task_id
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R0,   [R0]                        ;load task_id val
					  LSLS       R0,   R0,  #2                     ;left shift 2 times to x4
					  LDR        R1,   =KER_TASK_PSP               ;load task psp addr base
					  ADD        R0,   R0,  R1                     ;calc offset from psp base
					  LDR        R0,   [R0]                        ;load task PSP
					  
					  ;pop R11-R4 manually
					  ;MRS        R0,   PSP                         ;load PSP in R0
					  LDR        R4,   [R0, #0]                    ;load data
					  LDR        R5,   [R0, #4]                    ;load data
					  LDR        R6,   [R0, #8]                    ;load data
					  LDR        R7,   [R0, #12]                   ;load data
					  LDR        R1,   [R0, #16]                   ;load data
					  MOV        R8,   R1                          ;copy
					  LDR        R1,   [R0, #20]                   ;load data
					  MOV        R9,   R1                          ;copy
					  LDR        R1,   [R0, #24]                   ;load data
					  MOV        R10,  R1                          ;copy
					  LDR        R1,   [R0, #28]                   ;load data
					  MOV        R11,  R1                          ;copy
					  ADDS       R0,   #32                         ;add 32 bytes
					  MSR        PSP,  R0                          ;update new top of stack
					  
					  CPSIE      I                                 ;enable interrupt
					  BX         LR                                ;return from interrupt
					  
					  
PendSV_Handler
                      CPSID      I                                 ;disable interrupts
                      ;do some task here
                      CPSIE      I                                 ;enable interrupt
                      BX LR                                        ;return from exception
					  

    
	
	