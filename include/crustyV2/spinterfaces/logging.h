#ifndef crustyV2_SPINTERFACES_LOGGING_H
#define crustyV2_SPINTERFACES_LOGGING_H

#include "crustyV2/platform/types.h"
#include <cstdint>

namespace crustyV2 {
namespace spinterfaces {

/**
 * @brief Logging interface (Layer 4 - SpInterfaces)
 *
 * Provides API for components to log messages.
 * This interface will be callable from both C++ and Rust via CXX bridge.
 */
class Logging {
public:
    /**
     * @brief Log severity levels
     */
    enum class Level : uint8_t {
        DEBUG = 0,
        INFO = 1,
        WARNING = 2,
        ERROR = 3,
        CRITICAL = 4
    };

    /**
     * @brief Initialize logging subsystem
     * @param uartBase UART peripheral to use for logging
     * @param baudRate UART baud rate
     * @return Status OK if successful
     */
    static Status init(uintptr_t uartBase, uint32_t baudRate);

    /**
     * @brief Log a message with specified severity
     * @param level Severity level
     * @param message Message string
     */
    static void log(Level level, const char* message);

    /**
     * @brief Log an error message (callable from Rust via CXX)
     * @param message Error message
     */
    static void logError(const char* message);

    /**
     * @brief Log an info message (callable from Rust via CXX)
     * @param message Info message
     */
    static void logInfo(const char* message);

    /**
     * @brief Log a debug message
     * @param message Debug message
     */
    static void logDebug(const char* message);

    /**
     * @brief Log a warning message
     * @param message Warning message
     */
    static void logWarning(const char* message);

private:
    static uintptr_t s_uartBase;
    static bool s_initialized;
};

} // namespace spinterfaces
} // namespace crustyV2

#endif // crustyV2_SPINTERFACES_LOGGING_H
