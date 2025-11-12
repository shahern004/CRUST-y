#include "crustyV2/hal/nvic.h"

namespace crustyV2 {
namespace hal {

void NVIC::enableIRQ(uint8_t irq) {
    uint32_t offset = platform::nvicIserOffset(irq);
    uint8_t bitPos = platform::nvicBitPosition(irq);
    MMIO::write32(platform::NVIC_ISER_BASE + offset, 1U << bitPos);
}

void NVIC::disableIRQ(uint8_t irq) {
    uint32_t offset = platform::nvicIserOffset(irq);
    uint8_t bitPos = platform::nvicBitPosition(irq);
    MMIO::write32(platform::NVIC_ICER_BASE + offset, 1U << bitPos);
}

void NVIC::setPendingIRQ(uint8_t irq) {
    uint32_t offset = platform::nvicIserOffset(irq);
    uint8_t bitPos = platform::nvicBitPosition(irq);
    MMIO::write32(platform::NVIC_ISPR_BASE + offset, 1U << bitPos);
}

void NVIC::clearPendingIRQ(uint8_t irq) {
    uint32_t offset = platform::nvicIserOffset(irq);
    uint8_t bitPos = platform::nvicBitPosition(irq);
    MMIO::write32(platform::NVIC_ICPR_BASE + offset, 1U << bitPos);
}

bool NVIC::isPendingIRQ(uint8_t irq) {
    uint32_t offset = platform::nvicIserOffset(irq);
    uint8_t bitPos = platform::nvicBitPosition(irq);
    uint32_t value = MMIO::read32(platform::NVIC_ISPR_BASE + offset);
    return (value & (1U << bitPos)) != 0;
}

void NVIC::setPriority(uint8_t irq, InterruptPriority priority) {
    // Each IPR register holds 4 priority bytes
    uint32_t offset = (irq / 4) * 4;
    uint8_t bytePos = irq % 4;

    uintptr_t regAddr = platform::NVIC_IPR_BASE + offset;
    uint32_t regValue = MMIO::read32(regAddr);

    // Clear the priority byte and set new value
    // Priority is in upper 4 bits of each byte (lower 4 bits not implemented)
    uint8_t prioValue = static_cast<uint8_t>(priority) << 4;
    uint32_t mask = 0xFF << (bytePos * 8);
    regValue = (regValue & ~mask) | (static_cast<uint32_t>(prioValue) << (bytePos * 8));

    MMIO::write32(regAddr, regValue);
}

InterruptPriority NVIC::getPriority(uint8_t irq) {
    // Each IPR register holds 4 priority bytes
    uint32_t offset = (irq / 4) * 4;
    uint8_t bytePos = irq % 4;

    uint32_t regValue = MMIO::read32(platform::NVIC_IPR_BASE + offset);
    uint8_t prioValue = (regValue >> (bytePos * 8)) & 0xFF;

    // Priority is in upper 4 bits, shift down
    return static_cast<InterruptPriority>(prioValue >> 4);
}

void NVIC::disableGlobal() {
    __asm volatile ("cpsid i" : : : "memory");
}

void NVIC::enableGlobal() {
    __asm volatile ("cpsie i" : : : "memory");
}

} // namespace hal
} // namespace crustyV2
