# CRUST-y System Architecture

> **Branch Note**: This is the STM32 embedded development branch. A separate Windows development branch exists for rapid prototyping and testing.

## Project Purpose

CRUST-y is a hybrid C++/Rust embedded firmware architecture designed to meet NSA Memory-Safe-Language requirements through a phased transition approach. **Memory safety is the primary objective.**

The system targets baremetal STM32 microcontrollers and integrates Rust's memory safety guarantees into a legacy-compatible C++ architecture.

---

## Target Hardware

**Production Target:**
- Security Processor: STM32U5A5 (2MB Flash)
- Cryptographic Processor: Xilinx Kintex UltraScale+ KU5P FPGA

**Development Target:**
- Security Processor: STM32H573I-DK (mimics STM32U5A5 constraints)
- FPGA: Software simulation (CFPGA FIFO) - no physical hardware available

---

## Architecture Design

CRUST-y employs a **layered hybrid architecture** combining a traditional 5-layer C++ design with a cross-cutting Rust safety layer for critical validation operations.

### Layer 5: Components

**Purpose:** High-level application logic and orchestration

**Responsibilities:**
- Control flow management
- Non-volatile memory management
- Cryptographic configuration
- Key management operations

**Implementation:** C++ with Rust safety function calls via FFI

---

### Layer 4: SpInterfaces

**Purpose:** Inter-component and component-to-device communication APIs

**Responsibilities:**
- Logging infrastructure
- Communication protocols between components
- Service interfaces for cross-cutting concerns

**Implementation:** C++

---

### Layer 3: Devices

**Purpose:** Device abstractions grouping HAL primitives into cohesive interfaces

**Responsibilities:**
- Command channel interfaces (RSS)
- CFPGA FIFO management (simulated FPGA interface)
- Real-time clock abstraction
- Security peripheral abstractions

**Implementation:** C++

---

### Layer 2: Hardware Abstraction Layer (HAL)

**Purpose:** Hardware-agnostic device drivers

**Responsibilities:**
- Memory-mapped I/O operations (MMIO)
- General-purpose I/O (GPIO)
- UART communication
- Nested Vectored Interrupt Controller (NVIC)

**Implementation:** C++ (wraps ST CMSIS register definitions)

---

### Layer 1: Platform

**Purpose:** Hardware-specific definitions and system initialization

**Responsibilities:**
- Processor register definitions
- Memory map layout
- Peripheral base addresses
- Clock and power configuration
- System initialization sequence

**Implementation:** C (system init), C++ (platform abstractions)

**Dependencies:** STM32CubeH5 CMSIS device headers

---

## Rust Safety Layer (Cross-Cutting)

**Purpose:** Memory-safe validation for externally-facing interfaces

The Rust safety layer provides compile-time memory safety guarantees for critical validation operations without runtime overhead.

**Key Characteristics:**
- **Zero Unsafe Code:** All validation logic uses safe Rust (no `unsafe` blocks)
- **Bare-Metal Compatible:** Built with `no_std` and embedded allocator
- **Type-Safe FFI:** CXX bridge provides compile-time type checking across language boundary
- **Static Linking:** Compiles to static library linked with C++ firmware

**Responsibilities:**
- Control message validation (checksums, bounds checking, command verification)
- Status data validation before FPGA communication
- External interface input sanitization

**Integration:** C++ calls Rust functions via CXX-generated FFI shims with zero-overhead abstraction

---

## Hybrid Approach with ST Ecosystem

CRUST-y integrates official STMicroelectronics tools while maintaining architectural independence:

**From ST:**
- CMSIS register definitions (hardware accuracy)
- STM32CubeMX-generated clock configuration (correct-by-design)
- HAL driver examples (reference implementations)

**From CRUST-y:**
- 5-layer architecture (organizational structure)
- Rust safety validation (memory safety)
- Custom build system (Makefile-based, no CMake/HAL dependencies)
- API design philosophy (type safety, namespace organization)

**Benefit:** Combines ST's hardware expertise with CRUST-y's memory-safe architecture

---

## Memory Safety Strategy

CRUST-y achieves memory safety through a **phased priority approach**:

1. **Phase 1:** Externally-facing interfaces (control messages, status validation) → Rust
2. **Phase 2:** Internal high-risk components → Rust
3. **Phase 3:** Remaining C++ infrastructure → Rust
4. **Phase 4:** Full Rust firmware

This approach prioritizes attack surfaces and critical paths while maintaining legacy compatibility during transition.

---

## Build System

**Toolchain:**
- C++ Compiler: ARM GCC (`arm-none-eabi-gcc`) for Cortex-M33
- Rust Compiler: Target `thumbv8m.main-none-eabihf` (hardware FPU)
- FFI Bridge: CXX (compile-time type-safe C++/Rust interop)
- Code Generation: STM32CubeMX (system initialization)

**Build Process:**
1. Rust compilation → static library + CXX-generated C++ headers
2. C++ compilation (includes CXX headers)
3. Linking (C++ objects + Rust static library)
4. Binary generation (ELF → BIN for flashing)

**Output:** Single bare-metal firmware binary for STM32H573I-DK

---

## System Initialization Flow

1. **Reset Vector** → Startup assembly code
2. **Startup Assembly** → Stack/heap initialization, data/bss sections, vector table setup
3. **SystemInit()** → Clock configuration (HSI→PLL 250MHz), FPU enable, cache enable
4. **main()** → C++ application entry point
5. **Component Initialization** → Layer-by-layer device bring-up
6. **Main Loop** → Interrupt-driven operation with Rust validation

---

## Interrupt Architecture

**NVIC Configuration:**
- UART4 interrupt (debug logging)
- EXTI2 interrupt (simulated CFPGA FIFO threshold)
- Configurable priorities (0-15, lower = higher priority)

**Interrupt Flow:**
1. Hardware event triggers NVIC
2. C++ ISR handler executes
3. ISR calls Rust validation function via CXX bridge
4. Rust validates data with memory safety guarantees
5. ISR processes validated data
6. Return from interrupt

**Safety:** Rust validation prevents buffer overflows, out-of-bounds access, and invalid data propagation

---

## CFPGA FIFO Simulation

The simulated FPGA interface mimics hardware behavior for prototype development:

**Design:**
- Circular buffer (512 bytes)
- Threshold-based interrupt generation (EXTI2)
- Bidirectional communication (control commands in, status data out)

**Integration:**
- C++ manages FIFO operations
- Rust validates all external data entering/leaving FIFO
- ISR-driven for realistic timing behavior

---

## Memory Budget

**STM32H573I-DK Constraints:**
- Flash: 2MB (code + constants)
- RAM: 640KB (stack + heap + BSS)

**Allocation Strategy:**
- C++ firmware: Stack-allocated structures, minimal dynamic allocation
- Rust safety layer: 64KB heap via `embedded-alloc`, prefer fixed-size arrays
- Linker script enforces memory boundaries with compile-time checks

---

## References

**Internal Documentation:**
- Development plan: `STM32_MIGRATION_PLAN.md`
- Design decisions: `DesignLog.md`
- Session notes: `NEXT_SESSION.md`

**External Standards:**
- NSA Memory-Safe Languages guidance
- MISRA C++ 2023 (automotive safety)
- ARM Cortex-M33 Technical Reference Manual
- STM32H573 Reference Manual (RM0481)
