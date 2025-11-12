#ifndef crustyV2_HAL_UART_H
#define crustyV2_HAL_UART_H

#include "crustyV2/platform/types.h"
#include <cstdint>

namespace crustyV2 {
namespace hal {

/**
 * @brief UART (Universal Asynchronous Receiver/Transmitter) driver
 *
 * Provides interface for UART communication (primarily for debug logging).
 * Function descriptions for baremetal implementation.
 */
class UART {
public:
    /**
     * @brief Initialize UART peripheral with specified baud rate
     * @param uartBase UART peripheral base address
     * @param baudRate Desired baud rate (e.g., 115200)
     * @return Status OK if successful
     */
    static Status init(uintptr_t uartBase, uint32_t baudRate);

    /**
     * @brief Transmit a single byte
     * @param uartBase UART peripheral base address
     * @param data Byte to transmit
     */
    static void transmitByte(uintptr_t uartBase, uint8_t data);

    /**
     * @brief Transmit a buffer of bytes
     * @param uartBase UART peripheral base address
     * @param data Pointer to data buffer
     * @param length Number of bytes to transmit
     */
    static void transmit(uintptr_t uartBase, const uint8_t* data, size_t length);

    /**
     * @brief Transmit a null-terminated string
     * @param uartBase UART peripheral base address
     * @param str Null-terminated string to transmit
     */
    static void transmitString(uintptr_t uartBase, const char* str);

    /**
     * @brief Receive a single byte (blocking)
     * @param uartBase UART peripheral base address
     * @return Received byte
     */
    static uint8_t receiveByte(uintptr_t uartBase);

    /**
     * @brief Check if data is available to receive
     * @param uartBase UART peripheral base address
     * @return true if data available, false otherwise
     */
    static bool isDataAvailable(uintptr_t uartBase);

    /**
     * @brief Check if transmit is complete
     * @param uartBase UART peripheral base address
     * @return true if transmit complete, false otherwise
     */
    static bool isTransmitComplete(uintptr_t uartBase);
};

} // namespace hal
} // namespace crustyV2

#endif // crustyV2_HAL_UART_H
