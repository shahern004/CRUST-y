# Next Session: Quick Start

> **STM32-Only Branch Note**: This branch is baremetal-only for ARM Cortex-M33. See [STM32_MIGRATION_PLAN.md](STM32_MIGRATION_PLAN.md) for comprehensive migration strategy.

**Current Phase:** Phase 1 - System Initialization
**Last Updated:** November 12, 2025

---

## Immediate Blockers

### ✅ RESOLVED: ARM GCC Toolchain
- Status: Installed and verified working
- Command: `arm-none-eabi-gcc --version`

### ⚠️ BLOCKED: System Clock Configuration
- **Action Required:** Generate clock init code with STM32CubeMX
- **File:** `src/platform/system_stm32h5xx.c` has stub waiting for CubeMX output
- **Target:** HSI (64 MHz) → PLL → 250 MHz SYSCLK

---

## Priority Tasks (Next Session)

### Priority 1: Generate Clock Configuration (45 min)

**Use STM32CubeMX to generate system initialization:**

1. Launch STM32CubeMX → New Project → Board: STM32H573I-DK
2. Configure clock tree:
   - HSI: 64 MHz (internal oscillator)
   - PLL: Target 250 MHz SYSCLK
   - Generate code → Toolchain: Makefile
3. Copy clock setup from generated `system_stm32h5xx.c` into our file at line 79
4. Update `SystemCoreClock = 250000000;`

**Deliverable:** Working clock configuration in `src/platform/system_stm32h5xx.c`

---

### Priority 2: Integrate ST CMSIS Headers (20 min)

**Update platform layer to use official ST register definitions:**

**File:** `include/crustyV2/platform/stm32h573.h`

Add include:
```cpp
#include "stm32h573xx.h"  // ST official definitions
```

**Makefile update:**
Add ST CMSIS include paths:
```makefile
INCLUDES += -I STM32CubeH5/Drivers/CMSIS/Device/ST/STM32H5xx/Include
INCLUDES += -I STM32CubeH5/Drivers/CMSIS/Include
```

---

### Priority 3: First ARM Build (30 min)

**Attempt first ARM Cortex-M33 build:**

```bash
make clean
make
arm-none-eabi-size build/crustyV2_firmware.elf
```

**Expected:**
- Successful compilation
- Binary size < 2MB Flash, < 640KB RAM
- No linker errors

**If build fails:** Debug based on error messages (likely include paths or linker script issues)

---

## Quick Verification Checklist

Before starting:
- [x] ARM GCC installed: `arm-none-eabi-gcc --version`
- [ ] STM32CubeMX installed and launches
- [ ] ST CMSIS headers exist: `STM32CubeH5/Drivers/CMSIS/`
- [ ] Rust ARM target: `rustup target list | grep thumbv8m`

---

## File Locations Quick Reference

**To modify:**
- `src/platform/system_stm32h5xx.c` - Add CubeMX clock config at line 79
- `include/crustyV2/platform/stm32h573.h` - Add ST CMSIS include
- `Makefile` - Add ST include paths

**To reference:**
- `CubeMX_Generated/Core/Src/system_stm32h5xx.c` - Clock config source
- `STM32CubeH5/Drivers/CMSIS/Device/ST/STM32H5xx/Include/stm32h573xx.h` - Register defs

---

## Success Criteria

End of session should have:
- [ ] Clock configuration generated and integrated
- [ ] ST CMSIS headers included in build
- [ ] ARM build compiles without errors
- [ ] Binary size verified and reasonable

---

## Troubleshooting Quick Reference

**"arm-none-eabi-gcc: command not found"**
→ Add to PATH: `C:\Program Files (x86)\Arm GNU Toolchain\arm-none-eabi\bin`

**"stm32h573xx.h: No such file or directory"**
→ Check Makefile INCLUDES has STM32CubeH5 CMSIS paths

**"undefined reference to _estack"**
→ Verify linker script: `-T stm32h573.ld` in LDFLAGS

**Binary too large (>2MB)**
→ Check optimization: should be `-O2` or `-Os`, verify `--gc-sections`

---

## Next Phase Preview

**After Phase 1 Complete:**
- Phase 2: UART4 initialization for debug logging
- Phase 2: CFPGA FIFO implementation (interrupt-driven)
- Phase 2: End-to-end Rust validation integration test

---

## References

- **Comprehensive Guide:** [STM32_MIGRATION_PLAN.md](STM32_MIGRATION_PLAN.md)
- **Architecture:** [CRUSTyOverview.md](CRUSTyOverview.md)
- **Design History:** [DesignLog.md](DesignLog.md)
