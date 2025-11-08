 
 
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
DEF_NVIC_BASE         EQU        0xE000E100
DEF_SCB_BASE          EQU        0xE000ED00
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





;;==============================define NVIC addresses starting===============================;; 
DEF_NVIC_ISER         EQU        DEF_NVIC_BASE       + 0x00000000
DEF_NVIC_ICER         EQU        DEF_NVIC_BASE       + 0x00000080
DEF_NVIC_ISPR         EQU        DEF_NVIC_BASE       + 0x00000100
DEF_NVIC_ICPR         EQU        DEF_NVIC_BASE       + 0x00000180
DEF_NVIC_IPR0         EQU        DEF_NVIC_BASE       + 0x00000300
DEF_NVIC_IPR1         EQU        DEF_NVIC_BASE       + 0x00000320
DEF_NVIC_IPR2         EQU        DEF_NVIC_BASE       + 0x00000340
DEF_NVIC_IPR3         EQU        DEF_NVIC_BASE       + 0x00000360
DEF_NVIC_IPR4         EQU        DEF_NVIC_BASE       + 0x00000380
DEF_NVIC_IPR5         EQU        DEF_NVIC_BASE       + 0x000003A0
DEF_NVIC_IPR6         EQU        DEF_NVIC_BASE       + 0x000003C0
DEF_NVIC_IPR7         EQU        DEF_NVIC_BASE       + 0x000003E0
;;=================================define NVIC addresses end=================================;;





;;===============================define SCB addresses starting===============================;; 
DEF_SCB_CPUID         EQU        DEF_SCB_BASE        + 0x00000000
DEF_SCB_ICSR          EQU        DEF_SCB_BASE        + 0x00000004
DEF_SCB_VTOR          EQU        DEF_SCB_BASE        + 0x00000008
DEF_SCB_AIRCR         EQU        DEF_SCB_BASE        + 0x0000000C
DEF_SCB_SCR           EQU        DEF_SCB_BASE        + 0x00000010
DEF_SCB_CCR           EQU        DEF_SCB_BASE        + 0x00000014
DEF_SCB_SHPR2         EQU        DEF_SCB_BASE        + 0x0000001C
DEF_SCB_SHPR3         EQU        DEF_SCB_BASE        + 0x00000020
;;==================================define SCB addresses end=================================;;





;;============================define systick addresses starting==============================;; 
DEF_KER_MAX_NTASK     EQU        0x0000000A                        ;max 10 tasks
DEF_KER_STACK_SIZE    EQU        0x00000100                        ;256 bytes stack
DEF_KER_STACK_SPACE   EQU        DEF_KER_MAX_NTASK*DEF_KER_STACK_SIZE
;;===============================define systick addresses end================================;;





;;================================define system macro starting===============================;; 
TASK_BLOCKED          EQU        0x00                              ;blocked state                    
TASK_READY            EQU        0x01                              ;ready state                     
TASK_EXECUTING        EQU        0x02                              ;executing state                       
TASK_SUSPENDED        EQU        0x03                              ;suspended state                    
TASK_CONS_LAT         EQU        0x04                              ;constant latency state 
;;===================================define system macro end=================================;; 





;;==============================RAM area definition starting=================================;; 
					  AREA       |.data|, DATA, READWRITE, ALIGN=2
;;================================RAM area definition end====================================;; 





;;=========================global variable declaration starting==============================;; 
                      EXPORT     KER_TASK_STACK
					  EXPORT     KER_TASK_ID
					  EXPORT     KER_NTASK
                      EXPORT     KER_TASK_PSP
					  EXPORT     KER_TASK_PRIO
					  EXPORT     KER_TASK_HI_PRIO
					  EXPORT     KER_TASK_PRIO_TID
					  EXPORT     KER_TASK_SLEEP
					  EXPORT     KER_TASK_YIELD
					  EXPORT     KER_TASK_STS
					  EXPORT     KER_TEMP0
					  EXPORT     KER_TEMP1
;;===========================global variable declaration end=================================;; 





;;===========================global variable definition starting=============================;; 
KER_TASK_STACK        SPACE      DEF_KER_STACK_SPACE+0x08          ;total stack space
KER_TASK_ID           SPACE      4                                 ;current task id
KER_NTASK             SPACE      4                                 ;total created tasks
KER_TASK_PSP          SPACE      4*DEF_KER_MAX_NTASK               ;PSP for 10 tasks
KER_TASK_PRIO         SPACE      4*DEF_KER_MAX_NTASK               ;task priority
KER_TASK_HI_PRIO      SPACE      4                                 ;highest priority
KER_TASK_PRIO_TID     SPACE      4                                 ;highest priority task_id
KER_TASK_SLEEP        SPACE      4*DEF_KER_MAX_NTASK               ;task sleep duration
KER_TASK_YIELD        SPACE      4                                 ;task yield status
KER_TASK_STS          SPACE      4*DEF_KER_MAX_NTASK               ;task status
KER_TEMP0             SPACE      4*DEF_KER_MAX_NTASK               ;temporary storage
KER_TEMP1             SPACE      4*DEF_KER_MAX_NTASK               ;temporary storage
;;=============================global variable definition end================================;; 





;;==============================code area definition starting================================;; 
                      AREA       |.text|, CODE, READONLY
;;=================================code area definition end==================================;; 





;;=========================global function declaration starting==============================;; 
					  EXPORT     Kernel_Init
					  EXPORT     Kernel_Start_Tasks
					  EXPORT     Kernel_Task_Create
					  EXPORT     Kernel_Idle_Task
					  EXPORT     Kernel_Demo_Task0
					  EXPORT     Kernel_Demo_Task1
					  EXPORT     Kernel_Demo_Task2
					  EXPORT     Kernel_Task_Sleep
					  EXPORT     SysTick_Handler
					  EXPORT     PendSV_Handler
;;===========================global function declaration end=================================;; 





;;===========================macro for gpio set starting=====================================;; 
                      MACRO                                        ;macro start
					  MACRO_GPIO_SET                               ;macro name
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000001                 ;bit0 set
					  STR        R1,   [R0]                        ;store val
                      MEND                                         ;macro end
;;=============================macro for gpio set end========================================;; 





;;===========================macro for gpio clear starting===================================;; 
					  MACRO                                        ;macro start
                      MACRO_GPIO_CLEAR                             ;macro name
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00010000                 ;bit0 clear
					  STR        R1,   [R0]                        ;store val
					  MEND                                         ;macro end
;;=============================macro for gpio clear end======================================;; 





;;======================macro for pushing R0-R3,R12,LR,PC,xPSR starting======================;; 
                      MACRO                                        ;macro start
					  MACRO_PUSH_R0_R3_R12_LR_PC_xPSR              ;macro name
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
					  MEND                                         ;macro end
;;=========================macro for pushing R0-R3,R12,LR,PC,xPSR end========================;; 





;;===========================macro for pushing R4-R11 starting===============================;; 
                      MACRO                                        ;macro start
					  MACRO_PUSH_R4_R11                            ;macro name
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
					  MEND                                         ;macro end
;;============================macro for pushing R4-R11 end===================================;; 





;;===========================macro for popping R4-R11 starting===============================;; 
					  MACRO                                        ;macro start
					  MACRO_POP_R11_R4                             ;macro name
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
                      MEND                                         ;macro end
;;==============================macro for popping R4-R11 end=================================;; 





;;================================macro for offset starting==================================;; 
					  MACRO                                        ;macro start
					  MACRO_OFFSET_CALC                            ;macro name
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R0,   [R0]                        ;load task_id val
					  LSLS       R0,   R0,  #2                     ;left shift 2 times to x4
                      MEND                                         ;macro end
;;===================================macro for offset end====================================;; 




;;==============================macro for saving psp starting================================;; 
					  MACRO                                        ;macro start
					  MACRO_SAVE_PSP                               ;macro name
					  MACRO_OFFSET_CALC                            ;calculate offset, ret R0
					  LDR        R1,   =KER_TASK_PSP               ;load task psp addr base
					  ADD        R0,   R0,  R1                     ;calc offset from psp base
					  MRS        R1,   PSP                         ;load PSP in R1
					  STR        R1,   [R0]                        ;set val to reg
                      MEND                                         ;macro end
;;=================================macro for saving psp end==================================;; 





;;==============================macro for loading psp starting===============================;; 
					  MACRO                                        ;macro start
					  MACRO_LOAD_PSP                               ;macro name
					  MACRO_OFFSET_CALC                            ;calculate offset, ret R0
					  LDR        R1,   =KER_TASK_PSP               ;load task psp addr base
					  ADD        R0,   R0,  R1                     ;calc offset from psp base
					  LDR        R0,   [R0]                        ;load task PSP
                      MEND                                         ;macro end
;;=================================macro for loading psp end=================================;; 





;;=======================macro for sleep time management starting============================;; 
					  MACRO                                        ;macro start
        		      MACRO_KER_SLP_TIME_MGNT $ML                  ;macro name, local label
					  LDR        R1,   =KER_TASK_YIELD             ;load yield flag addr
					  LDR        R2,   [R1]                        ;load yield flag val
					  TST        R2,   R2                          ;check if !=0
					  BNE        $ML.SLPDEC                        ;jmp to label
                      LDR        R2,   =0x00000000                 ;load val 0
					  STR        R2,   [R1]                        ;clear yield flag
					  B          $ML.EXIT                          ;jmp to label
$ML.SLPDEC                                                         ;sleep time decrement
					  MACRO_OFFSET_CALC                            ;calculate offset, ret R0
					  LDR        R1,   =KER_TASK_SLEEP             ;load sleep addr
					  ADDS       R1,   R1, R0                      ;sleep base+offset
					  LDR        R2,   [R1]                        ;load sleep duration
					  CMP        R2,   #0                          ;compare with 0
					  BEQ        $ML.TREADY                        ;jmp to label
					  SUBS       R2,   R2, #1                      ;decrease by 1
					  STR        R2,   [R1]                        ;store new val
					  CMP        R2,   #0                          ;compare with 0
					  BEQ        $ML.TREADY                        ;jmp to label
$ML.BLOCKED
					  LDR        R1,   =TASK_BLOCKED               ;set status blocked
					  B          $ML.UPDSTS                        ;jmp to label
$ML.TREADY                                                         ;label->task ready
					  LDR        R1,   =TASK_READY                 ;set status ready
$ML.UPDSTS                                                         ;label->update status
					  LDR        R2,   =KER_TASK_STS               ;load status base addr
					  ADDS       R2,   R2, R0                      ;base+offset
					  STR        R1,   [R2]                        ;store status
$ML.EXIT                                                           ;label->skip calculations
                      MEND                                         ;macro end
;;=========================macro for sleep time management end===============================;; 





;;============================macro for scheduler starting===================================;; 
					  MACRO                                        ;macro start
            		  MACRO_KER_RUN_SCHEDULER $ML1, $ML2           ;macro name, local label
					  
					  ;init values before loop entry
					  LDR        R0,   =0xFF                       ;set val
					  LDR        R1,   =KER_TASK_HI_PRIO           ;load hi-prio addr
					  STR        R0,   [R1]                        ;store lowest priority
					  LDR        R0,   =0                          ;set val
					  LDR        R1,   =KER_TASK_PRIO_TID          ;load prio tid addr
					  STR        R0,   [R1]                        ;store prio tid
					  LDR        R0,   =0                          ;set val
					  LDR        R1,   =KER_TASK_ID                ;load task_id addr
					  STR        R0,   [R1]                        ;store task_id
					  
$ML2.LP_STRT                                                       ;label-> loop start
					  MACRO_KER_SLP_TIME_MGNT $ML1                 ;time mangement
					  
					  ;calculate offset R0, load status 
					  LDR        R1,   =KER_TASK_STS               ;load status base addr
					  ADDS       R1,   R1, R0                      ;status base+offset
					  LDR        R1,   [R1]                        ;load status
					  
					  ;check if task ready
					  LDR        R2,   =TASK_READY                 ;load ready status
					  CMP        R1,   R2                          ;compare
					  BNE        $ML2.BL_OR_LP                      ;jmp to label (blocked)
					  
					  ;task is ready
					  LDR        R1,   =KER_TASK_HI_PRIO           ;load hi-prio addr
					  LDR        R2,   [R1]                        ;load hi-prio val
					  LDR        R3,   =KER_TASK_PRIO              ;load prio base addr
					  ADDS       R3,   R3, R0                      ;prio base+offset
					  LDR        R3,   [R3]                        ;load prio val
					  
					  ;check current priority >= highest priority (lower val is higher priority)
					  CMP        R3,   R2                          ;compare 
					  BHS        $ML2.BL_OR_LP                     ;jmp to label (low prio)
					  
					  ;new high prio found
					  STR        R3,   [R1]                        ;store new hi-prio
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R0,   [R0]                        ;load task_id val
					  LDR        R1,   =KER_TASK_PRIO_TID          ;load prio task_id addr
					  STR        R0,   [R1]                        ;store prio task_id
$ML2.BL_OR_LP                                                       ;label->blocked or low priority
                      LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   [R0]                        ;load task_id val
					  ADDS       R1,   R1, #1                      ;increment
					  LDR        R2,   =KER_NTASK                  ;load ntask addr
					  LDR        R2,   [R2]                        ;load ntask val
                      CMP        R1,   R2                          ;compare
					  BHS        $ML2.LP_END                       ;task_id>=ntask
					  STR        R1,   [R0]                        ;store new task_id
					  B          $ML2.LP_STRT                      ;loop start
					  
$ML2.LP_END                                                        ;loop complete
					  LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   =KER_TASK_PRIO_TID          ;load prio tid addr
					  LDR        R1,   [R1]                        ;load prio tid val
					  STR        R1,   [R0]                        ;store new prio tid
                      MEND                                         ;macro end
;;================================macro for scheduler end====================================;; 





;;===================================idle task starting======================================;; 
Kernel_Idle_Task
                      ;Idle task, does nothing
					  LDR        R0,    =100                        ;set 100ms sleep
					  BL         Kernel_Task_Sleep
					  B          .                                  ;forever loop
;;=====================================idle task end=========================================;; 





;;==================================demo task0 starting======================================;; 
Kernel_Demo_Task0
                      ;toggle pin PA1
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000002                 ;bit1 set
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00020000                 ;bit1 reset
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,    =5                         ;set 5ms sleep
					  BL         Kernel_Task_Sleep
					  B          Kernel_Demo_Task0                 ;forever loop
;;====================================demo task0 end=========================================;; 





;;==================================demo task1 starting======================================;; 
Kernel_Demo_Task1
					  ;toggle pin PA2
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000004                 ;bit1 set
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00040000                 ;bit1 reset
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,    =10                        ;set 10ms sleep
					  BL         Kernel_Task_Sleep
					  B          Kernel_Demo_Task1                 ;forever loop
;;====================================demo task1 end=========================================;; 





;;==================================demo task2 starting======================================;; 
Kernel_Demo_Task2
					  ;toggle pin PA3
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00000008                 ;bit1 set
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,   =0x50000018                 ;load BSRR address
					  LDR        R1,   =0x00080000                 ;bit1 reset
					  STR        R1,   [R0]                        ;store val
					  LDR        R0,    =15                        ;set 1ms sleep
					  BL         Kernel_Task_Sleep
					  B          Kernel_Demo_Task2                 ;forever loop
;;====================================demo task2 end=========================================;; 





;;==================================demo task3 starting======================================;; 
Kernel_Init
                      PUSH       {LR}
					  
					  ;set first task_id
                      LDR        R0,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   =0x00000000                 ;start from 0
					  STR        R1,   [R0]                        ;store task_id val
					  
					  ;set ntask
                      LDR        R0,   =KER_NTASK                  ;load ntask addr
					  LDR        R1,   =0x00000000                 ;start from 0
					  STR        R1,   [R0]                        ;store ntask val
					  
					  ;set PendSV as lowest priority interrupt
					  LDR        R0,   =DEF_SCB_SHPR3              ;load SHPR3 addr
					  LDR        R1,   =0xFF<<16                   ;set lowest priority
					  STR        R1,   [R0]                        ;store val
					  
					  ;clear task yield flag
                      LDR        R0,   =KER_TASK_YIELD             ;load ntask addr
					  LDR        R1,   =0x00000000                 ;start from 0
					  STR        R1,   [R0]                        ;store ntask val
					  
					  LDR        R0,   =Kernel_Idle_Task           ;load idle task addr
					  LDR        R1,   =0xFF                       ;lowest priority
					  BL         Kernel_Task_Create
					  
					  POP        {PC}
;;====================================demo task3 end=========================================;; 





;;=================================task create starting======================================;; 
Kernel_Task_Create
                      PUSH       {LR}
					  
					  ;calculate stack top for this task (R0:R1 are used by arguments)
					  LDR        R2,   =DEF_KER_STACK_SIZE         ;load each stack size
					  LDR        R3,   =KER_NTASK                  ;load ntask addr
					  LDR        R3,   [R3]                        ;load ntask val
					  ADDS       R3,   R3, #1                      ;task_id+1
					  MULS       R2,   R3, R2                      ;(task_id+1)*size
					  LDR        R3,   =KER_TASK_STACK             ;PSP start base
					  ADDS       R2,   R2, R3                      ;add offset
					  
					  ;create space for stack frame (R0:R1 arg, R2 stack top)
                      SUBS       R2,   #32                         ;space for R4-R11
                      SUBS       R2,   #32                         ;space for hardware frame
                      MOVS       R3,   #0                          ;clear reg
					  
					  ;create software stack (R0:R1 arg, R2 stack top, R3 for clearing)
					  STR        R3,   [R2, #0]                    ;R4
					  STR        R3,   [R2, #4]                    ;R5
					  STR        R3,   [R2, #8]                    ;R6
					  STR        R3,   [R2, #12]                   ;R7
					  STR        R3,   [R2, #16]                   ;R8
					  STR        R3,   [R2, #20]                   ;R9
					  STR        R3,   [R2, #24]                   ;R10
					  STR        R3,   [R2, #28]                   ;R11
					  
					  ;create hardware stack (R0:R1 arg, R2 stack top, R3 for clearing)
                      STR        R3,   [R2, #32]                   ;R0
                      STR        R3,   [R2, #36]                   ;R1
                      STR        R3,   [R2, #40]                   ;R2
                      STR        R3,   [R2, #44]                   ;R3
                      STR        R3,   [R2, #48]                   ;R12
                      STR        R3,   [R2, #52]                   ;LR
					  MOV        R3,   R0                          ;func addr
                      STR        R3,   [R2, #56]                   ;PC
                      LDR        R3,   =0x01000000                 ;thumb bit set
                      STR        R3,   [R2, #60]                   ;xPSR (Thumb)
					  
					  ;calculate offset(R1 arg, R2 stack top)
					  LDR        R0,   =KER_NTASK                  ;load ntask addr
					  LDR        R0,   [R0]                        ;load ntask val
					  LSLS       R0,   R0, #2                      ;left shift to x4
					  
					  ;store PSP (R0 offset, R1 arg, R2 stack top)
					  LDR        R3,   =KER_TASK_PSP               ;PSP base
					  ADDS       R3,   R3, R0                      ;PSP base+offset
					  STR        R2,   [R3]                        ;save PSP
					  
					  ;store priority (R0 offset, R1 arg)
					  LDR        R2,   =KER_TASK_PRIO              ;priority base
					  ADDS       R2,   R2, R0                      ;priority base+offset
					  STR        R1,   [R2]                        ;save priority
					  
					  ;store sleep (R0 offset)
					  LDR        R1,   =KER_TASK_SLEEP             ;sleep base
					  LDR        R2,   =0                          ;set sleep duration 0
					  ADDS       R1,   R1, R0                      ;sleep base+offset
					  STR        R2,   [R1]                        ;save sleep duration
					  
					  ;store status (R0 offset)
					  LDR        R1,   =KER_TASK_STS               ;priority base
					  LDR        R2,   =TASK_READY                 ;set status ready
					  ADDS       R1,   R1, R0                      ;priority base+offset
					  STR        R2,   [R1]                        ;save priority
					  
					  ;increment ntask (R0 offset)
					  LDR        R0,   =KER_NTASK                  ;load ntask addr
					  LDR        R1,   [R0]                        ;load ntask val
					  ADDS       R1,   R1, #1                      ;ntask+1
					  STR        R1,   [R0]                        ;save PSP
					  
					  POP        {PC}                              ;return
;;====================================task create end========================================;; 





;;=================================start tasks starting======================================;; 
Kernel_Start_Tasks
                      ;configure SysTick timer
                      LDR        R0,   =DEF_STK_LOAD               ;load stk_load reg address
					  LDR        R1,   =15999                      ;load val for 1ms
					  STR        R1,   [R0]                        ;set val to reg
					  LDR        R0,   =DEF_STK_VAL                ;load stk_val reg address
					  MOVS       R1,   #0                          ;clear reg
					  STR        R1,   [R0]                        ;clear stk_val reg
					  LDR        R0,   =DEF_STK_CTRL               ;load stk_ctrl reg address
					  MOVS       R1,   #7                          ;mask bit0, bit1 & bit2
					  STR        R1,   [R0]                        ;set val to stk_ctrl
					  
					  ;calculate stack top for this task
					  LDR        R0,   =DEF_KER_STACK_SIZE         ;load each stack size
					  LDR        R1,   =KER_TASK_STACK             ;PSP start base
					  ADDS       R0,   R0, R1                      ;add offset
					  
					  ;Setup PSP for main
                      MSR        PSP,  R0                          ;set PSP
                      MRS        R1,   CONTROL
					  LDR        R2,   =0x02
                      ORRS       R1,   R1, R2                      ;CONTROL.SPSEL = 1
                      MSR        CONTROL, R1                       ;switch to PSP
                      ISB                                          ;instruction barrier
					  B          Kernel_Idle_Task                  ;call a task
;;====================================start tasks end========================================;; 





;;=================================systick isr starting======================================;; 
SysTick_Handler
                      ;request for PendSV
					  LDR        R0,   =DEF_SCB_ICSR               ;load SCB->ICSR addr
					  LDR        R1,   =0x10000000                 ;load set_PendSV bit
					  STR        R1,   [R0]                        ;sote val
					  BX         LR                                ;return from interrupt
;;====================================systick isr end========================================;; 





;;=============================pending service isr starting==================================;; 
PendSV_Handler
                      ;Hardware pushed (address wise, high->low) xPSR,PC,LR,R12,R3-R0
					  ;Software pushed (address wise, high->low) R11-R4
                      CPSID      I                                 ;disable interrupts
					  
					  MACRO_GPIO_SET                               ;debug pin set
					  MACRO_PUSH_R4_R11                            ;push R4-R11 manually
					  MACRO_SAVE_PSP                               ;save psp
					  MACRO_KER_RUN_SCHEDULER ISRLBL2, ISRLBL3     ;run scheduler, local label
					  MACRO_LOAD_PSP                               ;load psp
					  MACRO_POP_R11_R4                             ;pop R11-R4 manually
					  MACRO_GPIO_CLEAR                             ;debug pin clear
					  
					  CPSIE      I                                 ;enable interrupt
					  BX         LR                                ;return from interrupt
;;================================pending service isr end====================================;; 





;;==============================kernel task sleep starting===================================;; 
Kernel_Task_Sleep
                      PUSH       {LR}                              ;store return addr
					  CPSID      I                                 ;disable interrupts
					  
					  ;find offset (R0 arg)
                      LDR        R1,   =KER_TASK_ID                ;load task_id addr
					  LDR        R1,   [R1]                        ;load task_id val
					  LSLS       R1,   R1,  #2                     ;left shift 2 times to x4
					  
					  ;set sleep val (R0 arg, R1 offset)
					  LDR        R2,   =KER_TASK_SLEEP             ;load sleep base addr
					  ADDS       R2,   R2, R1                      ;add offset
					  STR        R0,   [R2]                        ;store sleep duration
					  
					  ;set status (R1 offset)
					  LDR        R2,   =KER_TASK_STS               ;load status base addr
					  ADDS       R2,   R2, R1                      ;add offset
					  LDR        R1,   =TASK_BLOCKED               ;set status blocked
					  STR        R1,   [R2]                        ;store status
					  
					  ;set task yield flag
                      LDR        R0,   =KER_TASK_YIELD             ;load ntask addr
					  LDR        R1,   =0x00000001                 ;start from 0
					  STR        R1,   [R0]                        ;store ntask val
					  
					  LDR        R0,   =DEF_SCB_ICSR               ;load SCB->ICSR addr
					  LDR        R1,   =0x10000000                 ;load set_PendSV bit
					  STR        R1,   [R0]                        ;sote val
					  
					  CPSIE      I                                 ;enable interrupt
					  POP        {PC}                              ;return
;;=================================kernel task sleep end=====================================;; 



					  
					  
					  END                                          ;end of file
					  
					  

    
	
	