#ifndef CRUSTY_HAL_NVIC_H
#define CRUSTY_HAL_NVIC_H

#include "crusty/platform/stm32h573.h"
#include "crusty/platform/types.h"
#include "crusty/hal/mmio.h"

namespace crusty {
namespace hal {

/**
 * @brief NVIC (Nested Vectored Interrupt Controller) driver
 *
 * Provides interface to enable/disable interrupts and set priorities
 * for the ARM Cortex-M33 NVIC.
 */
class NVIC {
public:
    /**
     * @brief Enable a specific interrupt
     * @param irq Interrupt number
     */
    static void enableIRQ(uint8_t irq);

    /**
     * @brief Disable a specific interrupt
     * @param irq Interrupt number
     */
    static void disableIRQ(uint8_t irq);

    /**
     * @brief Set pending flag for an interrupt
     * @param irq Interrupt number
     */
    static void setPendingIRQ(uint8_t irq);

    /**
     * @brief Clear pending flag for an interrupt
     * @param irq Interrupt number
     */
    static void clearPendingIRQ(uint8_t irq);

    /**
     * @brief Check if interrupt is pending
     * @param irq Interrupt number
     * @return true if pending, false otherwise
     */
    static bool isPendingIRQ(uint8_t irq);

    /**
     * @brief Set priority for an interrupt
     * @param irq Interrupt number
     * @param priority Priority level (0-15, 0 = highest)
     */
    static void setPriority(uint8_t irq, InterruptPriority priority);

    /**
     * @brief Get priority for an interrupt
     * @param irq Interrupt number
     * @return Priority level
     */
    static InterruptPriority getPriority(uint8_t irq);

    /**
     * @brief Disable all interrupts (global disable)
     */
    static void disableGlobal();

    /**
     * @brief Enable all interrupts (global enable)
     */
    static void enableGlobal();
};

} // namespace hal
} // namespace crusty

#endif // CRUSTY_HAL_NVIC_H
