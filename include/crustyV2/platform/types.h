#ifndef crustyV2_PLATFORM_TYPES_H
#define crustyV2_PLATFORM_TYPES_H

#include <cstdint>

namespace crustyV2 {

// ============================================================================
// Common Type Definitions
// ============================================================================

// Status and error codes
enum class Status : uint16_t {
    OK = 0,
    ERROR_INVALID_PARAM = 1,
    ERROR_OUT_OF_BOUNDS = 2,
    ERROR_TIMEOUT = 3,
    ERROR_BUSY = 4,
    ERROR_NOT_INITIALIZED = 5,
    ERROR_CHECKSUM = 6,
    ERROR_OVERFLOW = 7,
    ERROR_UNDERFLOW = 8,
    ERROR_UNKNOWN = 0xFFFF
};

// Interrupt priority levels (0 = highest, 15 = lowest for Cortex-M33)
enum class InterruptPriority : uint8_t {
    HIGHEST = 0,
    HIGH = 4,
    MEDIUM = 8,
    LOW = 12,
    LOWEST = 15
};

// GPIO pin states
enum class PinState : uint8_t {
    LOW = 0,
    HIGH = 1
};

// GPIO pin modes
enum class PinMode : uint8_t {
    INPUT = 0,
    OUTPUT = 1,
    ALTERNATE = 2,
    ANALOG = 3
};

} // namespace crustyV2

#endif // crustyV2_PLATFORM_TYPES_H
