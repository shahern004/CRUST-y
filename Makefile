# CRUST-y Makefile for hybrid C++/Rust firmware
# STM32H573 (Cortex-M33) - ARM cross-compilation

# ============================================================================
# Build Configuration
# ============================================================================

TARGET_EXEC := crustyV2_firmware.elf
TARGET_BIN  := crustyV2_firmware.bin
TARGET_HEX  := crustyV2_firmware.hex
BUILD_DIR   := C:\GithubProjects\CRUST-y\build
SRC_DIR     := C:\GithubProjects\CRUST-y\src
INC_DIR     := C:\GithubProjects\CRUST-y\include
RUST_DIR    := C:\GithubProjects\CRUST-y\rust
LINKER_SCRIPT := stm32h573.ld
STARTUP_FILE  := startup.s

# ============================================================================
# Toolchain (ARM Embedded GCC)
# ============================================================================

PREFIX := arm-none-eabi-
CC     := $(PREFIX)gcc
CXX    := $(PREFIX)g++
AS     := $(PREFIX)as
LD     := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
SIZE    := $(PREFIX)size
CARGO   := cargo

# Rust target for Cortex-M33
RUST_TARGET := thumbv8m.main-none-eabihf

# ============================================================================
# CXX Bridge Generated Files
# ============================================================================

CXX_BRIDGE_DIR := $(RUST_DIR)/target/$(RUST_TARGET)/cxxbridge/crustyV2-firmware/src
CXX_HEADER     := $(CXX_BRIDGE_DIR)/lib.rs.h
CXX_SOURCE     := $(CXX_BRIDGE_DIR)/lib.rs.cc
CXX_CXX_HEADER := $(RUST_DIR)/target/cxxbridge/rust/cxx.h
RUST_LIB       := $(RUST_DIR)/target/$(RUST_TARGET)/release/libcrustyV2.a

# ============================================================================
# C++ Source Files
# ============================================================================

OBJS := $(BUILD_DIR)/startup.o \
        $(BUILD_DIR)/main.o \
        $(BUILD_DIR)/nvic.o \
        $(BUILD_DIR)/gpio.o \
        $(BUILD_DIR)/uart.o \
        $(BUILD_DIR)/logging.o \
        $(BUILD_DIR)/control.o \
        $(BUILD_DIR)/system_stm32h5xx.o \
        $(BUILD_DIR)/cxxbridge.o

# ============================================================================
# Compiler Flags for Cortex-M33 with FPU
# ============================================================================

# CPU-specific flags
CPU_FLAGS := -mcpu=cortex-m33 \
             -mthumb \
             -mfpu=fpv5-sp-d16 \
             -mfloat-abi=hard

# Include paths (CRITICAL: Include CXX-generated headers)
INCLUDES := -I$(INC_DIR) \
            -I$(CXX_BRIDGE_DIR) \
            -I$(RUST_DIR)/target/cxxbridge

# C++ compiler flags
CXXFLAGS := $(CPU_FLAGS) \
            $(INCLUDES) \
            -std=c++17 \
            -O2 \
            -g3 \
            -Wall \
            -Wextra \
            -fno-exceptions \
            -fno-rtti \
            -ffunction-sections \
            -fdata-sections \
            -DSTM32H573xx \
            -DUSE_HAL_DRIVER

# Assembly flags
ASFLAGS := $(CPU_FLAGS) \
           -g3

# Linker flags
LDFLAGS := $(CPU_FLAGS) \
           -T$(LINKER_SCRIPT) \
           -Wl,--gc-sections \
           -Wl,-Map=$(BUILD_DIR)/$(basename $(TARGET_EXEC)).map \
           -Wl,--print-memory-usage \
           --specs=nano.specs \
           --specs=nosys.specs

# Libraries to link (Rust + system)
LIBS := -L$(RUST_DIR)/target/$(RUST_TARGET)/release \
        -lcrustyV2 \
        -lm \
        -lc

# ============================================================================
# Build Rules
# ============================================================================

.PHONY: all clean rust cpp flash size hex bin print-vars

# Default target: Build everything
all: rust cpp

# Build C++ firmware (produces .elf)
cpp: $(BUILD_DIR)/$(TARGET_EXEC)

# Generate .bin and .hex files for flashing
bin: $(BUILD_DIR)/$(TARGET_BIN)
hex: $(BUILD_DIR)/$(TARGET_HEX)

# Build Rust library with CXX code generation
rust:
	@echo "========================================"
	@echo "Building Rust library for $(RUST_TARGET)..."
	@echo "========================================"
	cd $(RUST_DIR) && $(CARGO) build --target $(RUST_TARGET) --release
	@echo ""
	@echo "CXX-generated files:"
	@if [ -f $(CXX_HEADER) ]; then echo "[OK] $(CXX_HEADER)"; else echo "[MISSING] $(CXX_HEADER)"; fi
	@if [ -f $(CXX_SOURCE) ]; then echo "[OK] $(CXX_SOURCE)"; else echo "[MISSING] $(CXX_SOURCE)"; fi
	@if [ -f $(RUST_LIB) ]; then echo "[OK] $(RUST_LIB)"; else echo "[MISSING] $(RUST_LIB)"; fi
	@echo "========================================"
	@echo "Rust build complete"
	@echo "========================================"

# Link C++ objects with Rust static library
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS) $(RUST_LIB)
	@echo "========================================"
	@echo "Linking $(TARGET_EXEC)..."
	@echo "========================================"
	$(LD) $(OBJS) $(LDFLAGS) $(LIBS) -o $@
	@echo ""
	$(SIZE) $@
	@echo "========================================"
	@echo "Build complete!"
	@echo "========================================"

# Convert ELF to binary (for flashing)
$(BUILD_DIR)/$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_EXEC)
	@echo "Generating binary file..."
	$(OBJCOPY) -O binary $< $@
	@echo "Binary: $@"

# Convert ELF to Intel HEX (for flashing)
$(BUILD_DIR)/$(TARGET_HEX): $(BUILD_DIR)/$(TARGET_EXEC)
	@echo "Generating hex file..."
	$(OBJCOPY) -O ihex $< $@
	@echo "Hex: $@"

# ============================================================================
# Compilation Rules
# ============================================================================

# Assemble startup code
$(BUILD_DIR)/startup.o: $(STARTUP_FILE)
	@mkdir -p $(BUILD_DIR)
	@echo "Assembling $(STARTUP_FILE)..."
	$(AS) $(ASFLAGS) $< -o $@

# Compile CXX-generated C++ code (auto-generated by Rust)
$(BUILD_DIR)/cxxbridge.o: $(CXX_SOURCE)
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling CXX bridge (lib.rs.cc)..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile C++ source files
$(BUILD_DIR)/main.o: $(SRC_DIR)/main.cpp $(CXX_HEADER)
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling main.cpp..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/nvic.o: $(SRC_DIR)/hal/nvic.cpp
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling nvic.cpp..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/gpio.o: $(SRC_DIR)/hal/gpio.cpp
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling gpio.cpp..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/uart.o: $(SRC_DIR)/hal/uart.cpp
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling uart.cpp..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/logging.o: $(SRC_DIR)/spinterfaces/logging.cpp
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling logging.cpp..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/control.o: $(SRC_DIR)/components/control.cpp $(CXX_HEADER)
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling control.cpp..."
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/system_stm32h5xx.o: $(SRC_DIR)/platform/system_stm32h5xx.c
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling system_stm32h5xx.c..."
	$(CC) $(CXXFLAGS) -c $< -o $@

# ============================================================================
# Utility Targets
# ============================================================================

# Display binary size information
size: $(BUILD_DIR)/$(TARGET_EXEC)
	@echo "========================================"
	@echo "Memory Usage:"
	@echo "========================================"
	$(SIZE) $<

# Clean build artifacts
clean:
	@echo "========================================"
	@echo "Cleaning build artifacts..."
	@echo "========================================"
	rm -rf $(BUILD_DIR)
	cd $(RUST_DIR) && $(CARGO) clean
	@echo "========================================"
	@echo "Clean complete"
	@echo "========================================"

# Flash to STM32 (requires st-flash or OpenOCD)
# Uncomment and modify for your programmer
# flash: $(BUILD_DIR)/$(TARGET_BIN)
# 	st-flash write $< 0x08000000

# Print build variables (for debugging)
print-vars:
	@echo "OBJS:          $(OBJS)"
	@echo "CXXFLAGS:      $(CXXFLAGS)"
	@echo "LDFLAGS:       $(LDFLAGS)"
	@echo "CXX_HEADER:    $(CXX_HEADER)"
	@echo "CXX_SOURCE:    $(CXX_SOURCE)"
	@echo "RUST_LIB:      $(RUST_LIB)"
	@echo "RUST_TARGET:   $(RUST_TARGET)"
	@echo "LINKER_SCRIPT: $(LINKER_SCRIPT)"