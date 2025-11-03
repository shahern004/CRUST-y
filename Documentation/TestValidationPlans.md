# CRUST-y Test Validation Plans

This document contains manual test procedures for each development phase. Execute these tests after implementation is complete for each phase.

**Current Status**: Phase 0 ✅ COMPLETE | Phase 1 🔄 IN PROGRESS | Phase 2 📋 PLANNED

---

## Phase 0: CXX Bridge Foundation - Test Plan ✅ COMPLETE

### Test 0.1: Build System Verification ✅ COMPLETE

**Objective**: Verify Rust build system generates CXX headers and compiles successfully

**Prerequisites**:
- `rust/build.rs` created
- `rust/Cargo.toml` updated with dependencies
- `rust/src/lib.rs` contains CXX bridge definition

**Test Steps**:
1. Clean all build artifacts:
   ```bash
   make clean
   ```

2. Build Rust code only:
   ```bash
   make rust
   ```

3. Verify Rust build succeeds with no errors

4. Check generated CXX header exists:
   ```bash
   dir rust\target\x86_64-pc-windows-gnu\cxxbridge\crusty-firmware\src\lib.rs.h
   ```

5. Check generated CXX implementation exists:
   ```bash
   dir rust\target\x86_64-pc-windows-gnu\cxxbridge\crusty-firmware\src\lib.rs.cc
   ```

6. Check Rust static library exists:
   ```bash
   dir rust\target\x86_64-pc-windows-gnu\release\libcrusty.a
   ```

**Expected Results**:
- ✅ `cargo build --release` completes successfully
- ✅ `lib.rs.h` file exists in target cxxbridge directory
- ✅ `lib.rs.cc` file exists in target cxxbridge directory
- ✅ `libcrusty.a` file exists in `rust/target/x86_64-pc-windows-gnu/release/`
- ✅ No compilation errors or warnings

**Pass/Fail Criteria**:
- **PASS**: All files generated, no errors ✅ VERIFIED
- **FAIL**: Missing files, compilation errors, or CXX generation failures

**Actual Result**: PASS - Rust builds successfully, CXX generates FFI bindings, library compiles

---

### Test 0.2: CXX Header Content Verification

**Objective**: Verify generated CXX headers contain expected function signatures

**Test Steps**:
1. Open generated header file:
   ```bash
   type Rust\target\cxxbridge\crusty\src\lib.rs.h
   ```

2. Manually inspect for expected declarations:
   - `struct ControlMessage` with fields (command_id, data, checksum)
   - `struct ValidationResult` with fields (is_valid, error_code)
   - Function declaration: `ValidationResult validate_control_message(const ControlMessage&)`
   - Function declaration: `ValidationResult validate_status_data(...)`

3. Verify no C++ syntax errors in generated code

**Expected Results**:
- ✅ Header contains `#pragma once` or include guards
- ✅ Structs defined in CXX bridge are present
- ✅ Function declarations match Rust signature definitions
- ✅ Proper namespace usage (e.g., `namespace crusty`)
- ✅ Valid C++ syntax

**Pass/Fail Criteria**:
- **PASS**: All expected declarations present, valid C++ syntax
- **FAIL**: Missing declarations, syntax errors, or type mismatches

---

### Test 0.3: Allocator Initialization

**Objective**: Verify Rust global allocator initializes correctly

**Test Steps**:
1. Build should have succeeded in Test 0.1 (allocator compiles)

2. Inspect Rust build output for allocator-related warnings:
   ```bash
   cd Rust
   cargo build --release 2>&1 | findstr /I "alloc"
   ```

3. Review `Rust/src/lib.rs` source code:
   - Verify `#[global_allocator]` attribute present
   - Verify `embedded_alloc::Heap` declaration
   - Verify heap size is reasonable (e.g., 65536 bytes)

**Expected Results**:
- ✅ No allocator-related compilation errors
- ✅ Global allocator declared with appropriate size
- ✅ Panic handler present for no_std environment

**Pass/Fail Criteria**:
- **PASS**: Allocator compiles, heap configured
- **FAIL**: Allocator errors, missing panic handler, or build failures

---

### Test 0.4: C++ Build Integration

**Objective**: Verify C++ code can include CXX-generated headers and link with Rust

**Test Steps**:
1. Build entire project (C++ + Rust):
   ```bash
   mingw32-make clean
   mingw32-make all
   ```

2. Verify build order is correct:
   - Rust builds first (generates headers)
   - CXX-generated C++ code compiles (lib.rs.cc)
   - C++ application code compiles (includes lib.rs.h)
   - Linking produces executable

3. Check for linking errors related to Rust symbols

4. Verify executable exists:
   ```bash
   dir build\crusty_firmware.exe
   ```

**Expected Results**:
- ✅ Build completes with Rust → C++ → Link order
- ✅ CXX-generated `lib.rs.cc` compiles successfully
- ✅ C++ code including `lib.rs.h` compiles successfully
- ✅ Linking resolves all Rust function symbols
- ✅ `crusty_firmware.exe` created
- ✅ No undefined reference errors

**Pass/Fail Criteria**:
- **PASS**: Full build succeeds, executable created
- **FAIL**: Compilation errors, linking errors, or missing executable

---

### Test 0.5: Basic Execution Test

**Objective**: Verify executable runs without crashing (pre-integration)

**Test Steps**:
1. Run the executable:
   ```bash
   mingw32-make run
   ```

2. Observe console output:
   - Check for platform initialization messages
   - Check for component initialization messages
   - Verify no crashes or segmentation faults

3. Program should execute existing C++ code path (no Rust calls yet)

**Expected Results**:
- ✅ Program starts successfully
- ✅ Log output shows initialization messages
- ✅ No runtime crashes or errors
- ✅ Program completes or enters main loop as expected

**Pass/Fail Criteria**:
- **PASS**: Program runs, logs appear, no crashes
- **FAIL**: Crashes, hangs, or immediate exit with errors

---

### Phase 0 Test Summary Report Template

After completing all Phase 0 tests, fill out this summary:

```
=== PHASE 0 TEST RESULTS ===
Date: _____________
Tester: ___________

Test 0.1 - Build System Verification:        [ PASS / FAIL ]
Test 0.2 - CXX Header Content Verification:  [ PASS / FAIL ]
Test 0.3 - Allocator Initialization:         [ PASS / FAIL ]
Test 0.4 - C++ Build Integration:            [ PASS / FAIL ]
Test 0.5 - Basic Execution Test:             [ PASS / FAIL ]

Overall Phase 0 Status: [ PASS / FAIL ]

Notes/Issues:
_________________________________________________
_________________________________________________
_________________________________________________

Decision: [ APPROVED TO PROCEED TO PHASE 1 / REQUIRES FIXES ]
```

---

## Phase 1: System Initialization - Test Plan 🔄 IN PROGRESS

**Execute after ARM toolchain installation and system initialization implementation**

### Test 1.1: ARM GCC Toolchain Installation

**Objective**: Verify ARM cross-compiler is installed and accessible

**Test Steps**:
1. Check ARM GCC version:
   ```bash
   arm-none-eabi-gcc --version
   ```

2. Check ARM G++ version:
   ```bash
   arm-none-eabi-g++ --version
   ```

3. Check binutils:
   ```bash
   arm-none-eabi-size --version
   arm-none-eabi-objcopy --version
   ```

**Expected Results**:
- ✅ ARM GCC version 13.2 or later
- ✅ All toolchain utilities accessible
- ✅ No "command not found" errors

**Pass/Fail Criteria**:
- **PASS**: Toolchain installed and functional
- **FAIL**: Missing tools or version mismatch

---

### Test 1.2: Dual-Target Makefile - Windows Build

**Objective**: Verify Windows development build still works after Makefile updates

**Test Steps**:
1. Clean and build for Windows target:
   ```bash
   make clean
   make TARGET=windows
   ```

2. Run executable:
   ```bash
   make run
   ```

3. Verify output shows initialization messages

**Expected Results**:
- ✅ Windows build compiles successfully
- ✅ Executable runs without crashes
- ✅ Conditional compilation uses Windows stubs
- ✅ Console output visible

**Pass/Fail Criteria**:
- **PASS**: Windows build works as before
- **FAIL**: Compilation errors or runtime issues

---

### Test 1.3: ARM Target Build Compilation

**Objective**: Verify ARM cross-compilation succeeds

**Test Steps**:
1. Build for ARM target:
   ```bash
   make clean
   make TARGET=arm
   ```

2. Check for compilation errors

3. Verify binary created:
   ```bash
   dir build\crusty_firmware.elf
   ```

4. Check binary size:
   ```bash
   arm-none-eabi-size build\crusty_firmware.elf
   ```

**Expected Results**:
- ✅ ARM build compiles without errors
- ✅ `crusty_firmware.elf` created
- ✅ Text section < 2MB (Flash constraint)
- ✅ Data + BSS < 640KB (RAM constraint)
- ✅ Rust library links correctly

**Pass/Fail Criteria**:
- **PASS**: ARM binary builds and fits in memory constraints
- **FAIL**: Compilation errors or size exceeds constraints

---

### Test 1.4: System Initialization Code Verification

**Objective**: Verify system_stm32h5xx.c contains clock configuration

**Test Steps**:
1. Review [system_stm32h5xx.c](../src/platform/system_stm32h5xx.c):
   - FPU initialization present
   - Clock configuration from CubeMX integrated
   - SystemCoreClock = 250000000 (after PLL config)

2. Verify SystemInit() is called from [startup.s](../startup.s)

3. Check that linker script sections are correct

**Expected Results**:
- ✅ SystemInit() calls FPU setup
- ✅ SystemInit() configures PLL for 250 MHz
- ✅ Startup code calls SystemInit() before main()
- ✅ Linker script compatible with ST memory layout

**Pass/Fail Criteria**:
- **PASS**: System initialization code complete and correct
- **FAIL**: Missing initialization or incorrect configuration

---

### Test 1.5: Hardware Flashing (Requires STM32H573I-DK)

**Objective**: Flash firmware to actual hardware and verify boot

**Prerequisites**:
- STM32H573I-DK board connected via ST-Link
- STM32CubeProgrammer installed

**Test Steps**:
1. Generate binary file:
   ```bash
   arm-none-eabi-objcopy -O binary build\crusty_firmware.elf build\crusty_firmware.bin
   ```

2. Flash to board using STM32CubeProgrammer:
   ```bash
   STM32_Programmer_CLI -c port=SWD -w build\crusty_firmware.bin 0x08000000 -rst
   ```

3. Connect UART4 serial console (115200 baud)

4. Reset board and observe output

**Expected Results**:
- ✅ Firmware flashes successfully
- ✅ Board resets and runs
- ✅ UART output visible (if implemented)
- ✅ No hard faults or exceptions
- ✅ LED activity (if GPIO implemented)

**Pass/Fail Criteria**:
- **PASS**: Firmware runs on hardware without crashes
- **FAIL**: Flash errors, hard faults, or no activity

---

### Test 1.6: calculate_crusty_number() FFI Demonstration

**Objective**: Verify Rust function callable from C++ (simple FFI test)

**Test Steps**:
1. In main.cpp, add call to Rust function:
   ```cpp
   uint32_t crusty_num = calculate_crusty_number();
   logging::log("CRUSTy number: " + std::to_string(crusty_num));
   ```

2. Build and run (Windows or ARM)

3. Verify output shows "42"

**Expected Results**:
- ✅ C++ successfully calls Rust function via CXX bridge
- ✅ Return value is 42 (41 + 1)
- ✅ No FFI errors or crashes
- ✅ Demonstrates working C++/Rust integration

**Pass/Fail Criteria**:
- **PASS**: Rust function callable, returns correct value
- **FAIL**: Linking errors or wrong value

---

### Phase 1 Test Summary Report Template

```
=== PHASE 1 TEST RESULTS ===
Date: _____________
Tester: ___________

Test 1.1 - ARM GCC Toolchain Installation:   [ PASS / FAIL ]
Test 1.2 - Windows Build Still Works:        [ PASS / FAIL ]
Test 1.3 - ARM Target Build Compilation:     [ PASS / FAIL ]
Test 1.4 - System Initialization Code:       [ PASS / FAIL ]
Test 1.5 - Hardware Flashing (Optional):     [ PASS / FAIL / SKIPPED ]
Test 1.6 - calculate_crusty_number() Demo:   [ PASS / FAIL ]

Overall Phase 1 Status: [ PASS / FAIL ]

Notes/Issues:
_________________________________________________
_________________________________________________

Decision: [ APPROVED TO PROCEED TO PHASE 2 / REQUIRES FIXES ]
```

---

## Phase 2: CFPGA FIFO Device - Test Plan 📋 PLANNED

**Execute after Phase 1 approval and CFPGA FIFO implementation**

### Test 2.1: FIFO Initialization

**Objective**: Verify CFPGA FIFO device initializes correctly

**Test Steps**:
1. Build and run the program:
   ```bash
   mingw32-make clean
   mingw32-make all
   mingw32-make run
   ```

2. Check log output for CFPGA initialization messages:
   - "Initializing CFPGA FIFO..."
   - "CFPGA FIFO initialized successfully"

3. Verify no errors during device initialization

**Expected Results**:
- ✅ CFPGA device initializes without errors
- ✅ Initialization log messages appear
- ✅ FIFO internal state is ready (empty, read/write pointers at 0)

**Pass/Fail Criteria**:
- **PASS**: Device initializes, logs confirm success
- **FAIL**: Initialization errors or missing log messages

---

### Test 2.2: FIFO Write Operations

**Objective**: Verify data can be written to FIFO correctly

**Test Steps**:
1. Modify `Control::run()` to write test data to FIFO:
   ```cpp
   // Test: Write 10 words to FIFO
   uint16_t testData[10] = {0x1234, 0x5678, 0xABCD, ...};
   Status status = cfpgaFifo.write(testData, 10);
   ```

2. Check log output for write confirmation

3. Verify FIFO state updates correctly (count increases)

**Expected Results**:
- ✅ Write operation returns `Status::OK`
- ✅ FIFO count reflects written data (10 words)
- ✅ No buffer overflow errors
- ✅ Log shows successful write operation

**Pass/Fail Criteria**:
- **PASS**: Data written successfully, count correct
- **FAIL**: Write fails, incorrect count, or overflow

---

### Test 2.3: FIFO Read Operations

**Objective**: Verify data can be read from FIFO correctly

**Test Steps**:
1. After Test 1.2, read data back from FIFO:
   ```cpp
   uint16_t readBuffer[10];
   Status status = cfpgaFifo.read(readBuffer, 10);
   ```

2. Compare read data with originally written data

3. Verify FIFO count decreases correctly

**Expected Results**:
- ✅ Read operation returns `Status::OK`
- ✅ Read data matches written data (0x1234, 0x5678, etc.)
- ✅ FIFO count returns to 0 after reading all data
- ✅ No underflow errors

**Pass/Fail Criteria**:
- **PASS**: Data read correctly matches written data
- **FAIL**: Data mismatch, underflow, or read errors

---

### Test 2.4: FIFO Interrupt Trigger

**Objective**: Verify FIFO triggers interrupt when threshold reached

**Test Steps**:
1. Write data to exceed threshold (e.g., 256+ words):
   ```cpp
   uint16_t largeData[300];
   // Fill with test pattern
   Status status = cfpgaFifo.write(largeData, 300);
   ```

2. Check for interrupt trigger indication:
   - Log message: "CFPGA FIFO interrupt triggered"
   - Interrupt flag set in simulation

3. Verify ISR would be called (simulated environment)

**Expected Results**:
- ✅ Writing beyond threshold triggers interrupt
- ✅ Interrupt flag/callback invoked
- ✅ Log confirms interrupt event
- ✅ FIFO state remains consistent

**Pass/Fail Criteria**:
- **PASS**: Interrupt triggers at correct threshold
- **FAIL**: No interrupt, wrong threshold, or state corruption

---

### Test 2.5: Circular Buffer Wraparound

**Objective**: Verify FIFO handles wraparound correctly

**Test Steps**:
1. Fill FIFO to near capacity
2. Read some data to move read pointer
3. Write more data to cause wraparound
4. Read all data and verify correctness

**Expected Results**:
- ✅ Write pointer wraps to beginning correctly
- ✅ Read pointer tracks independently
- ✅ Data integrity maintained across wraparound
- ✅ No data loss or corruption

**Pass/Fail Criteria**:
- **PASS**: Wraparound works, data correct
- **FAIL**: Data corruption or pointer errors

---

### Test 2.6: FIFO Overflow Protection

**Objective**: Verify FIFO rejects writes when full

**Test Steps**:
1. Fill FIFO to maximum capacity
2. Attempt to write additional data
3. Verify operation returns error status

**Expected Results**:
- ✅ Write returns `Status::ERROR` when FIFO full
- ✅ No buffer overflow occurs
- ✅ Log message indicates FIFO full condition
- ✅ Existing data not corrupted

**Pass/Fail Criteria**:
- **PASS**: Overflow prevented, error status returned
- **FAIL**: Buffer overflow or data corruption

---

### Test 2.7: ControlMessage Structure Compatibility

**Objective**: Verify FIFO can produce data in CXX-compatible ControlMessage format

**Test Steps**:
1. Write test data representing a control message:
   ```cpp
   // Command ID: 0x0042, Length: 4, Payload: [0x11, 0x22, 0x33, 0x44], Checksum: calculated
   ```

2. Read data from FIFO into ControlMessage struct:
   ```cpp
   ControlMessage msg;
   cfpgaFifo.readMessage(msg);
   ```

3. Verify struct fields populated correctly

**Expected Results**:
- ✅ ControlMessage struct fields match written data
- ✅ Command ID, length, payload, checksum all correct
- ✅ Fixed-size array boundaries respected
- ✅ Ready for Rust validation (Phase 2 integration)

**Pass/Fail Criteria**:
- **PASS**: ControlMessage correctly formatted
- **FAIL**: Field mismatches or format errors

---

### Phase 2 Test Summary Report Template

```
=== PHASE 2 TEST RESULTS ===
Date: _____________
Tester: ___________

Test 2.1 - FIFO Initialization:              [ PASS / FAIL ]
Test 2.2 - FIFO Write Operations:            [ PASS / FAIL ]
Test 2.3 - FIFO Read Operations:             [ PASS / FAIL ]
Test 2.4 - FIFO Interrupt Trigger:           [ PASS / FAIL ]
Test 2.5 - Circular Buffer Wraparound:       [ PASS / FAIL ]
Test 2.6 - FIFO Overflow Protection:         [ PASS / FAIL ]
Test 2.7 - ControlMessage Compatibility:     [ PASS / FAIL ]

Overall Phase 2 Status: [ PASS / FAIL ]

Notes/Issues:
_________________________________________________
_________________________________________________

Decision: [ APPROVED TO PROCEED TO PHASE 3 / REQUIRES FIXES ]
```

---

## Phase 3: Rust Validation Integration - Test Plan

**Execute after Phase 2 approval - tests Rust validation with CFPGA FIFO**

**Note**: These tests were originally part of "Phase 2" but have been relabeled to Phase 3 for consistency with the new phase numbering (Phase 0: CXX Bridge ✅ COMPLETE, Phase 1: System Init 🔄 IN PROGRESS, Phase 2: CFPGA FIFO 📋 PLANNED, Phase 3: Rust Integration 📋 PLANNED)

### Test 3.1: Rust Function Compilation

**Objective**: Verify Rust validation functions compile without unsafe blocks

**Test Steps**:
1. Build Rust code:
   ```bash
   cd Rust
   cargo build --release
   ```

2. Check for compilation warnings related to unsafe code

3. Manually inspect Rust source files:
   - `Rust/src/control_handler.rs`
   - `Rust/src/status_handler.rs`

4. Count unsafe blocks in business logic (target: 0)

**Expected Results**:
- ✅ Rust code compiles successfully
- ✅ No unsafe blocks in validation logic
- ✅ All array accesses bounds-checked by Rust
- ✅ Type system enforces invariants

**Pass/Fail Criteria**:
- **PASS**: Compiles, zero unsafe blocks in validation code
- **FAIL**: Compilation errors or unsafe blocks present

---

### Test 2.2: Valid Control Message Validation

**Objective**: Verify Rust accepts valid control messages

**Test Steps**:
1. In C++, create valid test message:
   ```cpp
   ControlMessage validMsg;
   validMsg.command_id = 0x0042;  // Valid command ID
   validMsg.length = 4;
   validMsg.data[0] = 0x11;
   validMsg.data[1] = 0x22;
   validMsg.data[2] = 0x33;
   validMsg.data[3] = 0x44;
   validMsg.checksum = calculateChecksum(validMsg);  // Correct checksum
   ```

2. Call Rust validation:
   ```cpp
   ValidationResult result = validate_control_message(validMsg);
   ```

3. Check result status

**Expected Results**:
- ✅ `result.is_valid == true`
- ✅ `result.error_code == 0` (no error)
- ✅ Log shows "Control message validation: PASS"

**Pass/Fail Criteria**:
- **PASS**: Valid message accepted
- **FAIL**: Valid message rejected incorrectly

---

### Test 2.3: Invalid Checksum Detection

**Objective**: Verify Rust rejects messages with incorrect checksums

**Test Steps**:
1. Create message with intentionally wrong checksum:
   ```cpp
   ControlMessage badMsg = validMsg;  // Copy valid message
   badMsg.checksum = 0xDEAD;  // Wrong checksum
   ```

2. Call Rust validation:
   ```cpp
   ValidationResult result = validate_control_message(badMsg);
   ```

3. Check result indicates checksum error

**Expected Results**:
- ✅ `result.is_valid == false`
- ✅ `result.error_code == ERROR_CHECKSUM` (specific error)
- ✅ Log shows "Control message validation: FAIL - Checksum mismatch"

**Pass/Fail Criteria**:
- **PASS**: Invalid checksum detected and rejected
- **FAIL**: Bad message accepted or wrong error code

---

### Test 2.4: Out-of-Range Command ID Detection

**Objective**: Verify Rust rejects invalid command IDs

**Test Steps**:
1. Create message with invalid command ID:
   ```cpp
   ControlMessage badMsg;
   badMsg.command_id = 0xFFFF;  // Invalid/unknown command
   // ... populate other fields correctly
   ```

2. Call Rust validation

**Expected Results**:
- ✅ `result.is_valid == false`
- ✅ `result.error_code == ERROR_INVALID_COMMAND`
- ✅ Log shows error with command ID

**Pass/Fail Criteria**:
- **PASS**: Invalid command ID rejected
- **FAIL**: Invalid command accepted

---

### Test 2.5: Buffer Overflow Protection

**Objective**: Verify Rust prevents buffer overflows in payload

**Test Steps**:
1. Create message with length exceeding buffer:
   ```cpp
   ControlMessage badMsg;
   badMsg.command_id = 0x0042;
   badMsg.length = 300;  // Exceeds 256-word buffer
   // ... attempt to process
   ```

2. Call Rust validation

**Expected Results**:
- ✅ `result.is_valid == false`
- ✅ `result.error_code == ERROR_BUFFER_OVERFLOW`
- ✅ No crash or memory corruption
- ✅ Rust bounds checking prevents out-of-bounds access

**Pass/Fail Criteria**:
- **PASS**: Overflow prevented, error returned safely
- **FAIL**: Crash, corruption, or overflow allowed

---

### Test 2.6: Status Data Validation

**Objective**: Verify Rust validates status data correctly

**Test Steps**:
1. Create valid status data buffer:
   ```cpp
   uint16_t statusData[64] = { /* valid status fields */ };
   ```

2. Call Rust validation:
   ```cpp
   ValidationResult result = validate_status_data(statusData, 64);
   ```

3. Verify acceptance of valid data

4. Repeat with invalid data (out-of-range values)

**Expected Results**:
- ✅ Valid status data accepted (`is_valid == true`)
- ✅ Invalid status data rejected (`is_valid == false`)
- ✅ Appropriate error codes for different failure types

**Pass/Fail Criteria**:
- **PASS**: Correct validation behavior for valid/invalid data
- **FAIL**: Incorrect acceptance/rejection

---

### Test 2.7: Rust Unit Tests

**Objective**: Run Rust's internal unit tests

**Test Steps**:
1. Run Rust test suite:
   ```bash
   cd Rust
   cargo test --lib
   ```

2. Verify all tests pass

3. Review test coverage:
   - Valid message tests
   - Invalid checksum tests
   - Invalid command ID tests
   - Buffer overflow tests
   - Edge cases (empty messages, max length, etc.)

**Expected Results**:
- ✅ All unit tests pass
- ✅ Test coverage includes happy path and error cases
- ✅ No test failures or panics

**Pass/Fail Criteria**:
- **PASS**: All Rust unit tests pass
- **FAIL**: Any test failures

---

### Phase 2 Test Summary Report Template

```
=== PHASE 2 TEST RESULTS ===
Date: _____________
Tester: ___________

Test 2.1 - Rust Function Compilation:        [ PASS / FAIL ]
Test 2.2 - Valid Control Message Validation: [ PASS / FAIL ]
Test 2.3 - Invalid Checksum Detection:       [ PASS / FAIL ]
Test 2.4 - Out-of-Range Command ID:          [ PASS / FAIL ]
Test 2.5 - Buffer Overflow Protection:       [ PASS / FAIL ]
Test 2.6 - Status Data Validation:           [ PASS / FAIL ]
Test 2.7 - Rust Unit Tests:                  [ PASS / FAIL ]

Overall Phase 2 Status: [ PASS / FAIL ]

Notes/Issues:
_________________________________________________
_________________________________________________

Decision: [ APPROVED TO PROCEED TO PHASE 3 / REQUIRES FIXES ]
```

---

## Phase 3: End-to-End Integration - Test Plan

**Execute after Phases 1 and 2 are both approved**

### Test 3.1: FIFO to Rust Integration

**Objective**: Verify FIFO interrupt triggers Rust validation

**Test Steps**:
1. Write control message to FIFO (exceeds threshold)
2. Verify interrupt triggers
3. Verify ISR reads message from FIFO
4. Verify ISR calls Rust validation function
5. Check log for Rust validation result

**Expected Results**:
- ✅ FIFO interrupt triggers ISR
- ✅ ISR extracts ControlMessage from FIFO
- ✅ Rust `validate_control_message()` called
- ✅ Validation result returned to C++
- ✅ Log shows complete flow: FIFO → ISR → Rust → Result

**Pass/Fail Criteria**:
- **PASS**: Complete data flow from FIFO through Rust validation
- **FAIL**: Missing steps or data not reaching Rust

---

### Test 3.2: Valid Command Execution Path

**Objective**: Verify valid commands execute after Rust validation

**Test Steps**:
1. Inject valid control command into FIFO
2. Allow interrupt and validation to occur
3. Verify C++ Control component receives validated command
4. Verify command executes (e.g., LED toggle, status update)
5. Check log for execution confirmation

**Expected Results**:
- ✅ Valid command passes Rust validation
- ✅ C++ Control component executes command
- ✅ Expected side effects occur (LED toggle, etc.)
- ✅ Log shows: "Command 0x0042 validated and executed"

**Pass/Fail Criteria**:
- **PASS**: Valid command executes successfully
- **FAIL**: Command not executed or wrong behavior

---

### Test 3.3: Invalid Command Rejection Path

**Objective**: Verify invalid commands are rejected safely

**Test Steps**:
1. Inject invalid control command (bad checksum)
2. Allow interrupt and validation to occur
3. Verify Rust rejects command
4. Verify C++ does NOT execute command
5. Check log for rejection message with reason

**Expected Results**:
- ✅ Invalid command fails Rust validation
- ✅ C++ receives rejection result
- ✅ Command NOT executed
- ✅ System remains stable (no crash)
- ✅ Log shows: "Command rejected: Checksum error"

**Pass/Fail Criteria**:
- **PASS**: Invalid command safely rejected, no execution
- **FAIL**: Command executes or system crashes

---

### Test 3.4: Status Response Generation

**Objective**: Verify status data validated before FIFO write

**Test Steps**:
1. C++ Control component generates status response
2. Status data passed to Rust for validation
3. Verify Rust validates status data
4. Verify validated status written to FIFO
5. Check FIFO contains correct status data

**Expected Results**:
- ✅ Status data validated by Rust
- ✅ Valid status written to FIFO successfully
- ✅ FIFO contains correct status values
- ✅ Log shows status validation and write

**Pass/Fail Criteria**:
- **PASS**: Status validated and written correctly
- **FAIL**: Invalid status written or validation skipped

---

### Test 3.5: Multiple Message Sequence

**Objective**: Verify system handles multiple messages correctly

**Test Steps**:
1. Inject sequence of 5 control messages:
   - Message 1: Valid command A
   - Message 2: Valid command B
   - Message 3: Invalid (bad checksum)
   - Message 4: Valid command C
   - Message 5: Invalid (bad command ID)

2. Process all messages through interrupt/validation flow

3. Verify correct handling of each message

**Expected Results**:
- ✅ Valid messages (1, 2, 4) execute successfully
- ✅ Invalid messages (3, 5) rejected correctly
- ✅ Correct order maintained
- ✅ No message lost or duplicated
- ✅ System remains stable throughout

**Pass/Fail Criteria**:
- **PASS**: All messages handled correctly in sequence
- **FAIL**: Lost messages, wrong order, or system instability

---

### Test 3.6: Performance and Timing

**Objective**: Verify system meets timing requirements

**Test Steps**:
1. Measure time from FIFO interrupt to command execution
2. Process 100 valid commands and calculate average latency
3. Check for memory leaks (heap usage)
4. Verify no stack overflows

**Expected Results**:
- ✅ Interrupt latency < 100μs (adjust for Windows simulation)
- ✅ Average processing time acceptable
- ✅ No memory leaks detected
- ✅ Stack usage within bounds
- ✅ Heap usage stable (allocator not growing)

**Pass/Fail Criteria**:
- **PASS**: Performance acceptable, no memory issues
- **FAIL**: Excessive latency or memory problems

---

### Test 3.7: Error Recovery and Stability

**Objective**: Verify system recovers from error conditions

**Test Steps**:
1. Test FIFO overflow condition (fill FIFO completely)
2. Inject message during overflow
3. Verify system rejects and recovers
4. Resume normal operation after clearing FIFO
5. Verify no persistent errors

**Expected Results**:
- ✅ Overflow detected and handled gracefully
- ✅ Error message logged
- ✅ System does not crash
- ✅ Normal operation resumes after recovery
- ✅ No data corruption

**Pass/Fail Criteria**:
- **PASS**: System recovers from errors gracefully
- **FAIL**: Crashes, hangs, or data corruption

---

### Test 3.8: Memory Safety Validation

**Objective**: Verify no memory safety violations occur

**Test Steps**:
1. Run complete test sequence with address sanitizer (if available on Windows)
2. Check for:
   - Buffer overflows
   - Use-after-free
   - Double-free
   - Memory leaks
   - Stack corruption

3. Review Rust's safety guarantees maintained

**Expected Results**:
- ✅ No memory safety violations detected
- ✅ Rust validation prevents C++ from processing unsafe data
- ✅ All buffer accesses within bounds
- ✅ No undefined behavior

**Pass/Fail Criteria**:
- **PASS**: Zero memory safety violations
- **FAIL**: Any memory safety issues detected

---

### Phase 3 Test Summary Report Template

```
=== PHASE 3 TEST RESULTS ===
Date: _____________
Tester: ___________

Test 3.1 - FIFO to Rust Integration:         [ PASS / FAIL ]
Test 3.2 - Valid Command Execution Path:     [ PASS / FAIL ]
Test 3.3 - Invalid Command Rejection Path:   [ PASS / FAIL ]
Test 3.4 - Status Response Generation:       [ PASS / FAIL ]
Test 3.5 - Multiple Message Sequence:        [ PASS / FAIL ]
Test 3.6 - Performance and Timing:           [ PASS / FAIL ]
Test 3.7 - Error Recovery and Stability:     [ PASS / FAIL ]
Test 3.8 - Memory Safety Validation:         [ PASS / FAIL ]

Overall Phase 3 Status: [ PASS / FAIL ]

Notes/Issues:
_________________________________________________
_________________________________________________

Decision: [ PROJECT COMPLETE / REQUIRES FIXES ]
```

---

## Final Integration Test Summary

After completing all phases, document overall project status:

```
=== CRUST-Y PROJECT FINAL TEST SUMMARY ===
Date: _____________
Project Lead: ___________

Phase 0 - CXX Bridge Foundation:       [ PASS / FAIL ]
Phase 1 - CFPGA FIFO Device:           [ PASS / FAIL ]
Phase 2 - Rust Safety Functions:      [ PASS / FAIL ]
Phase 3 - End-to-End Integration:     [ PASS / FAIL ]

Overall Project Status: [ SUCCESS / PARTIAL / FAILURE ]

Key Achievements:
- ________________________________
- ________________________________
- ________________________________

Lessons Learned:
- ________________________________
- ________________________________
- ________________________________

Recommendations for Production Migration:
- ________________________________
- ________________________________
- ________________________________

Ready for Documentation Phase: [ YES / NO ]
```

---

## Test Execution Notes

**General Guidelines**:
1. Execute tests in order (0.1 → 0.2 → ... → 3.8)
2. Do not proceed to next test if current test fails
3. Document all failures with detailed error messages
4. Capture console output for all test runs
5. Take notes on any unexpected behavior

**Test Environment**:
- OS: Windows 11
- Compiler: MinGW g++
- Rust toolchain: (document version)
- Hardware: Development PC (not embedded target)

**Debugging Tips**:
- Increase logging verbosity if tests fail
- Use `mingw32-make print-vars` to debug Makefile issues
- Check `cargo build --verbose` for Rust build details
- Review generated CXX headers manually if FFI issues occur

---

**End of Test Validation Plans**
