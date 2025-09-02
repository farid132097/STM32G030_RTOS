
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
						  
						  
						  

    