// Conditional compilation for std vs no_std environments
// Windows development: uses std (default "std-test" feature)
// STM32 baremetal: uses no_std (build with --no-default-features --features baremetal)

#![cfg_attr(not(feature = "std-test"), no_std)]

// Only import alloc for baremetal (no_std) builds
#[cfg(not(feature = "std-test"))]
extern crate alloc;

// ============================================================================
// Global Allocator Configuration (baremetal only)
// ============================================================================

#[cfg(not(feature = "std-test"))]
use embedded_alloc::Heap;

#[cfg(not(feature = "std-test"))]
#[global_allocator]
static HEAP: Heap = Heap::empty();

/// Initialize the heap allocator with 64KB of memory
/// This must be called before any heap allocations occur (baremetal only)
///
/// Safety: This uses a static mut buffer for heap memory
/// The heap size is conservative (64KB) given the target has 640KB RAM
#[cfg(not(feature = "std-test"))]
pub fn init_heap() {
    const HEAP_SIZE: usize = 64 * 1024; // 64KB heap
    static mut HEAP_MEM: [u8; HEAP_SIZE] = [0; HEAP_SIZE];

    unsafe {
        HEAP.init(HEAP_MEM.as_ptr() as usize, HEAP_SIZE);
    }
}

/// Stub for Windows development (std available, no need for custom heap)
#[cfg(feature = "std-test")]
pub fn init_heap() {
    // No-op on Windows - std provides allocator
}

// ============================================================================
// Panic Handler (baremetal only - std provides its own)
// ============================================================================

#[cfg(not(feature = "std-test"))]
use core::panic::PanicInfo;

#[cfg(not(feature = "std-test"))]
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // In baremetal environment, just halt
    // TODO: For production, log panic info via C++ logging before halting
    loop {}
}

// ============================================================================
// CXX Bridge Definition
// ============================================================================

#[cxx::bridge]
mod ffi {
    // ------------------------------------------------------------------------
    // Shared Data Structures (visible to both C++ and Rust)
    // ------------------------------------------------------------------------

    /// Control message structure for CFPGA FIFO communication
    /// Fixed-size array for deterministic memory usage (no heap allocation)
    #[derive(Debug, Clone)]
    struct ControlMessage {
        /// Command identifier (e.g., 0x0042 for specific command)
        command_id: u16,

        /// Length of valid data in the payload array (in u16 words)
        length: u16,

        /// Payload data buffer (fixed size: 256 x 16-bit words)
        /// Using fixed-size array to avoid heap allocation
        data: [u16; 256],

        /// Checksum for message integrity validation
        checksum: u16,
    }

    /// Result of validation operations
    /// Returned by Rust validation functions to C++
    #[derive(Debug, Clone, Copy)]
    struct ValidationResult {
        /// True if validation passed, false if failed
        is_valid: bool,

        /// Error code if validation failed (0 = no error)
        error_code: u16,
    }

    // ------------------------------------------------------------------------
    // Rust Functions (called from C++)
    // ------------------------------------------------------------------------

    extern "Rust" {
        /// Validate a control message from the CFPGA FIFO
        ///
        /// Performs the following checks:
        /// - Checksum verification
        /// - Command ID within valid range
        /// - Payload length within bounds
        /// - Data integrity
        ///
        /// # Arguments
        /// * `msg` - Reference to ControlMessage to validate
        ///
        /// # Returns
        /// ValidationResult indicating success or specific error
        fn validate_control_message(msg: &ControlMessage) -> ValidationResult;

        /// Validate status data before writing to FIFO
        ///
        /// Ensures status data meets format requirements and value ranges
        ///
        /// # Arguments
        /// * `data` - Slice of u16 status data
        ///
        /// # Returns
        /// ValidationResult indicating success or specific error
        fn validate_status_data(data: &[u16]) -> ValidationResult;
    }

    // ------------------------------------------------------------------------
    // C++ Functions (called from Rust)
    // ------------------------------------------------------------------------

    unsafe extern "C++" {
        // Currently no C++ functions called from Rust
        // Will add logging bridge here if needed:
        // fn log_from_rust(level: u8, message: &str);
    }
}

// ============================================================================
// Rust Implementation of Validation Functions
// ============================================================================

/// Error codes for validation failures
mod error_codes {
    pub const ERROR_NONE: u16 = 0;
    pub const ERROR_CHECKSUM: u16 = 1;
    pub const ERROR_INVALID_COMMAND: u16 = 2;
    pub const ERROR_BUFFER_OVERFLOW: u16 = 3;
    pub const ERROR_INVALID_LENGTH: u16 = 4;
    pub const ERROR_INVALID_DATA: u16 = 5;
}

/// Valid command ID range (example range - adjust as needed)
const MIN_VALID_COMMAND_ID: u16 = 0x0040;
const MAX_VALID_COMMAND_ID: u16 = 0x0050;

/// Maximum payload length (must not exceed data array size)
const MAX_PAYLOAD_LENGTH: u16 = 256;

/// Calculate checksum for control message
/// Uses simple additive checksum algorithm
///
/// # Arguments
/// * `msg` - Reference to ControlMessage
///
/// # Returns
/// Calculated checksum value
fn calculate_checksum(msg: &ffi::ControlMessage) -> u16 {
    let mut checksum: u32 = 0;

    // Include command_id in checksum
    checksum = checksum.wrapping_add(msg.command_id as u32);

    // Include length in checksum
    checksum = checksum.wrapping_add(msg.length as u32);

    // Include valid payload data in checksum (only up to length)
    // Use std::cmp for std builds, core::cmp for no_std builds
    #[cfg(feature = "std-test")]
    let data_length = std::cmp::min(msg.length as usize, msg.data.len());
    #[cfg(not(feature = "std-test"))]
    let data_length = core::cmp::min(msg.length as usize, msg.data.len());

    for i in 0..data_length {
        checksum = checksum.wrapping_add(msg.data[i] as u32);
    }

    // Return lower 16 bits
    (checksum & 0xFFFF) as u16
}

/// Validate control message from CFPGA FIFO
///
/// This function implements memory-safe validation with zero unsafe blocks
/// All array accesses are bounds-checked by Rust
pub fn validate_control_message(msg: &ffi::ControlMessage) -> ffi::ValidationResult {
    // Check 1: Validate payload length within bounds
    if msg.length > MAX_PAYLOAD_LENGTH {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_BUFFER_OVERFLOW,
        };
    }

    // Check 2: Validate command ID in allowed range
    if msg.command_id < MIN_VALID_COMMAND_ID || msg.command_id > MAX_VALID_COMMAND_ID {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_INVALID_COMMAND,
        };
    }

    // Check 3: Verify checksum
    let calculated_checksum = calculate_checksum(msg);
    if calculated_checksum != msg.checksum {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_CHECKSUM,
        };
    }

    // Check 4: Validate length is non-zero
    if msg.length == 0 {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_INVALID_LENGTH,
        };
    }

    // All checks passed
    ffi::ValidationResult {
        is_valid: true,
        error_code: error_codes::ERROR_NONE,
    }
}

/// Validate status data before writing to FIFO
///
/// Ensures status data meets format requirements
pub fn validate_status_data(data: &[u16]) -> ffi::ValidationResult {
    // Check 1: Validate data length is reasonable
    if data.is_empty() {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_INVALID_LENGTH,
        };
    }

    if data.len() > MAX_PAYLOAD_LENGTH as usize {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_BUFFER_OVERFLOW,
        };
    }

    // Check 2: Validate status data values (example: check for reserved values)
    // This is application-specific - adjust validation rules as needed
    for &value in data.iter() {
        // Example: reject status values in reserved range
        if value == 0xFFFF {
            return ffi::ValidationResult {
                is_valid: false,
                error_code: error_codes::ERROR_INVALID_DATA,
            };
        }
    }

    // All checks passed
    ffi::ValidationResult {
        is_valid: true,
        error_code: error_codes::ERROR_NONE,
    }
}

// ============================================================================
// Unit Tests
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_control_message() {
        let mut msg = ffi::ControlMessage {
            command_id: 0x0042,
            length: 4,
            data: [0; 256],
            checksum: 0,
        };

        // Fill test data
        msg.data[0] = 0x1111;
        msg.data[1] = 0x2222;
        msg.data[2] = 0x3333;
        msg.data[3] = 0x4444;

        // Calculate correct checksum
        msg.checksum = calculate_checksum(&msg);

        let result = validate_control_message(&msg);
        assert!(result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_NONE);
    }

    #[test]
    fn test_invalid_checksum() {
        let mut msg = ffi::ControlMessage {
            command_id: 0x0042,
            length: 4,
            data: [0; 256],
            checksum: 0xDEAD, // Wrong checksum
        };

        msg.data[0] = 0x1111;

        let result = validate_control_message(&msg);
        assert!(!result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_CHECKSUM);
    }

    #[test]
    fn test_invalid_command_id() {
        let mut msg = ffi::ControlMessage {
            command_id: 0xFFFF, // Out of valid range
            length: 4,
            data: [0; 256],
            checksum: 0,
        };

        msg.checksum = calculate_checksum(&msg);

        let result = validate_control_message(&msg);
        assert!(!result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_INVALID_COMMAND);
    }

    #[test]
    fn test_buffer_overflow_protection() {
        let msg = ffi::ControlMessage {
            command_id: 0x0042,
            length: 300, // Exceeds 256 word buffer
            data: [0; 256],
            checksum: 0,
        };

        let result = validate_control_message(&msg);
        assert!(!result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_BUFFER_OVERFLOW);
    }

    #[test]
    fn test_valid_status_data() {
        let data: [u16; 8] = [0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008];

        let result = validate_status_data(&data);
        assert!(result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_NONE);
    }

    #[test]
    fn test_invalid_status_data_reserved_value() {
        let data: [u16; 4] = [0x0001, 0x0002, 0xFFFF, 0x0004]; // 0xFFFF is reserved

        let result = validate_status_data(&data);
        assert!(!result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_INVALID_DATA);
    }

    #[test]
    fn test_empty_status_data() {
        let data: [u16; 0] = [];

        let result = validate_status_data(&data);
        assert!(!result.is_valid);
        assert_eq!(result.error_code, error_codes::ERROR_INVALID_LENGTH);
    }
}
