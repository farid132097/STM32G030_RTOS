
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
					  AREA    |.data|, DATA, READWRITE, ALIGN=2
					  
				      ;enlist global variables
					  EXPORT     Current_TCB
                      EXPORT     Next_TCB
					  
					  ;assign variables with size
Current_TCB           DCD        0                                 ;pointer to current task's PSP
Next_TCB              DCD        0                                 ;pointer to next task's PSP
					  

                      ;code area starts
                      AREA       |.text|, CODE, READONLY
					  
                      ;enlist global functions
					  EXPORT     Kernel_Systick_Init
				      EXPORT     Kernel_Idle_Task
					  EXPORT     SysTick_Handler
					  IMPORT     GPIO_Toggle
						  
Kernel_Idle_Task
KERNEL_IDLE_LOOP
					  B          KERNEL_IDLE_LOOP                  ;forever loop
                      
					  
					  
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
                      LDR        R0,   =0x20001000                 ;address of main stack
                      MSR        PSP,  R0                          ;set PSP
                      MRS        R1,   CONTROL
					  LDR        R2,   =2
                      ORRS       R1,   R1, R2                      ;CONTROL.SPSEL = 1 ? use PSP in thread mode
                      MSR        CONTROL, R1                       ;switch to PSP
                      ISB                                          ;instruction barrier
					  BL         Kernel_Idle_Task                  ;call idle task
					  
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
					  
					  
					  
					  ;toggle PA11
					  LDR        R0,   =0x50000014                 ;load ODR address
					  LDR        R1,   [R0]                        ;load ODR val
					  MOVS       R2,   #0x0B                       ;pin number
					  MOVS       R3,   #0x01                       ;assign 1
					  LSLS       R3,   R3, R2                      ;lsl by pin number
					  EORS       R1,   R1, R3                      ;xor 4th bit
					  STR        R1,   [R0]                        ;store val to ODR
					  
					  ;save test values
					  MOVS       R4,   #0x0A                       ;set test val
					  MOVS       R5,   #0x0B                       ;set test val
					  MOVS       R6,   #0x0C                       ;set test val
					  MOVS       R7,   #0x0D                       ;set test val
					  MOV        R8,   R4                          ;set test val
					  MOV        R9,   R5                          ;set test val
					  MOV        R10,  R6                          ;set test val
					  MOV        R11,  R7                          ;set test val
					  
					  
					  ;pop R11-R4 manually
					  MRS        R0,   PSP                         ;load PSP in R0
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
                      LDR        R0,   =Current_TCB                ;load current tcb addr
                      LDR        R1,   [R0]                        ;R1 current task sp
					  MOVS       R3,   #32                         ;load val
					  SUBS       R1,   R1, R3                      ;start = end - 32
                      STMIA      R1!,  {R4-R7}                     ;store R4-R7, R1 -> start+16
                      MOV        R2,   R8                          ;copy
                      STR        R2,   [R1]                        ;store R8
                      ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R2,   R9                          ;copy
                      STR        R2,   [R1]                        ;store R8
                      ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R2,   R10                         ;copy
                      STR        R2,   [R1]                        ;store R8
                      ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R2,   R11                         ;copy
                      STR        R2,   [R1]                        ;store R8
                      ADDS       R1,   R1, #4                      ;inc +4
					  STR        R1,   [R0]                        ;save updated SP
					  
					  ;load next task
                      LDR        R0,   =Next_TCB                   ;load next tcb addr
					  LDR        R1,   [R0]                        ;R1 next task sp
					  
					  ;restore 
					  MOVS       R3,   #32                         ;load val
					  SUBS       R1,   R1, R3                      ;go to start of saved context
                      LDMIA      R1!,  {R4-R7}                     ;restore R4-R7, R1 -> start+16
                      LDR        R2,   [R1]                        ;load 
					  ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R8,   R2                          ;copy
					  
					  LDR        R2,   [R1]                        ;load 
					  ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R9,   R2                          ;copy
					  
					  LDR        R2,   [R1]                        ;load 
					  ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R10,  R2                           ;copy
					  
					  LDR        R2,   [R1]                        ;load 
					  ADDS       R1,   R1, #4                      ;inc +4
					  MOV        R11,  R2                           ;copy
					  
                      ;switch PSP to next task
                      MSR        PSP,  R1                           ;switch PSP
					  
					  ;update Current_TCB pointer
					  LDR        R0,   =Current_TCB                ;load current tcb addr
					  LDR        R2,   =Next_TCB                   ;load next tcb addr
					  LDR        R3,   [R2]                        ;R3 = next saved-SP (end)
					  STR        R3,   [R0]                        ;store
					  
                      CPSIE      I                                 ;enable interrupt
                      BX LR                                        ;return from exception
					  

    
	
	