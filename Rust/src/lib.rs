// CRUST-y Rust Library for STM32H573 Baremetal
// Uses no_std with alloc for CXX bridge compatibility

#![no_std]

extern crate alloc;

use embedded_alloc::Heap;
use core::panic::PanicInfo;

// ============================================================================
// Global Allocator Configuration
// ============================================================================

#[global_allocator]
static HEAP: Heap = Heap::empty();

/// Initialize the heap allocator with 64KB of memory
/// MUST be called before any CXX bridge functions that allocate
///
/// Safety: Uses static mut buffer for heap memory
pub fn init_heap() {
    const HEAP_SIZE: usize = 64 * 1024; // 64KB heap for CXX bridge
    static mut HEAP_MEM: [u8; HEAP_SIZE] = [0; HEAP_SIZE];

    unsafe {
        HEAP.init(HEAP_MEM.as_ptr() as usize, HEAP_SIZE);
    }
}

// ============================================================================
// Panic Handler
// ============================================================================

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // TODO: Log panic info via C++ logging before halting
    loop {}
}

// ============================================================================
// CXX Bridge Definition
// ============================================================================

#[cxx::bridge]
mod ffi {
    /// Control message structure for CFPGA FIFO communication
    #[derive(Debug, Clone)]
    struct ControlMessage {
        command_id: u16,
        length: u16,
        data: [u16; 256],
        checksum: u16,
    }

    /// Result of validation operations
    #[derive(Debug, Clone, Copy)]
    struct ValidationResult {
        is_valid: bool,
        error_code: u16,
    }

    extern "Rust" {
        fn validate_control_message(msg: &ControlMessage) -> ValidationResult;
        fn validate_status_data(data: &[u16]) -> ValidationResult;
        fn calculate_crustyV2_number() -> u32;
    }

    unsafe extern "C++" {
        // Future: C++ logging bridge
        // fn log_from_rust(level: u8, message: &str);
    }
}

// ============================================================================
// Implementation
// ============================================================================

mod error_codes {
    pub const ERROR_NONE: u16 = 0;
    pub const ERROR_CHECKSUM: u16 = 1;
    pub const ERROR_INVALID_COMMAND: u16 = 2;
    pub const ERROR_BUFFER_OVERFLOW: u16 = 3;
    pub const ERROR_INVALID_LENGTH: u16 = 4;
    pub const ERROR_INVALID_DATA: u16 = 5;
}

const MIN_VALID_COMMAND_ID: u16 = 0x0040;
const MAX_VALID_COMMAND_ID: u16 = 0x0050;
const MAX_PAYLOAD_LENGTH: u16 = 256;

fn calculate_checksum(msg: &ffi::ControlMessage) -> u16 {
    let mut checksum: u32 = 0;

    checksum = checksum.wrapping_add(msg.command_id as u32);
    checksum = checksum.wrapping_add(msg.length as u32);

    let data_length = core::cmp::min(msg.length as usize, msg.data.len());

    for i in 0..data_length {
        checksum = checksum.wrapping_add(msg.data[i] as u32);
    }

    (checksum & 0xFFFF) as u16
}

pub fn validate_control_message(msg: &ffi::ControlMessage) -> ffi::ValidationResult {
    if msg.length > MAX_PAYLOAD_LENGTH {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_BUFFER_OVERFLOW,
        };
    }

    if msg.command_id < MIN_VALID_COMMAND_ID || msg.command_id > MAX_VALID_COMMAND_ID {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_INVALID_COMMAND,
        };
    }

    let calculated_checksum = calculate_checksum(msg);
    if calculated_checksum != msg.checksum {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_CHECKSUM,
        };
    }

    if msg.length == 0 {
        return ffi::ValidationResult {
            is_valid: false,
            error_code: error_codes::ERROR_INVALID_LENGTH,
        };
    }

    ffi::ValidationResult {
        is_valid: true,
        error_code: error_codes::ERROR_NONE,
    }
}

pub fn validate_status_data(data: &[u16]) -> ffi::ValidationResult {
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

    for &value in data.iter() {
        if value == 0xFFFF {
            return ffi::ValidationResult {
                is_valid: false,
                error_code: error_codes::ERROR_INVALID_DATA,
            };
        }
    }

    ffi::ValidationResult {
        is_valid: true,
        error_code: error_codes::ERROR_NONE,
    }
}

pub fn calculate_crustyV2_number() -> u32 {
    41 + 1
}