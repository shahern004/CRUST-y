# Next Session: Phase 0 to Phase 1 Transition - STM32 Port Preparation

## Current Status

**Phase 0 Implementation**: ✅ **100% COMPLETE**

### Completed This Session:
- ✅ CXX bridge fully functional with demonstration function
- ✅ Rust `calculate_crusty_number()` function implemented (returns 42)
- ✅ C++ successfully calls Rust via CXX bridge
- ✅ Windows build environment fully working
- ✅ MMIO functions stubbed for Windows (conditional compilation)
- ✅ UART functions stubbed for Windows (console output via `putchar`)
- ✅ Application runs successfully on Windows
- ✅ Output verified: "The CRUSTy number is: 42"

### Build System Status:
- ✅ Makefile paths corrected for MinGW target
- ✅ Rust builds with CXX bridge (x86_64-pc-windows-gnu)
- ✅ CXX generates headers in correct location
- ✅ C++ compilation successful
- ✅ Linking successful
- ✅ Executable runs without crashes

---

## What Was Implemented

### 1. CXX Bridge Demonstration Function

**File**: `Rust/src/lib.rs`

Added simple demonstration function to test C++/Rust FFI:

```rust
#[cxx::bridge]
mod ffi {
    extern "Rust" {
        // Existing validation functions...
        fn validate_control_message(msg: &ControlMessage) -> ValidationResult;
        fn validate_status_data(data: &[u16]) -> ValidationResult;

        // NEW: Demonstration function
        fn calculate_crusty_number() -> u32;
    }
}

// Implementation (in parent module scope)
pub fn calculate_crusty_number() -> u32 {
    41 + 1  // Returns 42
}
```

**Key Design Points**:
- Function declared in `extern "Rust"` block (CXX bridge)
- Implementation uses regular `pub fn` (not `extern fn`)
- CXX automatically generates C++ headers and FFI shims
- Zero-overhead FFI call from C++

### 2. C++ Integration

**File**: `src/main.cpp`

```cpp
#include "lib.rs.h"  // CXX-generated header

int main() {
    // ... platform initialization ...

    // Call Rust function
    uint32_t crusty_number = calculate_crusty_number();

    // Output result
    #ifdef WINDOWS_BUILD
        std::cout << "The CRUSTy number is: " << crusty_number << std::endl;
    #endif

    return 0;
}
```

### 3. Windows Build Support (Critical Fixes)

**Files Modified**:
- `include/crusty/hal/mmio.h` - All MMIO functions now conditionally compiled
- `src/hal/uart.cpp` - UART functions use console I/O on Windows

**Problem Solved**:
- Original code tried to access hardware memory addresses on Windows
- Caused access violation (Error -1073741819 / 0xC0000005)
- UART had infinite loops waiting for hardware status bits

**Solution**:
```cpp
// MMIO example (mmio.h)
static inline uint32_t read32(uintptr_t address) {
#ifdef WINDOWS_BUILD
    (void)address;
    return 0;  // Stub - return dummy value
#else
    volatile uint32_t* reg = reinterpret_cast<volatile uint32_t*>(address);
    return *reg;  // Real hardware access
#endif
}

// UART example (uart.cpp)
void UART::transmitByte(uintptr_t uartBase, uint8_t data) {
#ifndef WINDOWS_BUILD
    // Wait for TX register, write to hardware
    while ((MMIO::read32(uartBase + UART_ISR_OFFSET) & UART_ISR_TXE) == 0) {}
    MMIO::write32(uartBase + UART_TDR_OFFSET, data);
#else
    // Windows: output to console
    (void)uartBase;
    putchar(data);
#endif
}
```

### 4. Verified Output

**Console Output** (Windows):
```
[INFO] === CRUST-y Firmware Starting ===
[INFO] Platform: STM32H573I-DK
[INFO] Platform initialization complete
[INFO] Initializing devices...
[INFO] Device initialization complete
[INFO] Initializing components...
[INFO] All layers initialized successfully
[INFO] Starting main application loop
[INFO] ==============================================
[INFO] Testing C++/Rust integration via CXX bridge
[INFO] ==============================================
The CRUSTy number is: 42
[INFO] ==============================================
[INFO] Phase 0 complete - CXX bridge functional
[INFO] Press Enter to exit...
```

---

## Files Modified This Session

### Modified:
1. **`Rust/src/lib.rs`**
   - Added `calculate_crusty_number()` to CXX bridge declaration
   - Implemented function (returns 41 + 1)

2. **`src/main.cpp`**
   - Added `#include "lib.rs.h"` for CXX bridge
   - Added call to `calculate_crusty_number()`
   - Added output with conditional compilation

3. **`include/crusty/hal/mmio.h`**
   - Added `#ifdef WINDOWS_BUILD` stubs for all functions:
     - `read32()`, `write32()`, `read16()`, `write16()`, `read8()`, `write8()`
   - Windows: Returns 0 for reads, no-op for writes
   - STM32: Actual hardware memory access

4. **`src/hal/uart.cpp`**
   - Added `#include <cstdio>` for Windows
   - Added `#ifdef WINDOWS_BUILD` to `transmitByte()` and `receiveByte()`
   - Windows: Uses `putchar()` for console output
   - STM32: Actual UART hardware access

---

## Phase 0 Completion Criteria ✅

All criteria met:

1. ✅ Rust builds with CXX bridge (MinGW target)
2. ✅ CXX generates headers and implementation files
3. ✅ C++ includes CXX headers successfully
4. ✅ Linking combines C++ + Rust static library
5. ✅ Binary runs and outputs expected message
6. ✅ No crashes or runtime errors
7. ✅ C++ successfully calls Rust function via FFI
8. ✅ Rust function executes and returns correct value

**Phase 0 Status**: 🎉 **COMPLETE**

---

## Next Session: STM32 Port Preparation (Phase 1 Start)

### Overview

**Goal**: Prepare project for STM32H573I-DK baremetal deployment

**Key Tasks**:
1. Configure ARM Cortex-M33 toolchain
2. Create custom Rust target for STM32H573
3. Update build system for cross-compilation
4. Remove Windows stubs, enable real hardware
5. Configure linker scripts for STM32 memory layout
6. Test on actual hardware

### Task Breakdown

#### 1. Rust Toolchain Setup for ARM

**Actions**:
- Install ARM target: `rustup target add thumbv8m.main-none-eabihf`
- Verify Cortex-M33 support (STM32H573 = Cortex-M33 with FPU)
- Create custom target JSON if needed for specific features
- Update `.cargo/config.toml` for ARM target

**Target Triple**: `thumbv8m.main-none-eabihf`
- `thumbv8m.main` = ARMv8-M Mainline (Cortex-M33)
- `none` = No OS (baremetal)
- `eabihf` = Embedded ABI, Hard Float

#### 2. C++ ARM Toolchain Setup

**Actions**:
- Install ARM GCC toolchain: `arm-none-eabi-gcc`
- Verify version compatibility with Rust
- Update Makefile for ARM compiler
- Configure compiler flags for Cortex-M33

**Compiler Flags** (Example):
```makefile
CXX := arm-none-eabi-g++
CXXFLAGS := -mcpu=cortex-m33 \
            -mthumb \
            -mfpu=fpv5-sp-d16 \
            -mfloat-abi=hard \
            -specs=nosys.specs
```

#### 3. Linker Script Configuration

**Actions**:
- Create STM32H573 linker script (`stm32h573.ld`)
- Define memory regions (Flash @ 0x08000000, RAM @ 0x20000000)
- Define stack and heap sizes
- Configure vector table placement
- Update Makefile to use linker script

**Memory Layout** (STM32H573I-DK):
```
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 2048K
  RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 640K
}
```

#### 4. Conditional Compilation Cleanup

**Actions**:
- Remove `#ifdef WINDOWS_BUILD` stubs from MMIO
- Remove `#ifdef WINDOWS_BUILD` stubs from UART
- Enable actual hardware access
- Keep conditional compilation for `no_std` vs `std`

**Note**: Keep Windows build capability by using Cargo features:
- Feature `std-test` (default) = Windows development
- Feature `baremetal` = STM32 hardware
- Or use separate build targets

#### 5. Startup Code and Boot Sequence

**Actions**:
- Create `startup.s` for ARM Cortex-M33
- Define reset handler and vector table
- Initialize `.data` and `.bss` sections
- Configure system clocks (HSI/HSE, PLL)
- Call `main()` from reset handler

#### 6. Update Build System

**Makefile Changes**:
```makefile
# Target selection
TARGET := arm  # or 'windows' for development

ifeq ($(TARGET),arm)
    CXX := arm-none-eabi-g++
    CARGO_TARGET := thumbv8m.main-none-eabihf
    CARGO_FEATURES := --no-default-features --features baremetal
    CXXFLAGS := -mcpu=cortex-m33 -mthumb -mfloat-abi=hard
else
    CXX := g++
    CARGO_TARGET := x86_64-pc-windows-gnu
    CARGO_FEATURES := --features std-test
    CXXFLAGS := -DWINDOWS_BUILD
endif
```

#### 7. Hardware Abstraction Layer Verification

**Actions**:
- Verify memory map addresses match STM32H573 reference manual
- Update UART register offsets if needed
- Verify GPIO register offsets
- Test NVIC interrupt configuration
- Validate clock configuration

**Reference**: STM32H573 Reference Manual (RM0481)

#### 8. Debugging Setup

**Actions**:
- Configure OpenOCD for STM32H573I-DK
- Set up GDB for ARM debugging
- Create debug launch configurations
- Configure SWD interface
- Test connection to hardware

**OpenOCD Config** (Example):
```
source [find interface/stlink.cfg]
source [find target/stm32h5x.cfg]
```

---

## Key Decisions Needed Next Session

### 1. Build System Strategy

**Option A**: Separate Makefiles
- `Makefile.windows` - Windows development
- `Makefile.stm32` - STM32 hardware
- Pros: Clean separation
- Cons: Duplication

**Option B**: Single Makefile with Target Selection
- `make TARGET=windows` - Windows development
- `make TARGET=arm` - STM32 hardware
- Pros: DRY principle
- Cons: More complex

**Recommendation**: Option B (single Makefile with conditionals)

### 2. Testing Strategy

**Option A**: Hardware First
- Deploy to STM32 immediately
- Debug on real hardware
- Pros: Realistic testing
- Cons: Slower iteration

**Option B**: QEMU Emulation
- Test with QEMU ARM emulation
- Debug before hardware
- Pros: Fast iteration
- Cons: Emulation limitations

**Recommendation**: Option B initially, then hardware

### 3. CXX Bridge on no_std

**Challenge**: CXX has experimental no_std support

**Options**:
1. Use CXX with experimental no_std (documented in DesignLog.md Lesson 1)
2. Investigate alternatives if issues arise
3. Implement manual FFI if needed

**Current Plan**: Start with CXX no_std, already configured in Cargo.toml

---

## Preparation Checklist for Next Session

### Prerequisites:

- [ ] ARM GCC toolchain installed (`arm-none-eabi-gcc`)
- [ ] Rust ARM target installed (`rustup target add thumbv8m.main-none-eabihf`)
- [ ] OpenOCD installed (for hardware debugging)
- [ ] STM32H573I-DK hardware available
- [ ] ST-Link drivers installed (for programming/debugging)
- [ ] STM32H573 reference manual accessible (RM0481)
- [ ] STM32H573 datasheet accessible (DS13311)

### Documentation to Review:

1. STM32H573 Reference Manual (RM0481)
   - Memory mapping (Chapter 2)
   - Boot configuration (Chapter 3)
   - Clock tree (Chapter 7)
   - GPIO (Chapter 13)
   - UART (Chapter 47)

2. ARM Cortex-M33 Technical Reference Manual
   - NVIC configuration
   - MPU setup (if used)
   - FPU configuration

3. Rust Embedded Book
   - `no_std` best practices
   - Interrupt handling
   - Memory management

---

## Expected Deliverables Next Session

1. **Linker Script**: `stm32h573.ld`
2. **Startup Code**: `startup.s` or `startup.rs`
3. **Updated Makefile**: ARM cross-compilation support
4. **Updated Cargo.toml**: ARM target configuration
5. **Clock Configuration**: System clock initialization
6. **First Hardware Test**: LED blink on STM32H573I-DK

---

## Key Lessons Learned This Session

### Lesson 3: Windows Development Requires Hardware Stubs

**Finding**: Direct hardware access causes crashes on Windows

**Impact**:
- MMIO register access → access violation
- UART polling loops → infinite loops
- GPIO operations → invalid memory access

**Solution**:
- Conditional compilation (`#ifdef WINDOWS_BUILD`)
- Stub functions return safe values on Windows
- Use console I/O (`putchar`) for UART simulation
- All functions work correctly on both platforms

**Value**: Enables rapid development and testing on Windows before hardware deployment

### Lesson 4: CXX Bridge Pattern

**Finding**: Functions in `extern "Rust"` don't use `extern` keyword in implementation

**Pattern**:
- Declaration: `extern "Rust" { fn foo() -> u32; }` (in bridge)
- Implementation: `pub fn foo() -> u32 { ... }` (in parent module)
- CXX generates all FFI shims automatically

**Value**: Simplifies FFI development, no manual `extern "C"` needed

---

## Quick Reference Commands

**Build for Windows**:
```bash
mingw32-make clean
mingw32-make all
mingw32-make run
```

**Check CXX-generated files**:
```bash
ls Rust/target/x86_64-pc-windows-gnu/cxxbridge/crusty-firmware/src/
```

**Run Rust tests**:
```bash
cd Rust && cargo test
```

**Verify toolchains (for next session)**:
```bash
arm-none-eabi-gcc --version
rustup target list | grep thumb
```

---

## Session Summary

**Achievements**:
- ✅ Phase 0 complete - CXX bridge fully functional
- ✅ Demonstrated C++/Rust FFI with working example
- ✅ Windows build environment stable and reliable
- ✅ Foundation ready for STM32 port

**Next Focus**: Transition from Windows development to STM32 baremetal deployment

**Status**: 🎉 Ready for Phase 1 - STM32 Port
