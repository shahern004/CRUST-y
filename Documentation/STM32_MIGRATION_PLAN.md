# STM32 Migration Plan - Comprehensive Strategy

> **STM32-Only Branch Note**: This branch is STM32 baremetal-only for ARM Cortex-M33. Phase 4 (Windows stub removal) is complete. This document provides the complete migration roadmap.

**Document Purpose:** Comprehensive strategic migration guide (architecture → [CRUSTyOverview.md](CRUSTyOverview.md), immediate actions → [NEXT_SESSION.md](NEXT_SESSION.md))

**Version:** 1.1
**Date:** November 12, 2025
**Target Platform:** STM32H573I-DK Development Board
**Production Target:** STM32U5A5 Security Processor

---

## Migration Strategy

### Hybrid Approach Philosophy

CRUST-y integrates official STMicroelectronics tools while maintaining architectural independence:

**Leverage from ST:**
- STM32CubeMX for error-free clock configuration
- CMSIS register definitions (hardware-verified)
- HAL driver examples as reference implementations

**Preserve CRUST-y Design:**
- 5-layer architecture
- Rust memory-safe validation layer
- Custom Makefile build system (no CMake/HAL dependencies)

**Benefit:** Combines ST's hardware expertise with CRUST-y's safety-critical design philosophy

---

## STM32CubeH5 Resources

### Package Location
`C:\GithubProjects\CRUST-y\STM32CubeH5\`

### Key Resources Utilized

| Resource | Path | Usage |
|----------|------|-------|
| **CMSIS Device Headers** | `Drivers/CMSIS/Device/ST/STM32H5xx/Include/stm32h573xx.h` | Register definitions included by our platform layer |
| **System Template** | `Drivers/CMSIS/Device/ST/STM32H5xx/Source/Templates/system_stm32h5xx.c` | Clock configuration reference |
| **Startup Template** | `Source/Templates/startup_stm32h573xx.s` | Vector table and reset handler reference (already used) |
| **HAL Examples** | `Projects/STM32H573I-DK/Examples/` | GPIO, UART, NVIC reference implementations |
| **Board BSP** | `Drivers/BSP/STM32H573I-DK/` | Board-specific configurations |

### Tools Required

| Tool | Purpose | Download |
|------|---------|----------|
| **STM32CubeMX** | System initialization code generator | [ST Website](https://www.st.com/en/development-tools/stm32cubemx.html) |
| **STM32CubeProgrammer** | Firmware flashing and debugging | [ST Website](https://www.st.com/en/development-tools/stm32cubeprog.html) |
| **ARM GCC Toolchain** | Cross-compiler for Cortex-M33 | [ARM Website](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) |

---

## Phase Breakdown

### Phase 0: CXX Bridge Foundation ✅ COMPLETE

**Objective:** Establish type-safe Rust/C++ FFI infrastructure

**Achievements:**
- CXX bridge generates C++ headers automatically
- Rust validation functions implemented (100% memory-safe, zero unsafe blocks)
- Rust builds for ARM target (`thumbv8m.main-none-eabihf`)
- Build system: Rust → static library → linked with C++

**Files:**
- `rust/src/lib.rs` - CXX bridge definitions
- `rust/src/validation.rs` - Memory-safe validation logic
- `rust/Cargo.toml` - no_std configuration with embedded-alloc
- `rust/.cargo/config.toml` - ARM Cortex-M33 target

---

### Phase 1: System Initialization 🔄 IN PROGRESS

**Objective:** Generate and integrate clock configuration for STM32H573

**Status:** Infrastructure ready, awaiting clock configuration

#### Completed Infrastructure:
- ✅ ARM GCC toolchain installed
- ✅ Linker script created (`stm32h573.ld`) with STM32H573 memory map
- ✅ Startup assembly (`startup.s`) with full vector table and SystemInit() call
- ✅ System init stub (`src/platform/system_stm32h5xx.c`) ready for CubeMX code
- ✅ FPU configuration enabled in SystemInit()
- ✅ Windows stubs removed (Phase 4 completed early)

#### Remaining Tasks:
1. **Generate Clock Configuration with STM32CubeMX**
   - Board: STM32H573I-DK
   - Clock: HSI (64 MHz) → PLL → 250 MHz SYSCLK
   - Output: `CubeMX_Generated/Core/Src/system_stm32h5xx.c`

2. **Integrate ST CMSIS Headers**
   - Include `stm32h573xx.h` in platform layer
   - Add CMSIS paths to Makefile
   - Replace minimal register definitions with ST official headers

3. **First ARM Build**
   - Verify compilation with ARM GCC
   - Check binary size (< 2MB Flash, < 640KB RAM)
   - Resolve any linker or include path issues

**Deliverables:**
- Working clock configuration (250 MHz SYSCLK)
- Successful ARM Cortex-M33 binary generation
- ST CMSIS headers integrated

---

### Phase 2: Peripheral Initialization & CFPGA FIFO ⏳ PLANNED

**Objective:** Enable debug logging and implement simulated FPGA interface

#### Task 2.1: UART4 Debug Logging

**Purpose:** Enable debug output for firmware development

**Configuration:**
- Peripheral: UART4
- Baud rate: 115200
- Pins: PH13 (TX), PH14 (RX) - STM32H573I-DK defaults
- Mode: Polling (Phase 2), Interrupt-driven (future enhancement)

**Implementation:**
- Use existing HAL (`src/hal/uart.cpp`)
- Enable UART4 clock in RCC
- Configure GPIO alternate functions
- Test with "Hello STM32" message

**STM32CubeMX Configuration:**
- Connectivity → UART4 → Mode: Asynchronous
- Parameter Settings → Baud: 115200, Word: 8 Bits, Parity: None, Stop: 1

#### Task 2.2: CFPGA FIFO Simulation

**Purpose:** Simulate FPGA communication interface for prototype testing

**Design Specifications:**
- Structure: Circular buffer (512 bytes)
- Interrupt: EXTI2 (threshold-based)
- Operations: Bidirectional (control commands in, status data out)

**Implementation:**
- `include/crustyV2/devices/cfpga_fifo.h` - Device class definition
- `src/devices/cfpga_fifo.cpp` - Circular buffer implementation
- ISR: `EXTI2_IRQHandler()` in startup.s

**Integration with Rust:**
- C++ FIFO ISR reads data into buffer
- C++ calls Rust `validate_control_message()` via CXX bridge
- Rust validates checksums, bounds, command IDs
- C++ processes validated commands

#### Task 2.3: End-to-End Integration Test

**Test Flow:**
1. FIFO receives simulated control message
2. Threshold reached → EXTI2 interrupt fires
3. ISR reads FIFO data
4. ISR calls Rust validation function
5. Rust returns validation result
6. ISR processes valid commands or logs errors
7. Status response written back to FIFO

**Success Criteria:**
- UART output shows "FIFO Interrupt Triggered"
- Rust validation function executes without errors
- Valid commands processed successfully
- Invalid commands rejected with logged error codes

**Deliverables:**
- UART4 functional with debug output
- CFPGA FIFO circular buffer operational
- Rust validation integrated with interrupt flow
- End-to-end test passing

---

### Phase 3: Additional HAL Peripherals ⏳ PLANNED

**Objective:** Complete peripheral driver suite

#### GPIO Enhancement
- LED control for status indication
- Test pins for debug/timing analysis
- Reference: `STM32CubeH5/Projects/STM32H573I-DK/Examples/GPIO/`

#### NVIC Priority Configuration
- UART4 interrupt priority
- EXTI2 interrupt priority
- Configurable priority scheme for future expansion

#### Additional Peripherals (as needed)
- SPI (future FPGA hardware integration)
- I2C (sensor interfaces)
- Timers (real-time clock, PWM)

---

### Phase 4: Windows Stub Removal ✅ COMPLETE

**Objective:** Remove development stubs for STM32-only builds

**Status:** Completed early (before Phase 1)

**Changes Made:**
- ✅ `include/crustyV2/hal/mmio.h` - Removed all `WINDOWS_BUILD` conditionals (6 functions)
- ✅ `src/hal/uart.cpp` - Removed console I/O stubs
- ✅ `src/hal/nvic.cpp` - Removed Windows simulation code

**Result:** All HAL functions now use direct STM32 hardware access only

---

### Phase 5: Medium Priority Components ⏳ FUTURE

**Objective:** Expand Rust safety coverage to internal components

**Candidates for Rust Implementation:**
- Cryptographic key management functions
- Non-volatile memory operations
- Security-critical state machines

**Approach:** Incremental migration based on risk assessment

---

### Phase 6: Full Rust Transition ⏳ OUT OF SCOPE

**Objective:** Complete transition to pure Rust firmware

**Note:** Out of scope for current prototype. Proof-of-concept focuses on hybrid architecture feasibility.

---

## Technical Specifications

### Clock Configuration Target

| Parameter | Source | Frequency |
|-----------|--------|-----------|
| **HSI** | Internal oscillator | 64 MHz |
| **PLL Input** | HSI / PLLM | 16 MHz (PLLM = 4) |
| **VCO** | Input × PLLN | 2000 MHz (PLLN = 125) |
| **SYSCLK** | VCO / PLLP | 250 MHz (PLLP = 8) |
| **HCLK** | SYSCLK / AHB prescaler | 250 MHz (prescaler = 1) |
| **APB1/2/3** | HCLK / APB prescaler | 250 MHz (prescaler = 1) |

### Memory Layout (from stm32h573.ld)

| Section | Address | Size |
|---------|---------|------|
| **Flash** | 0x08000000 | 2 MB |
| **SRAM** | 0x20000000 | 640 KB |
| **Stack** | Top of SRAM downward | 32 KB (configurable) |
| **Heap** | After .bss upward | Remaining SRAM |

### Interrupt Vector Table (from startup.s)

| IRQ | Handler | Purpose |
|-----|---------|---------|
| **EXTI2** | EXTI2_IRQHandler | CFPGA FIFO threshold |
| **UART4** | UART4_IRQHandler | Debug logging (future) |
| **All Others** | Default_Handler | Weak default (infinite loop) |

---

## STM32CubeMX Configuration Guide

### Project Creation

1. **Launch STM32CubeMX**
2. **New Project** → **Board Selector**
3. **Search:** "STM32H573I-DK"
4. **Select Board:** STM32H573I-DK
5. **Initialize peripherals:** No (manual configuration)

### Clock Configuration

1. **Pinout & Configuration** → **System Core** → **RCC**
2. **High Speed Clock (HSI):** ON (64 MHz)
3. **PLL Configuration:**
   - Source: HSI
   - PLLM: 4 (divider)
   - PLLN: 125 (multiplier)
   - PLLP: 8 (divider) → SYSCLK
4. **System Clock Mux:** PLLCLK
5. **Clock Tree:** Verify 250 MHz SYSCLK

### UART4 Configuration

1. **Pinout & Configuration** → **Connectivity** → **UART4**
2. **Mode:** Asynchronous
3. **Configuration:**
   - Baud Rate: 115200
   - Word Length: 8 Bits
   - Parity: None
   - Stop Bits: 1
4. **GPIO Pins:** PH13 (TX), PH14 (RX)

### NVIC Configuration

1. **Pinout & Configuration** → **System Core** → **NVIC**
2. **Enable:**
   - UART4 global interrupt (Priority: 5)
   - EXTI line 2 interrupt (Priority: 3)

### Code Generation

1. **Project** → **Settings**
2. **Project Name:** CubeMX_Generated
3. **Project Location:** `C:\GithubProjects\CRUST-y\CubeMX_Generated\`
4. **Toolchain:** Makefile
5. **Generate Code**

### Extracting Generated Code

**From `CubeMX_Generated/Core/Src/system_stm32h5xx.c`:**
- Copy clock configuration section (RCC, Flash, PLL setup)
- Paste into `src/platform/system_stm32h5xx.c` at TODO marker (line 79)

**From `CubeMX_Generated/Core/Src/main.c`:**
- Reference UART initialization sequence
- Reference GPIO configuration

**From `CubeMX_Generated/Makefile`:**
- Reference compiler flags
- Reference include paths

---

## Build System Configuration

### Makefile Updates Required

**Add ST CMSIS Include Paths:**
```makefile
# ST CMSIS headers
ST_CMSIS_BASE = STM32CubeH5/Drivers/CMSIS
INCLUDES += -I$(ST_CMSIS_BASE)/Device/ST/STM32H5xx/Include
INCLUDES += -I$(ST_CMSIS_BASE)/Include
```

**Verify ARM Toolchain:**
```makefile
# ARM Cortex-M33 toolchain
CXX := arm-none-eabi-g++
CC := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
SIZE := arm-none-eabi-size
```

**Verify Compiler Flags:**
```makefile
# CPU-specific flags
CPU_FLAGS := -mcpu=cortex-m33 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard

# C++ flags
CXXFLAGS := -std=c++17 -O2 -g $(CPU_FLAGS) -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections

# Linker flags
LDFLAGS := -T stm32h573.ld -Wl,--gc-sections -specs=nosys.specs $(CPU_FLAGS)
```

### Build Commands

```bash
# Clean build
make clean

# Build firmware
make

# Check binary size
arm-none-eabi-size build/crustyV2_firmware.elf

# Generate .bin file for flashing
arm-none-eabi-objcopy -O binary build/crustyV2_firmware.elf build/crustyV2_firmware.bin

# Flash to board (requires STM32CubeProgrammer)
STM32_Programmer_CLI -c port=SWD -w build/crustyV2_firmware.bin 0x08000000 -rst
```

---

## Testing Strategy

### Phase 1 Testing: System Initialization

**Test 1: Binary Size Verification**
```bash
arm-none-eabi-size build/crustyV2_firmware.elf
```
**Pass Criteria:** Flash < 2MB, RAM < 640KB

**Test 2: Clock Configuration Verification**
- Use STM32CubeProgrammer to read RCC registers
- Verify SYSCLK = 250 MHz
- Verify PLL configuration matches target

### Phase 2 Testing: Peripheral Functionality

**Test 1: UART4 Output**
- Connect USB-to-serial adapter to PH13 (TX)
- Terminal: 115200 baud, 8N1
- Expected: "CRUST-y Firmware Initialized" message

**Test 2: CFPGA FIFO Interrupt**
- Write test data to FIFO (software trigger)
- Verify EXTI2 interrupt fires
- UART outputs: "FIFO Interrupt: Data Received"

**Test 3: Rust Validation Integration**
- Send valid control message to FIFO
- Expected: "Validation Passed: Command Executed"
- Send invalid control message (bad checksum)
- Expected: "Validation Failed: Checksum Mismatch"

---

## Risk Mitigation

### Risk: Clock Configuration Errors

**Mitigation:**
- Use STM32CubeMX-generated code (ST-verified)
- Cross-reference with ST Reference Manual RM0481
- Test at lower frequencies first (HSI 64 MHz) before PLL

### Risk: Linker Script Memory Errors

**Mitigation:**
- Use ST template linker script as reference
- Verify memory sections with `arm-none-eabi-size`
- Enable MPU (Memory Protection Unit) to catch violations

### Risk: CXX Bridge Compatibility with no_std

**Mitigation:**
- Rust validation functions already tested in no_std mode
- CXX bridge generates standard C FFI (platform-independent)
- Fallback: Use raw FFI if CXX no_std issues arise

### Risk: Interrupt Priority Conflicts

**Mitigation:**
- Document all interrupt priorities in NVIC configuration
- Use NVIC grouping for preemption priorities
- Test interrupt latency requirements

---

## Maintenance and Updates

### When to Update This Document

- **New phases added:** Update phase breakdown section
- **Tool versions change:** Update tools table with new version numbers
- **Hardware target changes:** Update technical specifications
- **Migration strategy evolves:** Update strategy section

### Document Ownership

This document is the **authoritative migration reference**. Other documents serve specific purposes:
- [CRUSTyOverview.md](CRUSTyOverview.md) - Architecture design (what the system is)
- [NEXT_SESSION.md](NEXT_SESSION.md) - Immediate actions (what to do now)
- [DesignLog.md](DesignLog.md) - Historical decisions (why choices were made)

---

## References

### STMicroelectronics Documentation
- [STM32H573 Reference Manual (RM0481)](https://www.st.com/resource/en/reference_manual/rm0481-stm32h563h573-and-stm32h562-armbased-32bit-mcus-stmicroelectronics.pdf)
- [STM32H573 Datasheet](https://www.st.com/resource/en/datasheet/stm32h573ii.pdf)
- [STM32CubeH5 User Manual (UM3065)](STM32CubeH5/Documentations/UM3065.pdf)

### ARM Documentation
- [Cortex-M33 Technical Reference Manual](https://developer.arm.com/documentation/100235/latest/)
- [ARM GCC Toolchain Documentation](https://gcc.gnu.org/onlinedocs/)

### Internal Documentation
- [CRUSTyOverview.md](CRUSTyOverview.md) - System architecture
- [DesignLog.md](DesignLog.md) - Design decisions and lessons learned
- [NEXT_SESSION.md](NEXT_SESSION.md) - Immediate tactical actions

### External Standards
- NSA Memory-Safe Languages Guidance
- MISRA C++ 2023 (Automotive Safety Standard)

---

*Last Updated: November 12, 2025*
*Document Version: 1.1*
