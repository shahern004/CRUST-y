# CRUST-y System Overview

This project is to develop CRUST-y architecture as a proof-of-concept in a prototype environment. The output of this project is to create and test a baremetal application with the ULTIMATE GOAL of creating documentation on feasibility and lessons-learned with CRUST-y for adoption on the actual dev environment.

## Project Purpose

CRUST-y is a hybrid C++/Rust project that aims to meet NSA Memory-Safe-Language requirements using a prioritized, phased approach to ensure smooth and manageable transition from Pure C++ legacy codebases to pure Rust.
**MEMORY SAFETY IS THE UTMOST PRIORITY AND THE PURPOSE OF THIS PROJECT**

## Hardware

- Security Processor: STM32U5A5
  - 2MB Flash NVM
  - For this project, we will use an STM32H573I-DK to mimic STM32U5A5 functionality and constraints.
- FPGA (Cryptographic Processor): Xilinx Kintex UltraScale+ KU5P
  - For this project, we will create a software abstraction of FPGA functionality (CFPGA FIFO). We do not have physical FPGA hardware in this lab.

## Software Development

### Prototype Dev Environment

- OS: Windows 11
- IDE: VSCode
- Development Strategy: Dual-target build system (Windows simulation for development, ARM for hardware deployment)

### CRUST-y Software Tooling

- **CXX Bridge**: C++/Rust FFI bridge with compile-time type safety
- **C++ Compiler (Windows)**: MinGW G++ (for development builds)
- **C++ Compiler (ARM)**: ARM GCC (`arm-none-eabi-gcc`) for STM32H573
- **Rust Compiler**:
  - Windows target: `x86_64-pc-windows-gnu`
  - ARM target: `thumbv8m.main-none-eabihf` (Cortex-M33 with hardware FPU)
- **STM32CubeMX**: System initialization code generator (hybrid approach)
- **STM32CubeH5**: Official ST HAL drivers and register definitions
- **STM32CubeProgrammer**: Firmware flashing and debugging
- **Target System**: Bare-Metal STM32H573I-DK (adhering to STM32U5A5 constraints)
- **Build System**: Manual Makefiles with conditional compilation (No CMAKE)

### Development Phases

**Phase 0: CXX Bridge Foundation (✅ COMPLETE)**

- Establish CXX bridge for C++/Rust interoperability with compile-time type safety
- CXX generates C++ headers that integration code depends on - foundational architectural component
- Implement Rust safety layer with memory-safe validation functions (zero unsafe blocks)
- Create dual-target build system (Windows development + ARM production)
- Implement conditional compilation for Windows simulation vs STM32 hardware
- **Status**: Rust library builds successfully (std and no_std modes), CXX bridge generates FFI bindings, C++ successfully calls Rust functions

**Phase 1: System Initialization (🔄 IN PROGRESS)**

- Install ARM GCC toolchain for Cortex-M33 compilation
- Use STM32CubeMX to generate clock configuration (hybrid approach with STM32CubeH5)
- Implement system initialization ([system_stm32h5xx.c](../src/platform/system_stm32h5xx.c)) with clock/RCC configuration
- Update Makefile for ARM target builds
- Enable real hardware access (remove Windows stubs)
- **Goal**: ARM binary compiles and basic hardware initialization works

**Phase 2: Peripheral Initialization & CFPGA FIFO**

- Implement UART4 for debug logging (115200 baud)
- Implement GPIO for test/status pins
- Create CFPGA FIFO simulation (circular buffer with EXTI2 interrupt)
- Integrate Rust validation with FIFO interrupt handler
- End-to-end test: FIFO → ISR → Rust validation → C++ processing
- **Goal**: Complete externally-facing software interfaces with Rust-validated control/status functions

**Phase 3: Medium Priority Components (Out of Scope)**

- Implement medium priority internal components in Rust

**Phase 4: Full Rust Transition (Out of Scope)**

- Complete full transition of entire codebase to Rust

## Processor Software Architecture

CRUST-y uses a hybrid architecture combining a traditional 5-layer C++ design with a Rust safety layer for critical validation functions.

### 5-Layer C++ Architecture

#### Layer 5: Components

- Highest level of logic and functionality to perform complicated tasks
- Includes Control, NV Memory, Crypto Configuration, Key Management
- **Files**: [control.h/cpp](../include/crusty/components/control.h)
- **Language**: C++ (calls Rust validation via CXX bridge)

#### Layer 4: SpInterfaces

- Devices and Components API (how components talk to devices and other components)
- Provides logging, communication interfaces
- **Files**: [logging.h/cpp](../include/crusty/spinterfaces/logging.h)
- **Language**: C++

#### Layer 3: Devices

- Groups together HAL functions to perform meaningful work
- Includes Command Channel (RSS), CFPGA FIFO, TIME (Real Time Clock), Security
- **Files**: [device_base.h](../include/crusty/devices/device_base.h), cfpga_fifo.h/cpp (to be implemented)
- **Language**: C++

#### Layer 2: Hardware Abstraction Layer (HAL)

- Abstracts away hardware specifics (i.e., device drivers)
- Provides MMIO, GPIO, UART, NVIC interfaces
- **Files**: [mmio.h](../include/crusty/hal/mmio.h), [gpio.h/cpp](../include/crusty/hal/gpio.h), [uart.h/cpp](../include/crusty/hal/uart.h), [nvic.h/cpp](../include/crusty/hal/nvic.h)
- **Language**: C++ (uses ST register definitions underneath)

#### Layer 1: Platform (Low-Level Platform)

- Definitions of the processor and memory, peripherals it contains, register definitions
- Wraps STM32CubeH5 CMSIS headers with our abstractions
- **Files**: [stm32h573.h](../include/crusty/platform/stm32h573.h), [memory_map.h](../include/crusty/platform/memory_map.h), [types.h](../include/crusty/platform/types.h), [system_stm32h5xx.h/c](../include/crusty/platform/system_stm32h5xx.h)
- **Language**: C (system initialization), C++ (platform abstractions)
- **Dependencies**: STM32CubeH5 CMSIS device headers (`stm32h573xx.h`)

### Rust Safety Layer (Cross-Cutting)

The Rust safety layer provides memory-safe validation for critical operations, called from C++ via the CXX bridge.

- **100% Memory-Safe**: Zero unsafe blocks in validation code
- **no_std Compatible**: Runs on bare-metal (baremetal feature) or Windows (std-test feature)
- **CXX Bridge Integration**: Type-safe FFI with compile-time checks
- **Functions**:
  - `validate_control_message()` - Validates CFPGA control messages (checksum, bounds, command ID)
  - `validate_status_data()` - Validates status data before FIFO write
  - `calculate_crusty_number()` - Demo function (41 + 1 = 42)
- **Files**: [lib.rs](../rust/src/lib.rs) (CXX bridge), [validation.rs](../rust/src/validation.rs) (validation logic)
- **Language**: Rust (no_std, embedded_alloc heap)
- **Build Output**: `libcrusty.a` (static library linked with C++)

### Hybrid Approach with STM32CubeH5

CRUST-y leverages official ST resources while maintaining custom architecture:

- **From ST**: Register definitions (`stm32h573xx.h`), clock configuration (STM32CubeMX-generated), HAL examples for reference
- **From CRUST-y**: 5-layer architecture, Rust safety layer, custom build system, API design
- **Benefit**: Correct-by-design register access, faster development, reduced error risk

### Dual-Target Build System

The Makefile supports conditional compilation for two targets:

- **Windows Development** (`make TARGET=windows`):
  - Uses MinGW G++ compiler
  - Rust target: `x86_64-pc-windows-gnu`
  - MMIO operations return stubs (no hardware access)
  - UART outputs to console
  - Fast iteration for logic development

- **ARM Production** (`make TARGET=arm`):
  - Uses ARM GCC (`arm-none-eabi-gcc`)
  - Rust target: `thumbv8m.main-none-eabihf`
  - Real MMIO hardware access
  - Real UART hardware (UART4)
  - Linker script: [stm32h573.ld](../stm32h573.ld)
  - Startup code: [startup.s](../startup.s)
