# CRUST-y Design Log

## Architecture: C++ Infrastructure + Rust Safety Functions

**C++ owns**: All 5 layers, main application, simulated CFPGA, interrupt handling
**Rust implements**: Phase 1 safety-critical functions called by C++ via CXX bridge

---

## Layer Structure

```
Layer 5: Components      → Application logic (control.cpp)
Layer 4: SpInterfaces    → APIs between components (logging)
Layer 3: Devices         → Device abstractions (CFPGA FIFO - TBD)
Layer 2: HAL             → Hardware drivers (NVIC, GPIO, UART, MMIO)
Layer 1: LowLevelPlatform → Memory map, register definitions
```

---

## Implementation Status

### ✅ Step 1: C++ Infrastructure (Complete)
**What**: All 5 layers implemented
**Key Files**:
- Layer 1: `include/crusty/platform/` (memory_map.h, stm32h573.h, types.h)
- Layer 2: `include/crusty/hal/` (mmio.h, nvic, gpio, uart)
- Layer 3: `include/crusty/devices/` (device_base.h)
- Layer 4: `include/crusty/spinterfaces/` (logging)
- Layer 5: `include/crusty/components/` (control)
- Main: `src/main.cpp`
- Build: `Makefile` (Windows MinGW)

**Memory Safety Features**:
- Bounds checking via `MemoryRegion::contains()`
- Volatile MMIO access
- Strong typing (Status, PinMode enums)
- No dynamic allocation

### ✅ Phase 0: CXX Bridge Foundation (Complete - READY FOR TESTING)
**What**: Established CXX bridge infrastructure for C++/Rust FFI with conditional compilation
**Critical Requirement**: CXX generates C++ headers that integration code depends on

**Implemented**:
- ✅ Configured Rust Cargo.toml with conditional compilation for std vs no_std
- ✅ Created build.rs for CXX code generation
- ✅ Defined CXX bridge with shared data structures (ControlMessage, ValidationResult)
- ✅ Implemented conditional allocator (std for Windows, embedded-alloc for baremetal)
- ✅ CXX bridge defines validation function signatures
- ✅ Updated Makefile with proper build order: Rust → C++ → Link
- ✅ Rust validation functions fully implemented with unit tests
- ✅ Zero unsafe blocks in validation logic (memory-safe)

**Key Architectural Decision: Conditional Compilation Strategy**

Based on research findings (CXX has limited no_std support), implemented hybrid approach:

**Windows Development (default "std-test" feature)**:
- Uses full std library for testing/development
- CXX works reliably with std
- Normal allocator and panic handler from std
- Build command: `cargo build --release` (default)
- **Purpose**: Validate FFI architecture and test integration on dev machine

**STM32 Baremetal (optional "baremetal" feature)**:
- Uses no_std with embedded-alloc
- Custom panic handler and allocator
- Build command: `cargo build --release --no-default-features --features baremetal`
- **Purpose**: Production deployment to hardware

**Why This Approach**:
1. Unblocks immediate testing on Windows
2. Proves C++/Rust FFI architecture works
3. Captures CXX no_std limitations as lesson learned
4. Provides fallback: if CXX incompatible with baremetal, validation logic remains unchanged (only FFI mechanism changes)

**Files Created/Modified**:
- ✅ `Rust/Cargo.toml` - Conditional features (std-test default, baremetal optional)
- ✅ `Rust/.cargo/config.toml` - MinGW (GNU) target configuration
- ✅ `Rust/build.rs` - CXX build configuration with C++17 flags
- ✅ `Rust/src/lib.rs` - Conditional compilation for std/no_std, full validation implementation
- ✅ `Makefile` - Full CXX integration with MinGW target paths
- ✅ `src/main.cpp` - Success message and console pause for testing
- ✅ `src/hal/nvic.cpp` - Conditional ARM assembly for Windows simulation

**Current Status**: 95% complete - CXX header path issue with MinGW target (see [NEXT_SESSION.md](../NEXT_SESSION.md))

**Known Issue**: CXX headers generated in target-specific path
- Expected: `Rust/target/cxxbridge/crusty-firmware/src/lib.rs.h`
- Actual: `Rust/target/x86_64-pc-windows-gnu/cxxbridge/crusty-firmware/src/lib.rs.h`
- Cause: Custom Rust target in `.cargo/config.toml` changes output directory structure
- Fix: Update Makefile `CXX_BRIDGE_DIR` to: `$(RUST_DIR)/target/x86_64-pc-windows-gnu/cxxbridge/crusty-firmware/src`

**Next Action**: Fix CXX header path in Makefile (line 28), then execute Phase 0 Test Plan

### ⏳ Phase 1: Simulated CFPGA FIFO (After Phase 0)
**What**: Software FIFO in C++ that triggers interrupts and outputs CXX-compatible data
**Design Constraint**: FIFO must work with CXX-defined shared structs

**To Implement**:
- Circular buffer FIFO in Layer 3 with fixed-size buffers
- Interrupt generation mechanism (threshold-based)
- ISR that reads FIFO and formats data for CXX bridge types
- Integration with Control component event handling

**Files to Create**:
- `include/crusty/devices/cfpga_fifo.h`
- `src/devices/cfpga_fifo.cpp`

### ⏳ Phase 2: Rust Safety Functions (After Phase 0)
**What**: Rust validation functions callable from C++ via CXX bridge
**Safety Goal**: Zero unsafe blocks in validation logic, leverage Rust type system

**To Implement**:
- Control message validation (checksum, bounds, command ID)
- Status data validation before FIFO writes
- Memory-safe processing using no_std Rust primitives
- Return structured validation results to C++

**Files to Create**:
- `Rust/src/control_handler.rs`
- `Rust/src/status_handler.rs`
- Implement functions defined in CXX bridge

### ⏳ Phase 3: Integration & Testing (After Phases 0, 1, 2)
**What**: Connect all components for end-to-end data flow
**To Integrate**:
- Update Control component to include CXX-generated headers
- Add Rust validation calls in C++ event handling path
- Test complete flow: FIFO write → interrupt → Rust validate → C++ execute
- Update documentation with architecture and lessons learned

---

## Phase 1 Data Flow (Target Design with CXX Bridge)

```
CXX Bridge Setup (Phase 0):
├─ Rust: Define #[cxx::bridge] with shared structs (ControlMessage, ValidationResult)
├─ CXX: Generates lib.rs.h and lib.rs.cc
└─ C++: Includes generated headers for type-safe FFI

Control Flow:
1. C++ CFPGA FIFO receives data → threshold reached
2. C++ FIFO triggers interrupt
3. C++ ISR catches interrupt
4. C++ ISR reads FIFO into CXX-defined ControlMessage struct
5. C++ calls Rust via CXX bridge: validate_control_message(msg)
6. Rust validates with memory safety (no_std, zero unsafe)
7. Rust returns ValidationResult struct via CXX bridge
8. C++ checks ValidationResult, executes command if valid
9. C++ prepares status response
10. C++ calls Rust: validate_status_data(buffer)
11. C++ writes validated status to FIFO
```

**CXX Bridge Role**:
- Defines shared data structures visible to both languages
- Generates type-safe C++ headers for Rust functions
- Handles ABI compatibility automatically
- Provides zero-overhead FFI with compile-time safety

---

## Key Design Decisions

**Why C++ infrastructure?**
Per CRUSTyOverview.md: C++ is main system. Rust only handles Phase 1 externally-facing interfaces and control/status bypass functions.

**Why layered architecture?**
Matches existing TaISR codebase structure (Layers 1-5) for eventual production migration.

**Why CXX bridge?**
Provides compile-time type safety across FFI boundary. No raw pointers, ABI mismatch protection. CXX generates C++ headers automatically, ensuring both sides agree on signatures.

**Why CXX-first approach (Phase 0 before FIFO)?**
- CXX generates C++ headers that integration code must #include
- Shared data structures defined in bridge drive C++ and Rust implementations
- Retrofitting CXX after writing manual FFI requires major refactoring
- Type safety only works if both sides built around CXX from start
- Build system dependencies: Rust must compile before C++ (to generate headers)

**Why conditional compilation (std vs no_std)?**
- CXX has limited no_std support (research finding from 2025 docs)
- Windows development uses std: reliable CXX, easier debugging, faster iteration
- Baremetal STM32 uses no_std: production deployment requirements
- Both compiled on dev machine, just different targets/features
- Validation logic identical (zero unsafe blocks) in both modes
- Provides fallback path if CXX no_std proves incompatible for production

**Baremetal configuration (when needed)**:
- STM32 has 640KB RAM, sufficient for embedded-alloc (64KB heap)
- Fixed-size arrays and slices preferred over Vec/String in hot paths
- Custom panic handler halts on error (production would log first)
- Target: thumbv8m.main-none-eabi (ARM Cortex-M33)

**Why simulated CFPGA?**
Lab doesn't have Xilinx FPGA. Software FIFO mimics hardware for prototype testing.

**Memory constraints**:
2MB Flash (STM32U5A5 production target), 640KB RAM (STM32H573I dev board)

---

## Build Commands

```bash
make clean      # Clean build artifacts (C++ and Rust)
make cpp        # Build C++ only (Step 1 - before CXX integration)
make rust       # Build Rust with CXX bridge (Phase 0+)
                # Generates: lib.rs.h, lib.rs.cc, libcrusty.a
make all        # Build everything (Phase 0+)
                # Order: Rust first (generate headers), then C++ (include headers)
make run        # Run executable
```

**Build Flow with CXX (Phase 0+)**:
1. `cargo build --release` in Rust/ → Generates CXX headers and Rust staticlib
2. Compile CXX-generated C++ code (lib.rs.cc)
3. Compile C++ source files (include CXX headers from target/cxxbridge/)
4. Link C++ objects with Rust staticlib

---

## File Structure

```
include/crusty/           → C++ headers (5 layers)
src/                      → C++ implementation
Rust/src/lib.rs          → CXX bridge definition (#[cxx::bridge])
Rust/src/*.rs            → Rust validation implementations
Rust/build.rs            → CXX code generation configuration
Rust/target/cxxbridge/   → Generated CXX headers (lib.rs.h, lib.rs.cc)
Rust/target/release/     → Rust staticlib (libcrusty.a)
Makefile                 → Build orchestration (Rust → C++ → Link)
Documentation/           → CRUSTyOverview.md, cxx.md, DesignLog.md, CLAUDE.md
```

**CXX-Generated Files** (auto-generated, do not edit manually):
- `Rust/target/cxxbridge/crusty/src/lib.rs.h` - C++ header with Rust function declarations
- `Rust/target/cxxbridge/crusty/src/lib.rs.cc` - C++ FFI implementation
- C++ code includes: `#include "crusty/src/lib.rs.h"`

---

## Next Actions

**Current**: Phase 0 - CXX Bridge Foundation
**Immediate Goals**:
- Update Rust/Cargo.toml for no_std + alloc configuration
- Create Rust/build.rs for CXX code generation
- Define CXX bridge in Rust/src/lib.rs with shared structs
- Implement baremetal allocator
- Verify CXX header generation
- Update Makefile for CXX build integration

**Subsequent Phases**:
- Phase 1: CFPGA FIFO using CXX-defined data structures
- Phase 2: Rust validation functions implementing bridge interface
- Phase 3: End-to-end integration and testing

**Critical Dependencies**:
- Phase 1 and 2 both depend on Phase 0 (require CXX headers)
- C++ compilation depends on Rust build completing (header generation)
- Phases 1 and 2 can proceed in parallel after Phase 0 complete

---

## Lessons Learned

### Lesson 1: CXX no_std Support is Limited (Phase 0)

**Finding**: Research of 2025 documentation revealed CXX has incomplete no_std support
- CXX with std library: ✅ Mature, widely tested, reliable
- CXX with no_std: ⚠️ Experimental, dependency issues (e.g., link_cplusplus requires std)

**Impact on Project**:
- Cannot rely solely on CXX for baremetal production builds
- Conditional compilation required for development vs production

**Solution Implemented**:
- **Development path** (Windows): Use std with CXX for testing/validation
- **Production path** (STM32): Prepared for potential fallback to raw FFI with safety wrappers
- Validation logic (pure Rust) independent of FFI mechanism

**Recommendation for Production Migration**:
1. Test CXX with `--no-default-features --features baremetal` on ARM target
2. If CXX no_std issues arise, implement raw FFI using same data structures
3. Validation functions remain unchanged (already memory-safe, zero unsafe blocks)
4. Only FFI boundary layer needs replacement

**Value**: This prototype validates the architecture and captures real-world CXX limitations for documentation

---

### Lesson 2: Rust Target Configuration Affects CXX Output Paths (Phase 0)

**Finding**: Custom Rust targets change CXX cxxbridge output directory structure

**Issue Encountered**:
- Default Rust target (auto-detected): Headers in `target/cxxbridge/`
- Custom target (`.cargo/config.toml`): Headers in `target/<target-name>/cxxbridge/`
- Makefile include paths must be updated to match

**Specific Case**:
- Configured: `target = "x86_64-pc-windows-gnu"` to match MinGW C++ toolchain
- CXX headers moved from `target/cxxbridge/` to `target/x86_64-pc-windows-gnu/cxxbridge/`
- Build failed: "No rule to make target 'Rust/target/cxxbridge/.../lib.rs.h'"

**Solution**:
Update Makefile to include target directory in CXX header paths:
```makefile
CXX_BRIDGE_DIR := $(RUST_DIR)/target/x86_64-pc-windows-gnu/cxxbridge/crusty-firmware/src
```

**Recommendation for Production Migration**:
- Document Rust target in Makefile comments clearly
- For ARM production: Will need to update to `thumbv8m.main-none-eabi` target
- Consider dynamic path detection: `$(shell find $(RUST_DIR)/target -path "*/cxxbridge/*/src" -print -quit)`

**Value**: Critical awareness for production ARM builds - same issue will occur

---

### Lesson 3: Toolchain Matching Between Rust and C++ (Phase 0)

**Finding**: Rust and C++ toolchains must match for successful linking

**Issue Encountered**:
- Rust defaulted to MSVC toolchain (x86_64-pc-windows-msvc)
- C++ using MinGW/GCC toolchain (g++)
- Linking error: `undefined reference to '__chkstk'` (MSVC-specific runtime function)
- MinGW linker doesn't provide MSVC runtime functions

**Why It Matters**:
- Different toolchains have different ABIs and runtime libraries
- MSVC uses `__chkstk` for stack probing
- MinGW/GCC uses different stack management

**Solution Implemented**:
1. Created `Rust/.cargo/config.toml` with `target = "x86_64-pc-windows-gnu"`
2. Forces Rust to compile for MinGW (GNU) target
3. Generates MinGW-compatible `libcrusty.a` instead of MSVC `crusty.lib`
4. Both Rust and C++ now use compatible ABIs

**Alternative Considered**:
- Adding `-lgcc` to linker flags (provides some MSVC compatibility)
- Rejected: Workaround, not proper fix; better to match toolchains

**Recommendation for Production Migration**:
- ARM production will use `arm-none-eabi-gcc` for C++
- Rust must target `thumbv8m.main-none-eabi` to match
- Both use embedded-GCC ABI - consistent toolchain family

**Value**: Ensures clean linking without runtime dependency mismatches

---

## References

- [CRUSTyOverview.md](CRUSTyOverview.md) - Project requirements
- [cxx.md](cxx.md) - CXX FFI library reference
- [TestValidationPlans.md](TestValidationPlans.md) - Manual test procedures
