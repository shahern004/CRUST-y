# Windows-native Makefile for MinGW
TARGET_EXEC := main.exe

BUILD_DIR := build
SRC_DIR := src

# Manually list your source files (simple and explicit for Windows)
SRCS := $(SRC_DIR)/main.cpp

# Generate object file names
OBJS := $(SRCS:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)

# Compiler flags
CPPFLAGS := -I$(SRC_DIR)
CXXFLAGS := -Wall -Wextra

# Link step
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# Compile step
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	@if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)

.PHONY: run
run: $(BUILD_DIR)/$(TARGET_EXEC)
	.\$(BUILD_DIR)\$(TARGET_EXEC)