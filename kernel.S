
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
	

                      AREA       |.text|, CODE, READONLY
					  
					  
					  
                      
					  EXPORT     Kernel_Systick_Init
					  EXPORT     SysTick_Handler
					  IMPORT     GPIO_Toggle
                      
Kernel_Systick_Init
                      PUSH       {LR}                            ;push return address
                      LDR        R0, =DEF_STK_LOAD               ;load stk_load reg address
					  LDR        R1, =15999                      ;load val for 1ms
					  STR        R1, [R0]                        ;set val to reg
					  LDR        R0, =DEF_STK_VAL                ;load stk_val reg address
					  MOVS       R1, #0                          ;clear reg
					  STR        R1, [R0]                        ;clear stk_val reg
					  LDR        R0, =DEF_STK_CTRL               ;load stk_ctrl reg address
					  MOVS       R1, #7                          ;mask bit0, bit1 & bit2
					  STR        R1, [R0]                        ;set val to stk_ctrl
					  POP        {PC}
					  
SysTick_Handler
                      PUSH       {R4-R7}                         ;push regs
					  LDR        R0, =0x50000014                 ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  MOVS       R2, #0x02                       ;pin number
					  MOVS       R3, #0x01                       ;assign 1
					  LSLS       R3, R3, R2                      ;lsl by pin number
					  EORS       R1, R1, R3                      ;xor 4th bit
					  STR        R1, [R0]                        ;store val to ODR
					  POP        {R4-R7}                         ;pop regs
					  BX         LR                              ;return from interrupt
					  
					  
					  
					  
                      END                                        ;end of file

    