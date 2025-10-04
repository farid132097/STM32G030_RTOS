
                      THUMB                                      ;enable thumb mode
				      PRESERVE8                                  ;8 bytes stack alignment
	
                      AREA       |.constdata|, DATA, READONLY

;define necessary address bases (constants)
DEF_CODE_BASE         EQU        0x00000000
DEF_SRAM_BASE         EQU        0x20000000
DEF_PERIPHERAL_BASE   EQU        0x40000000
DEF_FLASH_BASE        EQU        DEF_CODE_BASE       + 0x00000000
DEF_APB1_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00000000
DEF_APB2_BASE         EQU        DEF_PERIPHERAL_BASE + 0x00010000
DEF_AHB_BASE          EQU        DEF_PERIPHERAL_BASE + 0x00020000
DEF_GPIO_BASE         EQU        0x50000000


;define different peripheral address bases
DEF_RCC_BASE          EQU        DEF_AHB_BASE        + 0x00001000
DEF_GPIOA_BASE        EQU        DEF_GPIO_BASE       + 0x00000000
DEF_GPIOB_BASE        EQU        DEF_GPIO_BASE       + 0x00000400
DEF_GPIOC_BASE        EQU        DEF_GPIO_BASE       + 0x00000800
DEF_GPIOD_BASE        EQU        DEF_GPIO_BASE       + 0x00000C00


;define different peripheral register addresses
DEF_RCC_IOPENR        EQU        DEF_RCC_BASE        + 0x00000034
DEF_GPIOA_MODER       EQU        DEF_GPIOA_BASE      + 0x00000000
DEF_GPIOA_ODR         EQU        DEF_GPIOA_BASE      + 0x00000014


DEF_GPIO_PIN_NUMBER   EQU        0x0000000B
DEF_GPIO_MODER_MASK   EQU        0x00000003
DEF_GPIO_MODER_INPUT  EQU        0x00000000
DEF_GPIO_MODER_OUTPUT EQU        0x00000001
DEF_GPIO_MODER_ALTFNC EQU        0x00000002
DEF_GPIO_MODER_ANALOG EQU        0x00000003



                      AREA       |.text|, CODE, READONLY
						  
						  
					  EXPORT     GPIO_Init  
				      EXPORT     GPIO_High
					  EXPORT     GPIO_Low
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
					  
					  ;set ODR pin high to turn off LED
					  LDR        R0, =DEF_GPIOA_ODR              ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  MOVS       R2, #0x01                       ;assign 1
					  LDR        R3, =DEF_GPIO_PIN_NUMBER        ;mask pin number
					  LSLS       R2, R2, R3                      ;lsl by pin number
					  ORRS       R1, R1, R2                      ;set bit of the pin
					  STR        R1, [R0]                        ;store val to ODR
					  
					  ;set pin as general purpose i/o
					  LDR        R0, =DEF_GPIOA_MODER            ;load MODER address
					  LDR        R1, [R0]                        ;load MODER val
					  LDR        R2, =DEF_GPIO_PIN_NUMBER        ;load pin number
					  LSLS       R2, R2, #0x01                   ;left shift to x2
					  LDR        R3, =DEF_GPIO_MODER_MASK        ;load gp output val
					  LSLS       R3, R3, R2                      ;lsl by pin number
					  MVNS       R3, R3                          ;bitwise not
					  ANDS       R1, R1, R3                      ;clear moder bits
					  LDR        R3, =DEF_GPIO_MODER_OUTPUT      ;load gp output val
					  LSLS       R3, R3, R2                      ;lsl by pin number
					  ORRS       R1, R1, R3                      ;or with output val
					  STR        R1, [R0]                        ;store val to MODER
					  
					  ;return from function
					  POP        {PC}                            ;jump to return address
					  
					  
					  
GPIO_High
                      PUSH       {LR}                            ;push return address
					  LDR        R0, =DEF_GPIOA_ODR              ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  MOVS       R2, #0x01                       ;assign 1
					  LDR        R3, =DEF_GPIO_PIN_NUMBER        ;mask pin number
					  LSLS       R2, R2, R3                      ;lsl by pin number
					  ORRS       R1, R1, R2                      ;set bit of the pin
					  STR        R1, [R0]                        ;store val to ODR
					  POP        {PC}
					  
GPIO_Low
                      PUSH       {LR}                            ;push return address
					  LDR        R0, =DEF_GPIOA_ODR              ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  MOVS       R2, #0x01                       ;assign 1
					  LDR        R3, =DEF_GPIO_PIN_NUMBER        ;mask pin number
					  LSLS       R2, R2, R3                      ;lsl by pin number
					  MVNS       R2, R2                          ;bitwise not
					  ANDS       R1, R1, R2                      ;set bit of the pin
					  STR        R1, [R0]                        ;store val to ODR
					  POP        {PC}
					  
GPIO_Toggle
                      PUSH       {LR}                            ;push return address
					  
					  ;toggle pin PA4
					  LDR        R0, =DEF_GPIOA_ODR              ;load ODR address
					  LDR        R1, [R0]                        ;load ODR val
					  LDR        R2, =DEF_GPIO_PIN_NUMBER        ;mask pin number
					  MOVS       R3, #0x01                       ;assign 1
					  LSLS       R3, R3, R2                      ;lsl by pin number
					  EORS       R1, R1, R3                      ;xor 4th bit
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
    
	
	