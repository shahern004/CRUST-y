/**
 * @file main.cpp
 * @brief Main entry point for CRUST-y baremetal firmware (STM32H573)
 */

#include "crustyV2/platform/memory_map.h"
#include "crustyV2/platform/stm32h573.h"
#include "crustyV2/platform/types.h"
#include "crustyV2/hal/nvic.h"
#include "crustyV2/hal/gpio.h"
#include "crustyV2/hal/uart.h"
#include "crustyV2/spinterfaces/logging.h"
#include "crustyV2/components/control.h"

// CXX-generated Rust FFI bridge
#include "lib.rs.h"

using namespace crustyV2;

/**
 * @brief Initialize platform and hardware
 */
static Status initPlatform() {
    // Initialize UART for logging (115200 baud)
    Status status = spinterfaces::Logging::init(platform::UART4_BASE, 115200);
    if (status != Status::OK) {
        return status;
    }

    spinterfaces::Logging::logInfo("=== CRUST-y Firmware Starting ===");
    spinterfaces::Logging::logInfo("Platform: STM32H573I-DK");

    // Initialize LED GPIO (GPIOB pin 7)
    hal::GPIO::initPin(platform::GPIOB_BASE, 7, PinMode::OUTPUT);
    hal::GPIO::clearPin(platform::GPIOB_BASE, 7);

    spinterfaces::Logging::logInfo("Platform initialization complete");
    return Status::OK;
}

/**
 * @brief Initialize devices
 */
static Status initDevices() {
    spinterfaces::Logging::logInfo("Initializing devices...");
    // CFPGA initialization added in Step 2
    spinterfaces::Logging::logInfo("Device initialization complete");
    return Status::OK;
}

/**
 * @brief Initialize components
 */
static Status initComponents() {
    spinterfaces::Logging::logInfo("Initializing components...");

    Status status = components::Control::init();
    if (status != Status::OK) {
        spinterfaces::Logging::logError("Control component init failed");
        return status;
    }

    return Status::OK;
}

/**
 * @brief Main entry point
 */
int main(void) {
    // Initialize Rust heap (required for CXX bridge)
    init_heap();

    // Platform initialization
    Status status = initPlatform();
    if (status != Status::OK) {
        while (1) {}
    }

    // Device initialization
    status = initDevices();
    if (status != Status::OK) {
        spinterfaces::Logging::logError("Device initialization failed");
        while (1) {}
    }

    // Component initialization
    status = initComponents();
    if (status != Status::OK) {
        spinterfaces::Logging::logError("Component initialization failed");
        while (1) {}
    }

    spinterfaces::Logging::logInfo("All layers initialized successfully");
    spinterfaces::Logging::logInfo("Starting main application loop");

    // Blink LED to indicate running
    hal::GPIO::setPin(platform::GPIOB_BASE, 7);

    // Phase 0: CXX Bridge Integration Test
    spinterfaces::Logging::logInfo("==============================================");
    spinterfaces::Logging::logInfo("Testing C++/Rust integration via CXX bridge");
    spinterfaces::Logging::logInfo("==============================================");

    // Call Rust function
    uint32_t crustyV2_number = calculate_crusty_number();

    // Output result via UART
    char buffer[64];
    snprintf(buffer, sizeof(buffer), "The crusty number is: %u", crustyV2_number);
    spinterfaces::Logging::logInfo(buffer);

    spinterfaces::Logging::logInfo("==============================================");
    spinterfaces::Logging::logInfo("Phase 0 complete - CXX bridge functional");
    spinterfaces::Logging::logInfo("==============================================");

    // Main application loop
    while (1) {
        // TODO: Main application tasks
        hal::GPIO::togglePin(platform::GPIOB_BASE, 7);  // Heartbeat LED
        
        // Simple delay (replace with timer-based delay)
        for (volatile uint32_t i = 0; i < 1000000; i++);
    }

    return 0;
}

/**
 * @brief Default interrupt handler
 */
extern "C" void Default_Handler(void) {
    spinterfaces::Logging::logError("Unhandled interrupt!");
    while (1) {}
}