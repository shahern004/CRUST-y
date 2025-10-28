#ifndef CRUSTY_HAL_MMIO_H
#define CRUSTY_HAL_MMIO_H

#include <cstdint>

namespace crusty {
namespace hal {

/**
 * @brief Memory-Mapped I/O abstraction for safe register access
 *
 * Provides volatile read/write operations for hardware registers.
 * This is the primary interface for accessing memory-mapped peripherals.
 */
class MMIO {
public:
    /**
     * @brief Read 32-bit value from memory-mapped register
     * @param address Register address
     * @return Value read from register
     */
    static inline uint32_t read32(uintptr_t address) {
        volatile uint32_t* reg = reinterpret_cast<volatile uint32_t*>(address);
        return *reg;
    }

    /**
     * @brief Write 32-bit value to memory-mapped register
     * @param address Register address
     * @param value Value to write
     */
    static inline void write32(uintptr_t address, uint32_t value) {
        volatile uint32_t* reg = reinterpret_cast<volatile uint32_t*>(address);
        *reg = value;
    }

    /**
     * @brief Read 16-bit value from memory-mapped register
     * @param address Register address
     * @return Value read from register
     */
    static inline uint16_t read16(uintptr_t address) {
        volatile uint16_t* reg = reinterpret_cast<volatile uint16_t*>(address);
        return *reg;
    }

    /**
     * @brief Write 16-bit value to memory-mapped register
     * @param address Register address
     * @param value Value to write
     */
    static inline void write16(uintptr_t address, uint16_t value) {
        volatile uint16_t* reg = reinterpret_cast<volatile uint16_t*>(address);
        *reg = value;
    }

    /**
     * @brief Read 8-bit value from memory-mapped register
     * @param address Register address
     * @return Value read from register
     */
    static inline uint8_t read8(uintptr_t address) {
        volatile uint8_t* reg = reinterpret_cast<volatile uint8_t*>(address);
        return *reg;
    }

    /**
     * @brief Write 8-bit value to memory-mapped register
     * @param address Register address
     * @param value Value to write
     */
    static inline void write8(uintptr_t address, uint8_t value) {
        volatile uint8_t* reg = reinterpret_cast<volatile uint8_t*>(address);
        *reg = value;
    }

    /**
     * @brief Set specific bits in a 32-bit register
     * @param address Register address
     * @param mask Bitmask of bits to set
     */
    static inline void setBits32(uintptr_t address, uint32_t mask) {
        uint32_t value = read32(address);
        write32(address, value | mask);
    }

    /**
     * @brief Clear specific bits in a 32-bit register
     * @param address Register address
     * @param mask Bitmask of bits to clear
     */
    static inline void clearBits32(uintptr_t address, uint32_t mask) {
        uint32_t value = read32(address);
        write32(address, value & ~mask);
    }

    /**
     * @brief Modify specific bits in a 32-bit register
     * @param address Register address
     * @param clearMask Bitmask of bits to clear first
     * @param setMask Bitmask of bits to set
     */
    static inline void modifyBits32(uintptr_t address, uint32_t clearMask, uint32_t setMask) {
        uint32_t value = read32(address);
        value = (value & ~clearMask) | setMask;
        write32(address, value);
    }
};

} // namespace hal
} // namespace crusty

#endif // CRUSTY_HAL_MMIO_H
