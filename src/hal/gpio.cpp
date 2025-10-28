#include "crusty/hal/gpio.h"
#include "crusty/hal/mmio.h"

namespace crusty {
namespace hal {

// GPIO Register offsets
constexpr uint32_t GPIO_MODER_OFFSET = 0x00;   // Mode register
constexpr uint32_t GPIO_OTYPER_OFFSET = 0x04;  // Output type register
constexpr uint32_t GPIO_OSPEEDR_OFFSET = 0x08; // Output speed register
constexpr uint32_t GPIO_PUPDR_OFFSET = 0x0C;   // Pull-up/pull-down register
constexpr uint32_t GPIO_IDR_OFFSET = 0x10;     // Input data register
constexpr uint32_t GPIO_ODR_OFFSET = 0x14;     // Output data register
constexpr uint32_t GPIO_BSRR_OFFSET = 0x18;    // Bit set/reset register

void GPIO::initPin(uintptr_t port, uint8_t pin, PinMode mode) {
    if (pin > 15) return;  // Invalid pin number

    // Configure pin mode (2 bits per pin)
    uintptr_t moderAddr = port + GPIO_MODER_OFFSET;
    uint32_t moderValue = MMIO::read32(moderAddr);
    moderValue &= ~(0x3 << (pin * 2));  // Clear mode bits
    moderValue |= (static_cast<uint32_t>(mode) << (pin * 2));  // Set new mode
    MMIO::write32(moderAddr, moderValue);
}

void GPIO::setPin(uintptr_t port, uint8_t pin) {
    if (pin > 15) return;

    // Use BSRR register - write 1 to lower 16 bits sets pin
    MMIO::write32(port + GPIO_BSRR_OFFSET, 1U << pin);
}

void GPIO::clearPin(uintptr_t port, uint8_t pin) {
    if (pin > 15) return;

    // Use BSRR register - write 1 to upper 16 bits clears pin
    MMIO::write32(port + GPIO_BSRR_OFFSET, 1U << (pin + 16));
}

void GPIO::togglePin(uintptr_t port, uint8_t pin) {
    if (pin > 15) return;

    uint32_t odrValue = MMIO::read32(port + GPIO_ODR_OFFSET);
    odrValue ^= (1U << pin);  // XOR to toggle
    MMIO::write32(port + GPIO_ODR_OFFSET, odrValue);
}

PinState GPIO::readPin(uintptr_t port, uint8_t pin) {
    if (pin > 15) return PinState::LOW;

    uint32_t idrValue = MMIO::read32(port + GPIO_IDR_OFFSET);
    return ((idrValue & (1U << pin)) != 0) ? PinState::HIGH : PinState::LOW;
}

void GPIO::writePin(uintptr_t port, uint8_t pin, PinState state) {
    if (state == PinState::HIGH) {
        setPin(port, pin);
    } else {
        clearPin(port, pin);
    }
}

} // namespace hal
} // namespace crusty
