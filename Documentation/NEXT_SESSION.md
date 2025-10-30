# Next Session: STM32 Migration - Hybrid Approach with STM32CubeH5

**Date:** October 30, 2025
**Current Phase:** Phase 0 Complete → Phase 1 (System Initialization)
**Strategy:** **HYBRID APPROACH** - Leverage STM32CubeH5 package while maintaining our architecture

---

## Executive Summary

We are adopting a **hybrid approach** that combines:
- ✅ **Official ST tools** (STM32CubeMX for code generation)
- ✅ **STM32CubeH5 package** (HAL drivers, examples, register definitions)
- ✅ **Our custom architecture** (5-layer design, Rust validation)
- ✅ **Our build system** (Makefile with dual Windows/ARM targets)

This approach **eliminates low-level errors** (clock misconfiguration, register mistakes) while **maintaining architectural flexibility**.

---

## Current Status Summary

### Phase 0: CXX Bridge Foundation ✅ 100% COMPLETE

**Achievements:**
- ✅ Rust library builds successfully (std and no_std modes)
- ✅ CXX bridge generates FFI bindings automatically
- ✅ C++ successfully calls Rust functions
- ✅ Validation functions implemented (100% memory-safe)
- ✅ Windows development build working
- ✅ Conditional compilation for Windows/STM32

**Files Complete:**
- `rust/src/lib.rs` - CXX bridge definitions
- `rust/src/validation.rs` - Memory-safe validation logic
- `rust/Cargo.toml` - Dual feature configuration
- `Makefile` - Windows build system
- All Layer 1-5 C++ infrastructure (Windows mode)

### STM32 Migration Preparation ✅ INFRASTRUCTURE READY

**Completed Previous Session:**
- ✅ Rust ARM target installed (`thumbv8m.main-none-eabihf`)
- ✅ Cargo configured for ARM Cortex-M33
- ✅ Linker script created (`stm32h573.ld`)
- ✅ Startup code created (`startup.s` with full vector table)
- ✅ STM32CubeH5 package available locally
- ✅ Migration plan documented

**Completed This Session (October 30, 2025):**
- ✅ **Linker script updated** - ST-compatible sections added (.rodata, .init/.fini, interworking)
- ✅ **Startup file updated** - Now calls `SystemInit()` before main (ST-compatible boot sequence)
- ✅ **SystemInit infrastructure created** - `system_stm32h5xx.c/.h` stub ready for CubeMX code
- ✅ **FPU configuration** - Hardware floating point enabled in SystemInit
- ✅ **Makefile updated** - Builds new system initialization file
- ✅ **Windows build verified** - All changes compile successfully

**Files Created/Updated:**
- `stm32h573.ld` - **UPDATED** with ST-compatible sections, kept superior heap/stack config
- `startup.s` - **UPDATED** to call SystemInit(), FPU hardware floating point enabled
- `src/platform/system_stm32h5xx.c` - **NEW** ST-compatible system init stub (ready for CubeMX)
- `include/crusty/platform/system_stm32h5xx.h` - **NEW** SystemInit() declarations
- `Makefile` - **UPDATED** to compile system_stm32h5xx.c
- `rust/.cargo/config.toml` - ARM target configuration
- `Documentation/STM32_MIGRATION_PLAN.md` - Comprehensive migration guide

---

## NEW STRATEGY: Hybrid Approach

### What Changed?

**Original Plan:**
- Build all system initialization from scratch
- Manually configure clocks, peripherals
- High risk of register configuration errors

**New Hybrid Plan:**
- Use **STM32CubeMX** to generate initialization code
- Reference **STM32CubeH5 HAL examples** for correct configurations
- Adapt generated code to our architecture
- **Lower risk, faster development, correct-by-design**

### Available Resources (STM32CubeH5 Package)

Located at: `C:\GithubProjects\CRUST-y\STM32CubeH5\`

| Resource | Location | How We'll Use It |
|----------|----------|------------------|
| **Official Register Definitions** | `Drivers/CMSIS/Device/ST/STM32H5xx/Include/stm32h573xx.h` | Include in our platform layer |
| **System Init Template** | `Drivers/CMSIS/Device/ST/STM32H5xx/Source/Templates/system_stm32h5xx.c` | Adapt for our `system_init.cpp` |
| **Startup Code Reference** | `Source/Templates/startup_stm32h573xx.s` | Already used as reference ✅ |
| **HAL Driver Examples** | `Projects/STM32H573I-DK/Examples/` | Reference for UART/GPIO/NVIC |
| **26 Board Examples** | `Projects/STM32H573I-DK/Examples/GPIO/`, etc. | Verify our implementations |
| **Template Projects** | `Projects/STM32H573I-DK/Templates/` | Empty project structure |

### What STM32CubeMX Will Generate

When we run STM32CubeMX in the next session:

1. **Clock Configuration**
   - HSI → PLL configuration for 250 MHz
   - All prescaler settings (AHB, APB1/2/3)
   - Flash wait states
   - Power regulator voltage scaling

2. **Peripheral Initialization**
   - UART4 configuration (115200 baud, 8N1)
   - GPIO port clock enables
   - NVIC interrupt priorities

3. **Generated Files**
   - `system_stm32h5xx.c` - System clock initialization
   - `main.c` - Peripheral initialization examples
   - `stm32h5xx_hal_conf.h` - HAL configuration

**We will:** Copy relevant functions, adapt to C++, integrate into our `system_init.cpp`

---

## Next Session Immediate Tasks

### PRIORITY 1: Install ARM GCC Toolchain ⏰ 15 min

**Current Status:** ⚠️ `arm-none-eabi-gcc: command not found`

**Action:**
1. Download: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
   - Version: 13.2.rel1 or later
   - Platform: Windows (mingw-w64-i686)
   - Architecture: arm-none-eabi

2. Install to: `C:\Program Files (x86)\Arm GNU Toolchain\`

3. Add to PATH:
   ```
   C:\Program Files (x86)\Arm GNU Toolchain\arm-none-eabi\bin
   ```

4. Verify:
   ```bash
   arm-none-eabi-gcc --version
   arm-none-eabi-g++ --version
   arm-none-eabi-size --version
   ```

**Why Critical:** Cannot build ARM binaries without this toolchain.

---

### PRIORITY 2: Generate System Init Code with STM32CubeMX ⏰ 30 min

**Goal:** Generate clock configuration and peripheral initialization code

**Steps:**

1. **Launch STM32CubeMX**
   - New Project → Board Selector
   - Search: "STM32H573I-DK"
   - Select: STM32H573I-DK board
   - Initialize all peripherals with default mode: **NO** (we'll add manually)

2. **Configure System Clock**
   - Pinout & Configuration → System Core → RCC
   - HSI: ON (64 MHz internal oscillator)
   - System Clock Mux: PLLCLK
   - PLL Source: HSI
   - PLL Configuration:
     - PLLM (divider): 4 (64 MHz / 4 = 16 MHz)
     - PLLN (multiplier): 125 (16 MHz × 125 = 2000 MHz)
     - PLLP (divider): 8 (2000 MHz / 8 = 250 MHz) ← **SYSCLK**
   - HCLK (AHB): 250 MHz (no division)
   - APB1/2/3 Prescaler: /1 (all 250 MHz)

3. **Configure UART4 (Debug Logging)**
   - Pinout & Configuration → Connectivity → UART4
   - Mode: Asynchronous
   - Baud Rate: 115200
   - Word Length: 8 Bits
   - Parity: None
   - Stop Bits: 1
   - Pins: PH13 (TX), PH14 (RX) - Board defaults

4. **Configure GPIO (Test Pin)**
   - Pinout & Configuration → System Core → GPIO
   - Find LED pin (check board schematic)
   - Set as GPIO_Output
   - Label: "LED_GREEN"

5. **Configure NVIC**
   - Pinout & Configuration → System Core → NVIC
   - Enable: UART4 global interrupt (priority 0)
   - Enable: EXTI line 2 interrupt (priority 0)

6. **Project Settings**
   - Project → Settings
   - Project Name: "CubeMX_Generated"
   - Project Location: `C:\GithubProjects\CRUST-y\CubeMX_Generated\`
   - Toolchain: Makefile
   - **DO NOT** use HAL libraries (we'll reference only)

7. **Generate Code**
   - Project → Generate Code
   - Open Project Folder

8. **Review Generated Files**
   ```
   CubeMX_Generated/
   ├── Core/
   │   ├── Src/
   │   │   ├── system_stm32h5xx.c   ← Clock init - COPY THIS
   │   │   ├── main.c               ← Peripheral init examples
   │   │   └── stm32h5xx_it.c       ← ISR handlers
   │   └── Inc/
   │       ├── stm32h5xx_hal_conf.h ← HAL config
   │       └── main.h
   └── Makefile                      ← Reference for compiler flags
   ```

**Deliverable:** `CubeMX_Generated/` folder with initialization code

---

### PRIORITY 3: Populate system_stm32h5xx.c with CubeMX Code ⏰ 45 min

**Status:** ✅ **File structure already created** (system_stm32h5xx.c/.h exist with FPU init)

**Goal:** Fill `SystemInit()` function with CubeMX-generated clock configuration

**File to Update:** `src/platform/system_stm32h5xx.c` (already exists as stub)

**What to Add (from CubeMX output):**

Open `CubeMX_Generated/Core/Src/system_stm32h5xx.c` and copy the clock configuration code from `SystemInit()` function into our existing `src/platform/system_stm32h5xx.c` file.

**Specifically, copy:**
1. Flash wait state configuration
2. PLL configuration registers (RCC->PLLCFGR, RCC->PLL1DIVR, etc.)
3. Power regulator voltage scaling settings
4. Clock source switching logic
5. SystemCoreClock update calculation

**Current File Structure (already exists):**
```c
// src/platform/system_stm32h5xx.c
void SystemInit(void)
{
    /* FPU settings (already done) */
    #if (__FPU_PRESENT == 1) && (__FPU_USED == 1)
        SCB->CPACR |= ((3UL << 10*2)|(3UL << 11*2));
    #endif

    /* TODO Phase 1: Add CubeMX clock config here */
    // 1. Configure Flash wait states
    // 2. Configure PLL (HSI → 250 MHz)
    // 3. Enable caches
    // 4. Configure voltage scaling
    // 5. Switch to PLL

    SystemCoreClock = 64000000;  // Update to 250000000 after config
}
```

**Steps:**
1. Open `CubeMX_Generated/Core/Src/system_stm32h5xx.c`
2. Copy clock configuration code (between FPU and end)
3. Paste into our `src/platform/system_stm32h5xx.c` at the TODO marker
4. Update `SystemCoreClock = 250000000;` at the end
5. Include ST CMSIS header: `#include "stm32h573xx.h"` at top

**Note:** Our file is C (not C++), so no namespaces needed. This matches ST's convention.

---

### PRIORITY 4: Update Makefile for ARM Target ⏰ 30 min

**Goal:** Support `make TARGET=arm` to build for STM32H573

**Key Changes:**

```makefile
# Target selection (new feature)
TARGET ?= windows

# Conditional toolchain configuration
ifeq ($(TARGET),windows)
    CXX := g++
    RUST_TARGET := x86_64-pc-windows-gnu
    CXXFLAGS := -std=c++17 -O2 -g -DWINDOWS_BUILD
    LDFLAGS := -lcrusty -lws2_32 -luserenv -lbcrypt -lntdll
endif

ifeq ($(TARGET),arm)
    # ARM Cortex-M33 toolchain
    CXX := arm-none-eabi-g++
    CC := arm-none-eabi-gcc
    OBJCOPY := arm-none-eabi-objcopy
    SIZE := arm-none-eabi-size

    # Rust target
    RUST_TARGET := thumbv8m.main-none-eabihf

    # ARM-specific flags
    CPU_FLAGS := -mcpu=cortex-m33 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard
    CXXFLAGS := -std=c++17 -O2 -g $(CPU_FLAGS) -fno-exceptions -fno-rtti

    # Include ST CMSIS headers
    ST_CMSIS := STM32CubeH5/Drivers/CMSIS
    INCLUDES += -I$(ST_CMSIS)/Device/ST/STM32H5xx/Include
    INCLUDES += -I$(ST_CMSIS)/Include

    # Linker flags
    LDFLAGS := -T stm32h573.ld \
               -Wl,--gc-sections \
               -specs=nosys.specs \
               $(CPU_FLAGS)

    # Add startup code
    OBJS += $(BUILD_DIR)/startup.o
endif

# Update Rust build to use correct target
rust:
    cd $(RUST_DIR) && cargo build --release --target $(RUST_TARGET)
    # Update CXX bridge paths for selected target
```

**New Build Targets:**

```makefile
# Generate .bin file for flashing
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
    $(OBJCOPY) -O binary $< $@

# Print size info
size: $(BUILD_DIR)/crusty_firmware.elf
    $(SIZE) $<

# Flash to board (requires STM32CubeProgrammer)
flash: $(BUILD_DIR)/crusty_firmware.bin
    STM32_Programmer_CLI -c port=SWD -w $< 0x08000000 -rst
```

---

### PRIORITY 5: Update Platform Layer ⏰ 20 min

**Goal:** Use ST's official register definitions

**Update:** `include/crusty/platform/stm32h573.h`

```cpp
#ifndef CRUSTY_PLATFORM_STM32H573_H
#define CRUSTY_PLATFORM_STM32H573_H

// Include ST's official CMSIS device header
#include "stm32h573xx.h"

namespace crusty {
namespace platform {

// Our abstractions wrap ST definitions
// All base addresses come from stm32h573xx.h

// Example: UART4 uses ST's definition
constexpr uintptr_t UART4_BASE_ADDR = UART4_BASE;  // From stm32h573xx.h

// RCC (Reset and Clock Control) - already defined by ST
// GPIO ports - already defined by ST
// NVIC - already defined by ST

// CFPGA simulation - our custom definition
constexpr uint8_t CFPGA_IRQ = EXTI2_IRQn;  // Use EXTI2 for simulation

} // namespace platform
} // namespace crusty

#endif
```

**Benefit:** All register addresses verified by ST, no manual errors

---

## Phase 1 Success Criteria

At the end of next session, we should have:

- [ ] ARM GCC toolchain installed and verified
- [ ] STM32CubeMX generated clock configuration code
- [ ] `system_init.cpp` created with clock/RCC initialization
- [ ] Makefile supports `TARGET=arm` builds
- [ ] Platform layer includes ST CMSIS headers
- [ ] ARM build compiles without errors
- [ ] Binary size verified (<2MB Flash, <640KB RAM)

---

## Testing Plan (After Phase 1)

### Windows Development Build (Still Works)
```bash
make clean
make TARGET=windows
./build/crusty_firmware.exe
# Expected: Console output, no crashes
```

### ARM Build (New)
```bash
make clean
make TARGET=arm
arm-none-eabi-size build/crusty_firmware.elf
# Expected: Successful compile, size < 2MB Flash
```

---

## File Locations Reference

### Existing Files (Working)
```
rust/
├── src/
│   ├── lib.rs                     ✅ CXX bridge
│   └── validation.rs              ✅ Memory-safe validation
└── .cargo/config.toml             ✅ ARM target configured

include/crusty/
├── platform/
│   ├── stm32h573.h                ⏳ Update to include ST headers
│   ├── memory_map.h               ✅ Memory layout
│   └── types.h                    ✅ Common types
├── hal/
│   ├── mmio.h                     ✅ Conditional Windows/ARM
│   ├── gpio.h/cpp                 ✅ Ready
│   ├── uart.h/cpp                 ✅ Needs hardware enable
│   └── nvic.h/cpp                 ✅ Ready
├── devices/
│   └── device_base.h              ✅ Base class
├── spinterfaces/
│   └── logging.h/cpp              ✅ Ready
└── components/
    └── control.h/cpp              ✅ Ready

src/
└── main.cpp                       ✅ Ready (conditional compile)
```

### New Files (To Create)
```
src/platform/
└── system_init.cpp                ⏳ TODO - From CubeMX

include/crusty/platform/
└── system_init.h                  ⏳ TODO - API declaration

CubeMX_Generated/                  ⏳ TODO - STM32CubeMX output
└── Core/Src/system_stm32h5xx.c   ⏳ TODO - Reference for our code

stm32h573.ld                       ✅ DONE
startup.s                          ✅ DONE
```

---

## Documentation Updates

### New Documents Created This Session

1. **`Documentation/STM32_MIGRATION_PLAN.md`** ✅
   - Comprehensive hybrid approach strategy
   - Phase-by-phase implementation guide
   - All tool download links
   - Risk mitigation strategies

2. **`Documentation/NEXT_SESSION.md`** ✅ (This file)
   - Updated with hybrid approach
   - Immediate action items
   - STM32CubeMX configuration steps

### Documents to Update Next Session

- [ ] `Documentation/DesignLog.md` - Add Phase 1 entries
- [ ] `Documentation/ARCHITECTURE.md` - Update with ST integration details
- [ ] `README.md` - Add ARM build instructions

---

## Key Design Decisions

### Why Hybrid Approach?

| Aspect | Full Custom | Hybrid with ST | Winner |
|--------|-------------|----------------|--------|
| Clock Setup | Manual PLL calculation | CubeMX generates | ✅ Hybrid |
| Register Definitions | Copy from PDF | Use stm32h573xx.h | ✅ Hybrid |
| Error Risk | High (typos, wrong addresses) | Low (ST-verified) | ✅ Hybrid |
| Development Speed | Slow (research each register) | Fast (examples available) | ✅ Hybrid |
| Flexibility | Full control | Full control + correct defaults | ✅ Hybrid |
| Portability | Tied to our code | Easy to port (ST abstraction) | ✅ Hybrid |

**Decision:** Use ST's code where it makes sense, wrap it in our API for consistency.

### What We Keep Custom

- ✅ **5-layer architecture** - Our design philosophy
- ✅ **Rust validation** - Our safety-critical functions
- ✅ **Build system** - Our Makefile (not HAL ecosystem)
- ✅ **API design** - Our function signatures and namespaces
- ✅ **CFPGA FIFO** - Our device-specific code

### What We Adopt from ST

- ✅ **Register definitions** - `stm32h573xx.h` (correct by design)
- ✅ **Clock configuration** - CubeMX-generated (eliminates calculation errors)
- ✅ **Examples as reference** - Verify our implementations match ST's approach

---

## Troubleshooting Guide

### If ARM build fails with "arm-none-eabi-gcc: command not found"
- ✅ Install ARM GCC toolchain (Priority 1)
- ✅ Add to PATH
- ✅ Restart terminal/IDE

### If Rust ARM build fails
- ✅ Verify target installed: `rustup target list --installed`
- ✅ Should see: `thumbv8m.main-none-eabihf`
- ✅ Check `.cargo/config.toml` has ARM target settings

### If linker fails with "undefined reference to _estack"
- ✅ Verify `stm32h573.ld` is in project root
- ✅ Check Makefile has `-T stm32h573.ld` in LDFLAGS

### If binary is too large (>2MB)
- ✅ Check optimization: Should be `-O2` or `-Os`
- ✅ Use `arm-none-eabi-size` to see section sizes
- ✅ Verify `--gc-sections` removes unused code

---

## Next Session Start Checklist

Before coding, verify:

- [ ] ARM GCC installed: `arm-none-eabi-gcc --version` works
- [ ] Rust ARM target: `rustup target list | grep thumbv8m`
- [ ] STM32CubeMX installed and launches
- [ ] ST CMSIS headers exist: `STM32CubeH5/Drivers/CMSIS/`
- [ ] Current Windows build still works: `make clean && make`

---

## Estimated Timeline

| Task | Estimated Time | Priority |
|------|----------------|----------|
| Install ARM GCC | 15 min | P1 |
| Run STM32CubeMX | 30 min | P1 |
| Create system_init.cpp | 45 min | P1 |
| Update Makefile | 30 min | P1 |
| Update platform layer | 20 min | P2 |
| First ARM build attempt | 20 min | P2 |
| Debug build issues | 30 min | P2 |
| **Total** | **~3 hours** | |

---

## References

- **Migration Plan:** `Documentation/STM32_MIGRATION_PLAN.md`
- **Design Log:** `Documentation/DesignLog.md`
- **STM32CubeH5 Manual:** `STM32CubeH5/Documentations/UM3065.pdf`
- **STM32H573 Datasheet:** https://www.st.com/resource/en/datasheet/stm32h573ii.pdf
- **ARM GCC Download:** https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
- **STM32CubeMX:** https://www.st.com/en/development-tools/stm32cubemx.html

---

*Last Updated: October 30, 2025*
*Ready for Phase 1: System Initialization with Hybrid Approach*
