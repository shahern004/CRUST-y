/*
 * Startup code for STM32H573I-DK (ARM Cortex-M33)
 *
 * This file provides:
 *   - Vector table with all interrupt handlers
 *   - Reset handler that initializes .data and .bss
 *   - Default weak handlers for all interrupts
 *   - Stack pointer initialization
 */

    .syntax unified
    .cpu cortex-m33
    .fpu fpv5-sp-d16
    .thumb

/* Import symbols from linker script */
    .global _estack
    .global _sidata
    .global _sdata
    .global _edata
    .global _sbss
    .global _ebss

/* Entry point */
    .global Reset_Handler
    .type Reset_Handler, %function

/* Vector Table */
    .section .isr_vector,"a",%progbits
    .type g_pfnVectors, %object
    .size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
    /* Cortex-M33 System Exceptions */
    .word   _estack                     /* 0: Initial Stack Pointer */
    .word   Reset_Handler               /* 1: Reset Handler */
    .word   NMI_Handler                 /* 2: Non-Maskable Interrupt */
    .word   HardFault_Handler           /* 3: Hard Fault */
    .word   MemManage_Handler           /* 4: Memory Management Fault */
    .word   BusFault_Handler            /* 5: Bus Fault */
    .word   UsageFault_Handler          /* 6: Usage Fault */
    .word   SecureFault_Handler         /* 7: Secure Fault (Cortex-M33) */
    .word   0                           /* 8: Reserved */
    .word   0                           /* 9: Reserved */
    .word   0                           /* 10: Reserved */
    .word   SVC_Handler                 /* 11: Supervisor Call */
    .word   DebugMon_Handler            /* 12: Debug Monitor */
    .word   0                           /* 13: Reserved */
    .word   PendSV_Handler              /* 14: Pendable Service Call */
    .word   SysTick_Handler             /* 15: System Tick Timer */

    /* STM32H573-specific External Interrupts (IRQ 0-115) */
    .word   WWDG_IRQHandler             /* 16: Window Watchdog */
    .word   PVD_PVM_IRQHandler          /* 17: PVD/PVM through EXTI */
    .word   RTC_IRQHandler              /* 18: RTC */
    .word   RTC_S_IRQHandler            /* 19: RTC Secure */
    .word   TAMP_IRQHandler             /* 20: Tamper */
    .word   RAMCFG_IRQHandler           /* 21: RAM Config */
    .word   FLASH_IRQHandler            /* 22: Flash */
    .word   FLASH_S_IRQHandler          /* 23: Flash Secure */
    .word   GTZC_IRQHandler             /* 24: Global TrustZone */
    .word   RCC_IRQHandler              /* 25: RCC */
    .word   RCC_S_IRQHandler            /* 26: RCC Secure */
    .word   EXTI0_IRQHandler            /* 27: EXTI Line 0 */
    .word   EXTI1_IRQHandler            /* 28: EXTI Line 1 */
    .word   EXTI2_IRQHandler            /* 29: EXTI Line 2 (CFPGA) */
    .word   EXTI3_IRQHandler            /* 30: EXTI Line 3 */
    .word   EXTI4_IRQHandler            /* 31: EXTI Line 4 */
    .word   EXTI5_IRQHandler            /* 32: EXTI Line 5 */
    .word   EXTI6_IRQHandler            /* 33: EXTI Line 6 */
    .word   EXTI7_IRQHandler            /* 34: EXTI Line 7 */
    .word   EXTI8_IRQHandler            /* 35: EXTI Line 8 */
    .word   EXTI9_IRQHandler            /* 36: EXTI Line 9 */
    .word   EXTI10_IRQHandler           /* 37: EXTI Line 10 */
    .word   EXTI11_IRQHandler           /* 38: EXTI Line 11 */
    .word   EXTI12_IRQHandler           /* 39: EXTI Line 12 */
    .word   EXTI13_IRQHandler           /* 40: EXTI Line 13 */
    .word   EXTI14_IRQHandler           /* 41: EXTI Line 14 */
    .word   EXTI15_IRQHandler           /* 42: EXTI Line 15 */
    .word   IWDG_IRQHandler             /* 43: Independent Watchdog */
    .word   0                           /* 44: Reserved */
    .word   GPDMA1_Channel0_IRQHandler  /* 45: GPDMA1 Channel 0 */
    .word   GPDMA1_Channel1_IRQHandler  /* 46: GPDMA1 Channel 1 */
    .word   GPDMA1_Channel2_IRQHandler  /* 47: GPDMA1 Channel 2 */
    .word   GPDMA1_Channel3_IRQHandler  /* 48: GPDMA1 Channel 3 */
    .word   GPDMA1_Channel4_IRQHandler  /* 49: GPDMA1 Channel 4 */
    .word   GPDMA1_Channel5_IRQHandler  /* 50: GPDMA1 Channel 5 */
    .word   GPDMA1_Channel6_IRQHandler  /* 51: GPDMA1 Channel 6 */
    .word   GPDMA1_Channel7_IRQHandler  /* 52: GPDMA1 Channel 7 */
    .word   ADC1_IRQHandler             /* 53: ADC1 */
    .word   DAC1_IRQHandler             /* 54: DAC1 */
    .word   FDCAN1_IT0_IRQHandler       /* 55: FDCAN1 IT0 */
    .word   FDCAN1_IT1_IRQHandler       /* 56: FDCAN1 IT1 */
    .word   TIM1_BRK_IRQHandler         /* 57: TIM1 Break */
    .word   TIM1_UP_IRQHandler          /* 58: TIM1 Update */
    .word   TIM1_TRG_COM_IRQHandler     /* 59: TIM1 Trigger/Commutation */
    .word   TIM1_CC_IRQHandler          /* 60: TIM1 Capture Compare */
    .word   TIM2_IRQHandler             /* 61: TIM2 */
    .word   TIM3_IRQHandler             /* 62: TIM3 */
    .word   TIM4_IRQHandler             /* 63: TIM4 */
    .word   TIM5_IRQHandler             /* 64: TIM5 */
    .word   TIM6_IRQHandler             /* 65: TIM6 */
    .word   TIM7_IRQHandler             /* 66: TIM7 */
    .word   I2C1_EV_IRQHandler          /* 67: I2C1 Event */
    .word   I2C1_ER_IRQHandler          /* 68: I2C1 Error */
    .word   I2C2_EV_IRQHandler          /* 69: I2C2 Event */
    .word   I2C2_ER_IRQHandler          /* 70: I2C2 Error */
    .word   SPI1_IRQHandler             /* 71: SPI1 */
    .word   SPI2_IRQHandler             /* 72: SPI2 */
    .word   SPI3_IRQHandler             /* 73: SPI3 */
    .word   USART1_IRQHandler           /* 74: USART1 */
    .word   USART2_IRQHandler           /* 75: USART2 */
    .word   USART3_IRQHandler           /* 76: USART3 */
    .word   UART4_IRQHandler            /* 77: UART4 (Debug UART) */
    .word   UART5_IRQHandler            /* 78: UART5 */
    .word   LPUART1_IRQHandler          /* 79: LPUART1 */
    .word   LPTIM1_IRQHandler           /* 80: LPTIM1 */
    .word   TIM8_BRK_IRQHandler         /* 81: TIM8 Break */
    .word   TIM8_UP_IRQHandler          /* 82: TIM8 Update */
    .word   TIM8_TRG_COM_IRQHandler     /* 83: TIM8 Trigger/Commutation */
    .word   TIM8_CC_IRQHandler          /* 84: TIM8 Capture Compare */
    .word   ADC2_IRQHandler             /* 85: ADC2 */
    .word   LPTIM2_IRQHandler           /* 86: LPTIM2 */
    .word   TIM15_IRQHandler            /* 87: TIM15 */
    .word   TIM16_IRQHandler            /* 88: TIM16 */
    .word   TIM17_IRQHandler            /* 89: TIM17 */
    .word   USB_DRD_FS_IRQHandler       /* 90: USB DRD FS */
    .word   CRS_IRQHandler              /* 91: CRS */
    .word   UCPD1_IRQHandler            /* 92: UCPD1 */
    .word   FMC_IRQHandler              /* 93: FMC */
    .word   OCTOSPI1_IRQHandler         /* 94: OCTOSPI1 */
    .word   SDMMC1_IRQHandler           /* 95: SDMMC1 */
    .word   I2C3_EV_IRQHandler          /* 96: I2C3 Event */
    .word   I2C3_ER_IRQHandler          /* 97: I2C3 Error */
    .word   SPI4_IRQHandler             /* 98: SPI4 */
    .word   SPI5_IRQHandler             /* 99: SPI5 */
    .word   SPI6_IRQHandler             /* 100: SPI6 */
    .word   USART6_IRQHandler           /* 101: USART6 */
    .word   USART10_IRQHandler          /* 102: USART10 */
    .word   USART11_IRQHandler          /* 103: USART11 */
    .word   SAI1_IRQHandler             /* 104: SAI1 */
    .word   SAI2_IRQHandler             /* 105: SAI2 */
    .word   GPDMA2_Channel0_IRQHandler  /* 106: GPDMA2 Channel 0 */
    .word   GPDMA2_Channel1_IRQHandler  /* 107: GPDMA2 Channel 1 */
    .word   GPDMA2_Channel2_IRQHandler  /* 108: GPDMA2 Channel 2 */
    .word   GPDMA2_Channel3_IRQHandler  /* 109: GPDMA2 Channel 3 */
    .word   GPDMA2_Channel4_IRQHandler  /* 110: GPDMA2 Channel 4 */
    .word   GPDMA2_Channel5_IRQHandler  /* 111: GPDMA2 Channel 5 */
    .word   GPDMA2_Channel6_IRQHandler  /* 112: GPDMA2 Channel 6 */
    .word   GPDMA2_Channel7_IRQHandler  /* 113: GPDMA2 Channel 7 */
    .word   FPU_IRQHandler              /* 114: FPU */
    .word   ICACHE_IRQHandler           /* 115: ICACHE */
    .word   DCACHE1_IRQHandler          /* 116: DCACHE1 */
    .word   DTS_IRQHandler              /* 117: DTS */
    .word   RNG_IRQHandler              /* 118: RNG */
    .word   HASH_IRQHandler             /* 119: HASH */
    .word   CEC_IRQHandler              /* 120: CEC */
    .word   TIM12_IRQHandler            /* 121: TIM12 */
    .word   TIM13_IRQHandler            /* 122: TIM13 */
    .word   TIM14_IRQHandler            /* 123: TIM14 */
    .word   I3C1_EV_IRQHandler          /* 124: I3C1 Event */
    .word   I3C1_ER_IRQHandler          /* 125: I3C1 Error */
    .word   I2C4_EV_IRQHandler          /* 126: I2C4 Event */
    .word   I2C4_ER_IRQHandler          /* 127: I2C4 Error */
    .word   LPTIM3_IRQHandler           /* 128: LPTIM3 */
    .word   LPTIM4_IRQHandler           /* 129: LPTIM4 */
    .word   LPTIM5_IRQHandler           /* 130: LPTIM5 */
    .word   LPTIM6_IRQHandler           /* 131: LPTIM6 */

/*
 * Reset Handler
 * Executed on power-up and reset
 */
    .section .text.Reset_Handler
    .weak Reset_Handler
    .type Reset_Handler, %function
Reset_Handler:
    /* Copy .data section from Flash to RAM */
    ldr r0, =_sdata         /* Destination (RAM) */
    ldr r1, =_edata         /* End of destination */
    ldr r2, =_sidata        /* Source (Flash) */
    movs r3, #0
    b copy_data_check

copy_data_loop:
    ldr r4, [r2, r3]        /* Read from Flash */
    str r4, [r0, r3]        /* Write to RAM */
    adds r3, r3, #4         /* Next word */

copy_data_check:
    adds r4, r0, r3         /* Calculate current RAM address */
    cmp r4, r1              /* Compare with end address */
    bcc copy_data_loop      /* Loop if not done */

    /* Zero-initialize .bss section */
    ldr r0, =_sbss          /* Start of .bss */
    ldr r1, =_ebss          /* End of .bss */
    movs r2, #0
    b zero_bss_check

zero_bss_loop:
    str r2, [r0]            /* Write zero */
    adds r0, r0, #4         /* Next word */

zero_bss_check:
    cmp r0, r1              /* Compare with end address */
    bcc zero_bss_loop       /* Loop if not done */

    /* Call system initialization (clock setup, FPU enable, caches) */
    /* This function will be implemented in system_stm32h5xx.c */
    bl SystemInit

    /* Call C++ constructors for global objects */
    bl __libc_init_array

    /* Call main() */
    bl main

    /* If main returns, loop forever */
    b .

    .size Reset_Handler, .-Reset_Handler

/*
 * Default handlers for all interrupts
 * Weak aliases - can be overridden by actual implementation
 */
    .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
    b Infinite_Loop
    .size Default_Handler, .-Default_Handler

/* Weak aliases for all exception/interrupt handlers */
    .weak NMI_Handler
    .thumb_set NMI_Handler,Default_Handler

    .weak HardFault_Handler
    .thumb_set HardFault_Handler,Default_Handler

    .weak MemManage_Handler
    .thumb_set MemManage_Handler,Default_Handler

    .weak BusFault_Handler
    .thumb_set BusFault_Handler,Default_Handler

    .weak UsageFault_Handler
    .thumb_set UsageFault_Handler,Default_Handler

    .weak SecureFault_Handler
    .thumb_set SecureFault_Handler,Default_Handler

    .weak SVC_Handler
    .thumb_set SVC_Handler,Default_Handler

    .weak DebugMon_Handler
    .thumb_set DebugMon_Handler,Default_Handler

    .weak PendSV_Handler
    .thumb_set PendSV_Handler,Default_Handler

    .weak SysTick_Handler
    .thumb_set SysTick_Handler,Default_Handler

    /* External Interrupts */
    .weak WWDG_IRQHandler
    .thumb_set WWDG_IRQHandler,Default_Handler

    .weak PVD_PVM_IRQHandler
    .thumb_set PVD_PVM_IRQHandler,Default_Handler

    .weak RTC_IRQHandler
    .thumb_set RTC_IRQHandler,Default_Handler

    .weak RTC_S_IRQHandler
    .thumb_set RTC_S_IRQHandler,Default_Handler

    .weak TAMP_IRQHandler
    .thumb_set TAMP_IRQHandler,Default_Handler

    .weak RAMCFG_IRQHandler
    .thumb_set RAMCFG_IRQHandler,Default_Handler

    .weak FLASH_IRQHandler
    .thumb_set FLASH_IRQHandler,Default_Handler

    .weak FLASH_S_IRQHandler
    .thumb_set FLASH_S_IRQHandler,Default_Handler

    .weak GTZC_IRQHandler
    .thumb_set GTZC_IRQHandler,Default_Handler

    .weak RCC_IRQHandler
    .thumb_set RCC_IRQHandler,Default_Handler

    .weak RCC_S_IRQHandler
    .thumb_set RCC_S_IRQHandler,Default_Handler

    .weak EXTI0_IRQHandler
    .thumb_set EXTI0_IRQHandler,Default_Handler

    .weak EXTI1_IRQHandler
    .thumb_set EXTI1_IRQHandler,Default_Handler

    .weak EXTI2_IRQHandler
    .thumb_set EXTI2_IRQHandler,Default_Handler

    .weak EXTI3_IRQHandler
    .thumb_set EXTI3_IRQHandler,Default_Handler

    .weak EXTI4_IRQHandler
    .thumb_set EXTI4_IRQHandler,Default_Handler

    .weak EXTI5_IRQHandler
    .thumb_set EXTI5_IRQHandler,Default_Handler

    .weak EXTI6_IRQHandler
    .thumb_set EXTI6_IRQHandler,Default_Handler

    .weak EXTI7_IRQHandler
    .thumb_set EXTI7_IRQHandler,Default_Handler

    .weak EXTI8_IRQHandler
    .thumb_set EXTI8_IRQHandler,Default_Handler

    .weak EXTI9_IRQHandler
    .thumb_set EXTI9_IRQHandler,Default_Handler

    .weak EXTI10_IRQHandler
    .thumb_set EXTI10_IRQHandler,Default_Handler

    .weak EXTI11_IRQHandler
    .thumb_set EXTI11_IRQHandler,Default_Handler

    .weak EXTI12_IRQHandler
    .thumb_set EXTI12_IRQHandler,Default_Handler

    .weak EXTI13_IRQHandler
    .thumb_set EXTI13_IRQHandler,Default_Handler

    .weak EXTI14_IRQHandler
    .thumb_set EXTI14_IRQHandler,Default_Handler

    .weak EXTI15_IRQHandler
    .thumb_set EXTI15_IRQHandler,Default_Handler

    .weak IWDG_IRQHandler
    .thumb_set IWDG_IRQHandler,Default_Handler

    .weak GPDMA1_Channel0_IRQHandler
    .thumb_set GPDMA1_Channel0_IRQHandler,Default_Handler

    .weak GPDMA1_Channel1_IRQHandler
    .thumb_set GPDMA1_Channel1_IRQHandler,Default_Handler

    .weak GPDMA1_Channel2_IRQHandler
    .thumb_set GPDMA1_Channel2_IRQHandler,Default_Handler

    .weak GPDMA1_Channel3_IRQHandler
    .thumb_set GPDMA1_Channel3_IRQHandler,Default_Handler

    .weak GPDMA1_Channel4_IRQHandler
    .thumb_set GPDMA1_Channel4_IRQHandler,Default_Handler

    .weak GPDMA1_Channel5_IRQHandler
    .thumb_set GPDMA1_Channel5_IRQHandler,Default_Handler

    .weak GPDMA1_Channel6_IRQHandler
    .thumb_set GPDMA1_Channel6_IRQHandler,Default_Handler

    .weak GPDMA1_Channel7_IRQHandler
    .thumb_set GPDMA1_Channel7_IRQHandler,Default_Handler

    .weak ADC1_IRQHandler
    .thumb_set ADC1_IRQHandler,Default_Handler

    .weak DAC1_IRQHandler
    .thumb_set DAC1_IRQHandler,Default_Handler

    .weak FDCAN1_IT0_IRQHandler
    .thumb_set FDCAN1_IT0_IRQHandler,Default_Handler

    .weak FDCAN1_IT1_IRQHandler
    .thumb_set FDCAN1_IT1_IRQHandler,Default_Handler

    .weak TIM1_BRK_IRQHandler
    .thumb_set TIM1_BRK_IRQHandler,Default_Handler

    .weak TIM1_UP_IRQHandler
    .thumb_set TIM1_UP_IRQHandler,Default_Handler

    .weak TIM1_TRG_COM_IRQHandler
    .thumb_set TIM1_TRG_COM_IRQHandler,Default_Handler

    .weak TIM1_CC_IRQHandler
    .thumb_set TIM1_CC_IRQHandler,Default_Handler

    .weak TIM2_IRQHandler
    .thumb_set TIM2_IRQHandler,Default_Handler

    .weak TIM3_IRQHandler
    .thumb_set TIM3_IRQHandler,Default_Handler

    .weak TIM4_IRQHandler
    .thumb_set TIM4_IRQHandler,Default_Handler

    .weak TIM5_IRQHandler
    .thumb_set TIM5_IRQHandler,Default_Handler

    .weak TIM6_IRQHandler
    .thumb_set TIM6_IRQHandler,Default_Handler

    .weak TIM7_IRQHandler
    .thumb_set TIM7_IRQHandler,Default_Handler

    .weak I2C1_EV_IRQHandler
    .thumb_set I2C1_EV_IRQHandler,Default_Handler

    .weak I2C1_ER_IRQHandler
    .thumb_set I2C1_ER_IRQHandler,Default_Handler

    .weak I2C2_EV_IRQHandler
    .thumb_set I2C2_EV_IRQHandler,Default_Handler

    .weak I2C2_ER_IRQHandler
    .thumb_set I2C2_ER_IRQHandler,Default_Handler

    .weak SPI1_IRQHandler
    .thumb_set SPI1_IRQHandler,Default_Handler

    .weak SPI2_IRQHandler
    .thumb_set SPI2_IRQHandler,Default_Handler

    .weak SPI3_IRQHandler
    .thumb_set SPI3_IRQHandler,Default_Handler

    .weak USART1_IRQHandler
    .thumb_set USART1_IRQHandler,Default_Handler

    .weak USART2_IRQHandler
    .thumb_set USART2_IRQHandler,Default_Handler

    .weak USART3_IRQHandler
    .thumb_set USART3_IRQHandler,Default_Handler

    .weak UART4_IRQHandler
    .thumb_set UART4_IRQHandler,Default_Handler

    .weak UART5_IRQHandler
    .thumb_set UART5_IRQHandler,Default_Handler

    .weak LPUART1_IRQHandler
    .thumb_set LPUART1_IRQHandler,Default_Handler

    .weak LPTIM1_IRQHandler
    .thumb_set LPTIM1_IRQHandler,Default_Handler

    .weak TIM8_BRK_IRQHandler
    .thumb_set TIM8_BRK_IRQHandler,Default_Handler

    .weak TIM8_UP_IRQHandler
    .thumb_set TIM8_UP_IRQHandler,Default_Handler

    .weak TIM8_TRG_COM_IRQHandler
    .thumb_set TIM8_TRG_COM_IRQHandler,Default_Handler

    .weak TIM8_CC_IRQHandler
    .thumb_set TIM8_CC_IRQHandler,Default_Handler

    .weak ADC2_IRQHandler
    .thumb_set ADC2_IRQHandler,Default_Handler

    .weak LPTIM2_IRQHandler
    .thumb_set LPTIM2_IRQHandler,Default_Handler

    .weak TIM15_IRQHandler
    .thumb_set TIM15_IRQHandler,Default_Handler

    .weak TIM16_IRQHandler
    .thumb_set TIM16_IRQHandler,Default_Handler

    .weak TIM17_IRQHandler
    .thumb_set TIM17_IRQHandler,Default_Handler

    .weak USB_DRD_FS_IRQHandler
    .thumb_set USB_DRD_FS_IRQHandler,Default_Handler

    .weak CRS_IRQHandler
    .thumb_set CRS_IRQHandler,Default_Handler

    .weak UCPD1_IRQHandler
    .thumb_set UCPD1_IRQHandler,Default_Handler

    .weak FMC_IRQHandler
    .thumb_set FMC_IRQHandler,Default_Handler

    .weak OCTOSPI1_IRQHandler
    .thumb_set OCTOSPI1_IRQHandler,Default_Handler

    .weak SDMMC1_IRQHandler
    .thumb_set SDMMC1_IRQHandler,Default_Handler

    .weak I2C3_EV_IRQHandler
    .thumb_set I2C3_EV_IRQHandler,Default_Handler

    .weak I2C3_ER_IRQHandler
    .thumb_set I2C3_ER_IRQHandler,Default_Handler

    .weak SPI4_IRQHandler
    .thumb_set SPI4_IRQHandler,Default_Handler

    .weak SPI5_IRQHandler
    .thumb_set SPI5_IRQHandler,Default_Handler

    .weak SPI6_IRQHandler
    .thumb_set SPI6_IRQHandler,Default_Handler

    .weak USART6_IRQHandler
    .thumb_set USART6_IRQHandler,Default_Handler

    .weak USART10_IRQHandler
    .thumb_set USART10_IRQHandler,Default_Handler

    .weak USART11_IRQHandler
    .thumb_set USART11_IRQHandler,Default_Handler

    .weak SAI1_IRQHandler
    .thumb_set SAI1_IRQHandler,Default_Handler

    .weak SAI2_IRQHandler
    .thumb_set SAI2_IRQHandler,Default_Handler

    .weak GPDMA2_Channel0_IRQHandler
    .thumb_set GPDMA2_Channel0_IRQHandler,Default_Handler

    .weak GPDMA2_Channel1_IRQHandler
    .thumb_set GPDMA2_Channel1_IRQHandler,Default_Handler

    .weak GPDMA2_Channel2_IRQHandler
    .thumb_set GPDMA2_Channel2_IRQHandler,Default_Handler

    .weak GPDMA2_Channel3_IRQHandler
    .thumb_set GPDMA2_Channel3_IRQHandler,Default_Handler

    .weak GPDMA2_Channel4_IRQHandler
    .thumb_set GPDMA2_Channel4_IRQHandler,Default_Handler

    .weak GPDMA2_Channel5_IRQHandler
    .thumb_set GPDMA2_Channel5_IRQHandler,Default_Handler

    .weak GPDMA2_Channel6_IRQHandler
    .thumb_set GPDMA2_Channel6_IRQHandler,Default_Handler

    .weak GPDMA2_Channel7_IRQHandler
    .thumb_set GPDMA2_Channel7_IRQHandler,Default_Handler

    .weak FPU_IRQHandler
    .thumb_set FPU_IRQHandler,Default_Handler

    .weak ICACHE_IRQHandler
    .thumb_set ICACHE_IRQHandler,Default_Handler

    .weak DCACHE1_IRQHandler
    .thumb_set DCACHE1_IRQHandler,Default_Handler

    .weak DTS_IRQHandler
    .thumb_set DTS_IRQHandler,Default_Handler

    .weak RNG_IRQHandler
    .thumb_set RNG_IRQHandler,Default_Handler

    .weak HASH_IRQHandler
    .thumb_set HASH_IRQHandler,Default_Handler

    .weak CEC_IRQHandler
    .thumb_set CEC_IRQHandler,Default_Handler

    .weak TIM12_IRQHandler
    .thumb_set TIM12_IRQHandler,Default_Handler

    .weak TIM13_IRQHandler
    .thumb_set TIM13_IRQHandler,Default_Handler

    .weak TIM14_IRQHandler
    .thumb_set TIM14_IRQHandler,Default_Handler

    .weak I3C1_EV_IRQHandler
    .thumb_set I3C1_EV_IRQHandler,Default_Handler

    .weak I3C1_ER_IRQHandler
    .thumb_set I3C1_ER_IRQHandler,Default_Handler

    .weak I2C4_EV_IRQHandler
    .thumb_set I2C4_EV_IRQHandler,Default_Handler

    .weak I2C4_ER_IRQHandler
    .thumb_set I2C4_ER_IRQHandler,Default_Handler

    .weak LPTIM3_IRQHandler
    .thumb_set LPTIM3_IRQHandler,Default_Handler

    .weak LPTIM4_IRQHandler
    .thumb_set LPTIM4_IRQHandler,Default_Handler

    .weak LPTIM5_IRQHandler
    .thumb_set LPTIM5_IRQHandler,Default_Handler

    .weak LPTIM6_IRQHandler
    .thumb_set LPTIM6_IRQHandler,Default_Handler

/* Provide weak symbol for C++ global constructor init */
    .weak __libc_init_array
    .thumb_set __libc_init_array,Default_Handler
