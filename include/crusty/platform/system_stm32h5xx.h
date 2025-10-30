/**
 * @file system_stm32h5xx.h
 * @brief System initialization header for STM32H573
 *
 * Declarations for system initialization functions called by startup code.
 */

#ifndef CRUSTY_PLATFORM_SYSTEM_STM32H5XX_H
#define CRUSTY_PLATFORM_SYSTEM_STM32H5XX_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/**
 * @brief System Clock Frequency variable
 *
 * Updated by SystemInit() and SystemCoreClockUpdate()
 * Default: 64 MHz (HSI), Target: 250 MHz (PLL)
 */
extern uint32_t SystemCoreClock;

/**
 * @brief Initialize the system clock and peripherals
 *
 * Called by startup code after .data/.bss init but before main()
 * Configures:
 *   - FPU (Floating Point Unit)
 *   - Flash wait states
 *   - Clock system (PLL configuration)
 *   - Voltage scaling
 *   - Caches
 */
void SystemInit(void);

/**
 * @brief Update SystemCoreClock variable
 *
 * Recalculates SystemCoreClock from RCC registers
 * Call after any clock configuration changes
 */
void SystemCoreClockUpdate(void);

#ifdef __cplusplus
}
#endif

#endif /* CRUSTY_PLATFORM_SYSTEM_STM32H5XX_H */
