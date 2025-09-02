
                      THUMB                                      ;enable thumb mode
				      PRESERVE8                                  ;8 bytes stack alignment
	
                      AREA       |.constdata|, DATA, READONLY

;Define necessary address bases (constants)
DEF_CODE_BASE         EQU        0x00000000
DEF_SRAM_BASE         EQU        0x20000000
DEF_PERIPHERAL_BASE   EQU        0x40000000
DEF_FLASH_BASE        EQU        DEF_CODE_BASE       + 0x00000000
DEF_APB1_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00000000
DEF_APB2_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00010000
DEF_AHB_BASE          EQU        DEF_PERIPHERAL_BASE + 0x00020000
DEF_GPIO_BASE         EQU        0x50000000


;Define different peripheral address bases
DEF_RCC_BASE          EQU        DEF_AHB_BASE        + 0x00001000
DEF_GPIOA_BASE        EQU        DEF_GPIO_BASE       + 0x00000000
DEF_GPIOB_BASE        EQU        DEF_GPIO_BASE       + 0x00000400
DEF_GPIOC_BASE        EQU        DEF_GPIO_BASE       + 0x00000800
DEF_GPIOD_BASE        EQU        DEF_GPIO_BASE       + 0x00000C00


;Define different peripheral register addresses
DEF_RCC_IOPENR        EQU        DEF_RCC_BASE        + 0x00000034
DEF_GPIOA_MODER       EQU        DEF_GPIOA_BASE      + 0x00000000
DEF_GPIOA_ODR         EQU        DEF_GPIOA_BASE      + 0x00000014



                      AREA       |.text|, CODE, READONLY
						  
						  
						  
				      EXPORT     GPIO_Init
					  EXPORT     GPIO_Toggle
					  EXPORT     Delay
					  

GPIO_Init
                      ;save return address
                      PUSH       {LR}                            ;push return address
					  
					  ;enable clock from rcc
                      LDR        R0, =DEF_RCC_IOPENR             ;load IOPENR address
					  LDR        R1, [R0]                        ;load IOPENR val
					  LDR        R2, =0x00000001                 ;mask bit0
	                  ORRS       R1, R1, R2                      ;IOPENR |=(1<<0) 
					  STR        R1, [R0]                        ;store val to IOPENR
					  
					  
					  ;set pin as general purpose i/o
					  LDR        R0, =DEF_GPIOA_MODER            ;load MODER address
					  LDR        R1, [R0]                        ;load MODER val
					  LDR        R2, =0x00000300                 ;mask bit8 & 9
					  MVNS       R2, R2                          ;invert bits
					  ANDS       R1, R1, R2                      ;clear bits
					  LDR        R2, =0x00000100                 ;mask bit8
					  ORRS       R1, R1, R2                      ;set bit8
					  STR        R1, [R0]                        ;store val to MODER
					  
					  ;set ODR pin high to turn off LED
					  LDR        R0, =DEF_GPIOA_ODR              ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  LDR        R2, =0x00000010                 ;mask bit8
					  ORRS       R1, R1, R2                      ;set bit8
					  STR        R1, [R0]                        ;store val to ODR
					  
					  ;return from function
					  POP        {PC}                            ;jump to return address
					  
					  
					  
GPIO_Toggle
                      PUSH       {LR}                            ;push return address
					  
					  ;toggle pin PA4
					  LDR        R0, =DEF_GPIOA_ODR              ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  MOVS       R2, #0x10                       ;mask bit4
					  EORS       R1, R1, R2                      ;xor 4th bit
					  STR        R1, [R0]                        ;store val to ODR
					  
					  POP        {PC}
					  
					  
					  
					  
Delay
                      PUSH       {LR}                            ;push return address
					  
					  ;delay some cycles
					  LDR        R0, =1600000                    ;load delay cycle val
DelaySome
                      SUBS       R0, R0, #1
					  BNE        DelaySome
					  
					  POP        {PC}
					  
					  
					  
					  
					  
					  
					  
                      END                                        ;end of file
    