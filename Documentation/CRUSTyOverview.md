# CRUST-y System Overview

This project is to develop CRUST-y architecture as a proof-of-concept in a prototype environment. The output of this project is to create and test a baremetal application with the ULTIMATE GOAL of creating documentation on feasibility and lessons-learned with CRUST-y for adoption on the actual dev environment.

## Project Purpose

CRUST-y is a hybrid C++/Rust project that aims to meet NSA Memory-Safe-Language requirements using a prioritized, phased approach to ensure smooth and mangeable transition from Pure C++ legacy codebases to pure Rust.
**MEMORY SAFETY IS THE UTMOST PRIORITY AND THE PURPOSE OF THIS PROJECT**

## Hardware

- Security Processor: STM32U5A5
  - 2MB Flash NVM
  - For this project, we will use an STM32H573I-DK to mimic STM32U5A5 functionality and constraints.
- FPGA (Cryptographic Processor): Xilinx Kintex UltraScale+ KU5P
  - For this project, we will need to create a software abstraction of FPGA functionality. We do not have an FPGA in this lab.

## Software Development:

### Prototype Dev Environment

- OS: Windows 11
- IDE: VSCode

### CRUST-y Software Tooling

- CXX: C++/Rust Bridge (see cxx.md for documentation)
- Compiler: G++
- Target System: Bare-Metal STM32H573I-DK (adhering to Baremetal STM32U5A5 constraints, which will be eventual production processor)
- Makefile management: Manual Makefiles (No CMAKE)

### Development Phases

1. Phase 1:

- Implement externally-facing software interfaces and software-validated control/status bypass functions in Rust (high priority)
- For this prototype, we will create a simulated CFPGA FIFO in software which sends an interrupt to the the C++ core code. C++ will then dispatch Rust code to handle control/status data from in and out of the FIFO to the C++ core code for processing.
- **CXX Bridge Foundation (Phase 0)**: CXX defines the FFI interface between C++ and Rust. The CXX bridge must be established first, as it generates C++ headers that integration code depends on. This is a foundational architectural decision, not an optional add-on.
- CXX will be used to bridge C++ and Rust interroperability with compile-time type safety. Keep in mind this application will be deployed to a baremetal embedded system (no_std with allocator). All relevant constraints need to be concidered during development.
- Dev Environment code examples are in this repo in ./Rust/ and ./src/. The existing Rust code uses raw FFI and will be replaced with CXX bridge implementation for memory safety.

1. Phase 2:

- Implement medium priority internal components in Rust (out of scope for this prototype project)

3. Phase 3:

- Complete full transition of the entire TaISR codebase to Rust (out of scope for this prototype project)

## Processor Software Components

### Layer 5: Components

- Highest level of logic and funcitonality to perform complicated tasks
- Includes Control, NV Memory, Crypto Configuration, Key Management

### Layer 4: SpInterfaces

- Devices and Components API (how components talk to devices and other components)

### Layer 3: Devices

- Groups together HAL functions to perfrom meaningful work
- Includes Command Channel (RSS), CFPGA, TIME (Real Time Clock), Security

### Layer 2: Hardware Abstraction Layer (HAL)

- Abastracts away hardware sepcifics (I.e., device driver)

### Layer 1: LowLevelPlatform

- Definitions of the processor and memory, peripherals it contains, register definitions, etc
