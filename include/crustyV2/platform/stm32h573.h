#ifndef crustyV2_PLATFORM_STM32H573_H
#define crustyV2_PLATFORM_STM32H573_H

#include <cstdint>

namespace crustyV2 {
namespace platform {

// STM32H573I-DK specific register definitions
// Defines memory-mapped register addresses for the STM32H573 microcontroller

// ============================================================================
// Core Peripherals (ARM Cortex-M33)
// ============================================================================

// NVIC (Nested Vectored Interrupt Controller) base address
constexpr uintptr_t NVIC_BASE = 0xE000E100;

// NVIC Interrupt Set-Enable Registers
constexpr uintptr_t NVIC_ISER_BASE = NVIC_BASE + 0x000;

// NVIC Interrupt Clear-Enable Registers
constexpr uintptr_t NVIC_ICER_BASE = NVIC_BASE + 0x080;

// NVIC Interrupt Set-Pending Registers
constexpr uintptr_t NVIC_ISPR_BASE = NVIC_BASE + 0x100;

// NVIC Interrupt Clear-Pending Registers
constexpr uintptr_t NVIC_ICPR_BASE = NVIC_BASE + 0x180;

// NVIC Interrupt Priority Registers
constexpr uintptr_t NVIC_IPR_BASE = NVIC_BASE + 0x300;

// SysTick Timer base address
constexpr uintptr_t SYSTICK_BASE = 0xE000E010;

// SysTick Control and Status Register
constexpr uintptr_t SYSTICK_CSR = SYSTICK_BASE + 0x00;

// SysTick Reload Value Register
constexpr uintptr_t SYSTICK_RVR = SYSTICK_BASE + 0x04;

// SysTick Current Value Register
constexpr uintptr_t SYSTICK_CVR = SYSTICK_BASE + 0x08;

// SysTick Calibration Value Register
constexpr uintptr_t SYSTICK_CALIB = SYSTICK_BASE + 0x0C;

// ============================================================================
// STM32H573 Peripherals
// ============================================================================

// RCC (Reset and Clock Control) base address
constexpr uintptr_t RCC_BASE = 0x44020C00;

// GPIO Port A base address
constexpr uintptr_t GPIOA_BASE = 0x42020000;

// GPIO Port B base address
constexpr uintptr_t GPIOB_BASE = 0x42020400;

// GPIO Port C base address
constexpr uintptr_t GPIOC_BASE = 0x42020800;

// UART4 base address (for debug logging)
constexpr uintptr_t UART4_BASE = 0x40011000;

// ============================================================================
// Interrupt Numbers for STM32H573I
// ============================================================================

// UART4 global interrupt number
constexpr uint8_t UART4_IRQ = 52;

// External interrupt line 0
constexpr uint8_t EXTI0_IRQ = 6;

// External interrupt line 1
constexpr uint8_t EXTI1_IRQ = 7;

// External interrupt line 2
constexpr uint8_t EXTI2_IRQ = 8;

// Reserved for simulated CFPGA interrupt (will use EXTI2)
constexpr uint8_t CFPGA_IRQ = EXTI2_IRQ;

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * @brief Calculate NVIC register offset for a given IRQ number
 * @param irq Interrupt number
 * @return Register offset in bytes
 */
constexpr uint32_t nvicIserOffset(uint8_t irq) {
    return (irq / 32) * 4;
}

/**
 * @brief Calculate bit position within NVIC register
 * @param irq Interrupt number
 * @return Bit position (0-31)
 */
constexpr uint8_t nvicBitPosition(uint8_t irq) {
    return irq % 32;
}

} // namespace platform
} // namespace crustyV2

#endif // crustyV2_PLATFORM_STM32H573_H
