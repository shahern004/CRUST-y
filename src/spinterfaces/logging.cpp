#include "crustyV2/spinterfaces/logging.h"
#include "crustyV2/hal/uart.h"

namespace crustyV2 {
namespace spinterfaces {

// Static member initialization
uintptr_t Logging::s_uartBase = 0;
bool Logging::s_initialized = false;

Status Logging::init(uintptr_t uartBase, uint32_t baudRate) {
    Status status = hal::UART::init(uartBase, baudRate);
    if (status == Status::OK) {
        s_uartBase = uartBase;
        s_initialized = true;
    }
    return status;
}

void Logging::log(Level level, const char* message) {
    if (!s_initialized || message == nullptr) {
        return;
    }

    // Prepend level indicator
    const char* prefix = "";
    switch (level) {
        case Level::DEBUG:    prefix = "[DEBUG] ";   break;
        case Level::INFO:     prefix = "[INFO] ";    break;
        case Level::WARNING:  prefix = "[WARN] ";    break;
        case Level::ERROR:    prefix = "[ERROR] ";   break;
        case Level::CRITICAL: prefix = "[CRIT] ";    break;
    }

    hal::UART::transmitString(s_uartBase, prefix);
    hal::UART::transmitString(s_uartBase, message);
    hal::UART::transmitString(s_uartBase, "\r\n");
}

void Logging::logError(const char* message) {
    log(Level::ERROR, message);
}

void Logging::logInfo(const char* message) {
    log(Level::INFO, message);
}

void Logging::logDebug(const char* message) {
    log(Level::DEBUG, message);
}

void Logging::logWarning(const char* message) {
    log(Level::WARNING, message);
}

} // namespace spinterfaces
} // namespace crustyV2
