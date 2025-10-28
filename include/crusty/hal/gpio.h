#ifndef CRUSTY_HAL_GPIO_H
#define CRUSTY_HAL_GPIO_H

#include "crusty/platform/types.h"
#include <cstdint>

namespace crusty {
namespace hal {

/**
 * @brief GPIO (General Purpose I/O) driver
 *
 * Provides interface for configuring and controlling GPIO pins.
 * Function descriptions only - implementation for baremetal hardware.
 */
class GPIO {
public:
    /**
     * @brief Initialize a GPIO pin with specified mode
     * @param port GPIO port base address
     * @param pin Pin number (0-15)
     * @param mode Pin mode (input, output, alternate, analog)
     */
    static void initPin(uintptr_t port, uint8_t pin, PinMode mode);

    /**
     * @brief Set GPIO pin to HIGH
     * @param port GPIO port base address
     * @param pin Pin number (0-15)
     */
    static void setPin(uintptr_t port, uint8_t pin);

    /**
     * @brief Set GPIO pin to LOW
     * @param port GPIO port base address
     * @param pin Pin number (0-15)
     */
    static void clearPin(uintptr_t port, uint8_t pin);

    /**
     * @brief Toggle GPIO pin state
     * @param port GPIO port base address
     * @param pin Pin number (0-15)
     */
    static void togglePin(uintptr_t port, uint8_t pin);

    /**
     * @brief Read GPIO pin state
     * @param port GPIO port base address
     * @param pin Pin number (0-15)
     * @return Current pin state (HIGH or LOW)
     */
    static PinState readPin(uintptr_t port, uint8_t pin);

    /**
     * @brief Write GPIO pin state
     * @param port GPIO port base address
     * @param pin Pin number (0-15)
     * @param state Desired state (HIGH or LOW)
     */
    static void writePin(uintptr_t port, uint8_t pin, PinState state);
};

} // namespace hal
} // namespace crusty

#endif // CRUSTY_HAL_GPIO_H
