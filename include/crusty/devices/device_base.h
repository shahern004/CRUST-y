#ifndef CRUSTY_DEVICES_DEVICE_BASE_H
#define CRUSTY_DEVICES_DEVICE_BASE_H

#include "crusty/platform/types.h"

namespace crusty {
namespace devices {

/**
 * @brief Base class for all device abstractions (Layer 3)
 *
 * Devices group HAL functions to perform meaningful work.
 * This provides a common interface for initialization and status checking.
 */
class DeviceBase {
public:
    /**
     * @brief Initialize the device
     * @return Status OK if successful
     */
    virtual Status init() = 0;

    /**
     * @brief Check if device is initialized
     * @return true if initialized, false otherwise
     */
    virtual bool isInitialized() const = 0;

    /**
     * @brief Reset the device
     * @return Status OK if successful
     */
    virtual Status reset() = 0;

    virtual ~DeviceBase() = default;
};

} // namespace devices
} // namespace crusty

#endif // CRUSTY_DEVICES_DEVICE_BASE_H
