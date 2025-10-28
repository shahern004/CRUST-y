#ifndef CRUSTY_PLATFORM_MEMORY_MAP_H
#define CRUSTY_PLATFORM_MEMORY_MAP_H

#include <cstdint>
#include <cstddef>

namespace crusty {
namespace platform {

// Memory Map for STM32H573I-DK
// Defines memory regions, sizes, and boundaries for baremetal constraints

// Flash memory size: 2MB (matching STM32U5A5 constraint)
constexpr size_t FLASH_SIZE = 2 * 1024 * 1024;

// RAM size for STM32H573I: 640KB total
// (128KB SRAM1 + 64KB SRAM2 + 320KB SRAM3 + 128KB SRAM4)
constexpr size_t RAM_SIZE = 640 * 1024;

// Flash memory base address
constexpr uintptr_t FLASH_BASE = 0x08000000;

// RAM base address (SRAM1)
constexpr uintptr_t RAM_BASE = 0x20000000;

// Peripheral region (STM32 peripherals are memory-mapped)
constexpr uintptr_t PERIPHERAL_BASE = 0x40000000;
constexpr size_t PERIPHERAL_SIZE = 0x20000000; // 512MB peripheral address space

// Stack and heap configuration (defined in linker script)
constexpr size_t STACK_SIZE = 32 * 1024;  // 32KB stack
constexpr size_t HEAP_SIZE = 64 * 1024;   // 64KB heap

/**
 * @brief Memory region definition for bounds checking
 */
struct MemoryRegion {
    uintptr_t base;
    size_t size;

    /**
     * @brief Check if an address falls within this region
     */
    constexpr bool contains(uintptr_t address) const {
        return address >= base && address < (base + size);
    }

    /**
     * @brief Check if a range falls entirely within this region
     */
    constexpr bool containsRange(uintptr_t address, size_t len) const {
        // Check for overflow
        if (address + len < address) return false;
        if (base + size < base) return false;

        return address >= base && (address + len) <= (base + size);
    }

    /**
     * @brief Get the end address (exclusive)
     */
    constexpr uintptr_t end() const {
        return base + size;
    }
};

// Pre-defined memory regions
constexpr MemoryRegion FLASH_REGION = {FLASH_BASE, FLASH_SIZE};
constexpr MemoryRegion RAM_REGION = {RAM_BASE, RAM_SIZE};
constexpr MemoryRegion PERIPHERAL_REGION = {PERIPHERAL_BASE, PERIPHERAL_SIZE};

} // namespace platform
} // namespace crusty

#endif // CRUSTY_PLATFORM_MEMORY_MAP_H
