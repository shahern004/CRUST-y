#include "crusty/hal/uart.h"
#include "crusty/hal/mmio.h"

namespace crusty {
namespace hal {

// UART Register offsets (STM32H573)
constexpr uint32_t UART_CR1_OFFSET = 0x00;   // Control register 1
constexpr uint32_t UART_CR2_OFFSET = 0x04;   // Control register 2
constexpr uint32_t UART_CR3_OFFSET = 0x08;   // Control register 3
constexpr uint32_t UART_BRR_OFFSET = 0x0C;   // Baud rate register
constexpr uint32_t UART_ISR_OFFSET = 0x1C;   // Interrupt and status register
constexpr uint32_t UART_RDR_OFFSET = 0x24;   // Receive data register
constexpr uint32_t UART_TDR_OFFSET = 0x28;   // Transmit data register

// UART CR1 bits
constexpr uint32_t UART_CR1_UE = (1 << 0);   // UART enable
constexpr uint32_t UART_CR1_TE = (1 << 3);   // Transmitter enable
constexpr uint32_t UART_CR1_RE = (1 << 2);   // Receiver enable

// UART ISR bits
constexpr uint32_t UART_ISR_TXE = (1 << 7);  // Transmit data register empty
constexpr uint32_t UART_ISR_RXNE = (1 << 5); // Receive data register not empty
constexpr uint32_t UART_ISR_TC = (1 << 6);   // Transmission complete

Status UART::init(uintptr_t uartBase, uint32_t baudRate) {
    // Simplified initialization
    // In real implementation: calculate BRR value based on clock frequency

    // For now, use a fixed BRR value for 115200 baud at 64MHz PCLK
    // BRR = PCLK / baudRate = 64000000 / 115200 ≈ 555
    uint32_t brrValue = 64000000 / baudRate;

    // Disable UART before configuration
    MMIO::clearBits32(uartBase + UART_CR1_OFFSET, UART_CR1_UE);

    // Set baud rate
    MMIO::write32(uartBase + UART_BRR_OFFSET, brrValue);

    // Enable transmitter and receiver
    MMIO::write32(uartBase + UART_CR1_OFFSET, UART_CR1_UE | UART_CR1_TE | UART_CR1_RE);

    return Status::OK;
}

void UART::transmitByte(uintptr_t uartBase, uint8_t data) {
    // Wait for TX register to be empty
    while ((MMIO::read32(uartBase + UART_ISR_OFFSET) & UART_ISR_TXE) == 0) {
        // Busy wait
    }

    // Write data to transmit register
    MMIO::write32(uartBase + UART_TDR_OFFSET, data);
}

void UART::transmit(uintptr_t uartBase, const uint8_t* data, size_t length) {
    for (size_t i = 0; i < length; i++) {
        transmitByte(uartBase, data[i]);
    }
}

void UART::transmitString(uintptr_t uartBase, const char* str) {
    while (*str != '\0') {
        transmitByte(uartBase, static_cast<uint8_t>(*str));
        str++;
    }
}

uint8_t UART::receiveByte(uintptr_t uartBase) {
    // Wait for data to be available
    while ((MMIO::read32(uartBase + UART_ISR_OFFSET) & UART_ISR_RXNE) == 0) {
        // Busy wait
    }

    return static_cast<uint8_t>(MMIO::read32(uartBase + UART_RDR_OFFSET));
}

bool UART::isDataAvailable(uintptr_t uartBase) {
    return (MMIO::read32(uartBase + UART_ISR_OFFSET) & UART_ISR_RXNE) != 0;
}

bool UART::isTransmitComplete(uintptr_t uartBase) {
    return (MMIO::read32(uartBase + UART_ISR_OFFSET) & UART_ISR_TC) != 0;
}

} // namespace hal
} // namespace crusty
