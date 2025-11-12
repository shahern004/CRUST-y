#ifndef crustyV2_COMPONENTS_CONTROL_H
#define crustyV2_COMPONENTS_CONTROL_H

#include "crustyV2/platform/types.h"
#include <cstdint>

namespace crustyV2 {
namespace components {

/**
 * @brief Control component (Layer 5 - Components)
 *
 * High-level control logic and application orchestration.
 * Coordinates between devices and calls Rust safety functions.
 */
class Control {
public:
    /**
     * @brief Initialize the control component
     * @return Status OK if successful
     */
    static Status init();

    /**
     * @brief Main application loop
     * Should be called from main() after initialization
     */
    static void run();

    /**
     * @brief Handle a control event
     * @param eventId Event identifier
     * @param data Event data
     * @param dataLen Length of event data
     * @return Status OK if handled successfully
     */
    static Status handleEvent(uint16_t eventId, const uint16_t* data, uint16_t dataLen);

    /**
     * @brief Check if control component is initialized
     * @return true if initialized, false otherwise
     */
    static bool isInitialized();

private:
    static bool s_initialized;
};

} // namespace components
} // namespace crustyV2

#endif // crustyV2_COMPONENTS_CONTROL_H
