 
 
 ; File          : kernel.S
 ; Author        : MD. Faridul Islam (faridmdislam@gmail.com)
 ; Description   : ARM Cortex M0+ kernel for bare-metal RTOS
 ; Created       : Sep 02, 2025, 09:30 PM
 ; Last Modified : Nov 02, 2025, 11:55 AM




;;=============================system type definition starting===============================;; 
                      THUMB                                      ;enable thumb mode
				      PRESERVE8                                  ;8 bytes stack alignment
;;===============================system type definition end==================================;; 





;;============================constant area definition starting==============================;; 
                      AREA       |.constdata|, DATA, READONLY
;;==============================constant area definition end=================================;; 





;;===============================define address bases starting===============================;; 
DEF_CODE_BASE         EQU        0x00000000
DEF_SRAM_BASE         EQU        0x20000000
EDF_SRAMM_END         EQU        0x20001FFF
DEF_PERIPHERAL_BASE   EQU        0x40000000
DEF_FLASH_BASE        EQU        DEF_CODE_BASE       + 0x00000000
DEF_SCS_BASE          EQU        0xE000E010
DEF_APB1_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00000000
DEF_APB2_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00010000
DEF_AHB_BASE          EQU        DEF_PERIPHERAL_BASE + 0x00020000
;;=================================define address bases end==================================;; 





;;============================define systick addresses starting==============================;; 
DEF_STK_CTRL          EQU        DEF_SCS_BASE        + 0x00000000
DEF_STK_LOAD          EQU        DEF_SCS_BASE        + 0x00000004
DEF_STK_VAL           EQU        DEF_SCS_BASE        + 0x00000008
DEF_STK_CALIB         EQU        DEF_SCS_BASE        + 0x0000000C
;;===============================define systick addresses end================================;;
	




;;============================define systick addresses starting==============================;; 
DEF_KER_MAX_NTASK     EQU        0x0000000A                        ;max 10 tasks
DEF_KER_STACK_SIZE    EQU        0x00000100                        ;256 bytes stack
DEF_KER_STACK_SPACE   EQU        DEF_KER_MAX_NTASK*DEF_KER_STACK_SIZE
;;===============================define systick addresses end================================;;





;;==============================RAM area definition starting=================================;; 
					  AREA       |.data|, DATA, READWRITE, ALIGN=2
;;================================RAM area definition end====================================;; 





;;=========================global variable declaration starting==============================;; 
					  EXPORT     KER_TASK_ID
					  EXPORT     KER_TASK_NTASK
                      EXPORT     KER_TASK_PSP
					  EXPORT     KER_TASK_STACK
;;===========================global variable declaration end=================================;; 





;;===========================global variable definition starting=============================;; 
KER_TASK_ID           SPACE      4                                 ;current task id
KER_TASK_NTASK        SPACE      4                                 ;total tasks
KER_TASK_PSP          SPACE      12                                ;PSP for 10 tasks
KER_TASK_STACK        SPACE      DEF_KER_STACK_SPACE               ;total stack space
;;=============================global variable definition end================================;; 





;;==============================code area definition starting================================;; 
                      AREA       |.text|, CODE, READONLY
;;=================================code area definition end==================================;; 





;;=========================global function declaration starting==============================;; 
					  EXPORT     Kernel_Task_Params_Init
					  EXPORT     Kernel_Systick_Init
				      EXPORT     Kernel_Idle_Task
					  EXPORT     Kernel_Demo_Task0
					  EXPORT     Kernel_Demo_Task1
					  EXPORT     Kernel_Demo_Task2
					  EXPORT     Kernel_Init
					  EXPORT     Kernel_Task_Create
					  EXPORT     SysTick_Handler
;;===========================global function declaration end=================================;; 





;;===========================macro for gpio set starting=====================================;; 
                      MACRO
                      MACRO_GPIO_SET
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000001                 ;bit0 set
					  STR        R1,   [R0]                        ;store val
					  MEND
;;=============================macro for gpio set end========================================;; 





;;===========================macro for gpio clear starting===================================;; 
					  MACRO
                      MACRO_GPIO_CLEAR
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00010000                 ;bit0 clear
					  STR        R1,   [R0]                        ;store val
					  MEND
;;=============================macro for gpio clear end======================================;; 





;;===========================macro for pushing r4-r11 starting===============================;; 
                      MACRO
					  MACRO_PUSH_R4_R11                            ;push R4-R11 manually
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
					  MEND
;;============================macro for pushing r4-r11 end==================================;; 





;;===========================macro for popping r4-r11 starting==============================;; 
					  MACRO
					  MACRO_POP_R11_R4                             ;pop R11-R4 manually
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
                      MEND
;;==============================macro for popping r4-r11 end================================;; 




Kernel_Idle_Task
                      ;Idle task, does nothing
					  B          .                                  ;forever loop
                      
					  
Kernel_Demo_Task0
                      ;toggle pin PA1
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000002                 ;bit1 set
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00020000                 ;bit1 reset
					  STR        R1,   [R0]                        ;store val
					  B          Kernel_Demo_Task0                 ;forever loop
					  
Kernel_Demo_Task1
					  ;toggle pin PA2
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000004                 ;bit1 set
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00040000                 ;bit1 reset
					  STR        R1,   [R0]                        ;store val
					  B          Kernel_Demo_Task1                 ;forever loop
					  
Kernel_Demo_Task2
					  ;toggle pin PA3
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000008                 ;bit1 set
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00080000                 ;bit1 reset
					  STR        R1,   [R0]                        ;store val
					  B          Kernel_Demo_Task2                 ;forever loop
                      
Kernel_Init
                      PUSH       {LR}
					  ;set first task_id
                      LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   =0x00000001                 ;start from 0
					  STR        R1,   [R0]                        ;store task_id val
					  POP        {PC}
					  
Kernel_Task_Create
                      PUSH       {LR}
					  ;task0 stack space init
					  
					  LDR        R2,   =DEF_KER_STACK_SIZE         ;load each stack size
					  LDR        R3,   =KER_TASK_ID                ;load current task id addr
					  LDR        R3,   [R3]                        ;load current task id
					  MULS       R2,   R3, R2                      ;multiply R2 & R3
					  MOV        R12,  R2                          ;copy val
					  LDR        R3,   =KER_TASK_STACK             ;PSP current top
					  LDR        R2,   =DEF_KER_STACK_SPACE        ;load stack space
					  ADDS       R3,   R3, R2                      ;add offset
					  MOV        R2,   R12                         ;copy val
					  SUBS       R3,   R3, R2                      ;stack_top-task_id*stack_size
					  
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
                      LDR        R1,   =KER_TASK_PSP
                      STR        R0,   [R1]                        ;save PSP
					  POP        {PC}


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
                      ;Hardware pushed (address wise, high->low) xPSR,PC,LR,R12,R3-R0
					  ;Software pushed (address wise, high->low) R11-R4
                      CPSID      I                                 ;disable interrupts
					  
					  
					  MACRO_GPIO_SET
					  
					  MACRO_PUSH_R4_R11                            ;push R4-R11 manually
					  
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
					  
					  
					  
					  ;load PSP according to the new task_id
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R0,   [R0]                        ;load task_id val
					  LSLS       R0,   R0,  #2                     ;left shift 2 times to x4
					  LDR        R1,   =KER_TASK_PSP               ;load task psp addr base
					  ADD        R0,   R0,  R1                     ;calc offset from psp base
					  LDR        R0,   [R0]                        ;load task PSP
					  
					  
					  MACRO_POP_R11_R4                             ;pop R11-R4 manually
					  
					  MACRO_GPIO_CLEAR
					  
					  CPSIE      I                                 ;enable interrupt
					  BX         LR                                ;return from interrupt
					  
					  
PendSV_Handler
                      CPSID      I                                 ;disable interrupts
                      ;do some task here
                      CPSIE      I                                 ;enable interrupt
                      BX LR                                        ;return from exception
					  
					  
					  
					  
					  END
					  
					  

    
	
	