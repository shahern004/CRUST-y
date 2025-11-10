/**
 * @file main.cpp
 * @brief Main entry point for CRUST-y baremetal firmware
 *
 * This is the C++ infrastructure that initializes all layers and
 * orchestrates the application. Rust functions are called for
 * safety-critical operations as defined in Phase 1.
 */

#include "crusty/platform/memory_map.h"
#include "crusty/platform/stm32h573.h"
#include "crusty/platform/types.h"
#include "crusty/hal/nvic.h"
#include "crusty/hal/gpio.h"
#include "crusty/hal/uart.h"
#include "crusty/spinterfaces/logging.h"
#include "crusty/components/control.h"

// Include CXX-generated Rust FFI bridge (Phase 0+)
#include "lib.rs.h"

#ifdef WINDOWS_BUILD
#include <iostream>  // For console input to pause on Windows
#endif

using namespace crusty;

/**
 * @brief Initialize platform and hardware (Layer 1 & 2)
 * @return Status OK if successful
 */
static Status initPlatform() {
    // Initialize UART for logging (115200 baud)
    Status status = spinterfaces::Logging::init(platform::UART4_BASE, 115200);
    if (status != Status::OK) {
        // Can't log if UART init fails, but continue
        return status;
    }

    spinterfaces::Logging::logInfo("=== CRUST-y Firmware Starting ===");
    spinterfaces::Logging::logInfo("Platform: STM32H573I-DK");

    // Initialize GPIO (example: LED on GPIOB pin 7 for status)
    hal::GPIO::initPin(platform::GPIOB_BASE, 7, PinMode::OUTPUT);
    hal::GPIO::clearPin(platform::GPIOB_BASE, 7);  // LED off initially

    spinterfaces::Logging::logInfo("Platform initialization complete");
    return Status::OK;
}

/**
 * @brief Initialize devices (Layer 3)
 * @return Status OK if successful
 */
static Status initDevices() {
    spinterfaces::Logging::logInfo("Initializing devices...");

    // CFPGA initialization will be added in Step 2

    spinterfaces::Logging::logInfo("Device initialization complete");
    return Status::OK;
}

/**
 * @brief Initialize components (Layer 5)
 * @return Status OK if successful
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
    // Layer 1 & 2: Platform and HAL initialization
    Status status = initPlatform();
    if (status != Status::OK) {
        // Platform init failed - halt
        while (1) {}
    }

    // Layer 3: Device initialization
    status = initDevices();
    if (status != Status::OK) {
        spinterfaces::Logging::logError("Device initialization failed");
        while (1) {}
    }

    // Layer 5: Component initialization
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

    // Call Rust function to calculate the CRUSTy number
    uint32_t crusty_number = calculate_crusty_number();

    // Output result
#ifdef WINDOWS_BUILD
    std::cout << "The CRUSTy number is: " << crusty_number << std::endl;
#else
    // For baremetal, format and log via UART
    char buffer[64];
    snprintf(buffer, sizeof(buffer), "The CRUSTy number is: %u", crusty_number);
    spinterfaces::Logging::logInfo(buffer);
#endif

    spinterfaces::Logging::logInfo("==============================================");
    spinterfaces::Logging::logInfo("Phase 0 complete - CXX bridge functional");
    spinterfaces::Logging::logInfo("Press Enter to exit...");

#ifdef WINDOWS_BUILD
    // Keep console open on Windows for manual verification
    std::cin.get();
#endif

    return 0;
}

/**
 * @brief Default interrupt handler
 * Catches any unhandled interrupts
 */
extern "C" void Default_Handler(void) {
    spinterfaces::Logging::logError("Unhandled interrupt!");
    while (1) {}
}
