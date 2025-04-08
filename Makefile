# Makefile for building NASM tictactoe project

SRC_DIR := src
OUT_DIR := out
ENTRY := _start
ENTRY_FILE := $(SRC_DIR)/tictactoe.asm
OUT_BIN := $(OUT_DIR)/tictactoe
DEBUG_BIN := $(OUT_DIR)/tictactoe_debug

ASM := nasm
LD := ld

ASMFLAGS := -f elf64
LDFLAGS := -e $(ENTRY) -s -no-pie -z noseparate-code -static
DEBUG_ASMFLAGS := -f elf64 -g
DEBUG_LDFLAGS := -e $(ENTRY)

SOURCES := $(wildcard $(SRC_DIR)/*.asm)
OBJECTS := $(patsubst $(SRC_DIR)/%.asm, $(OUT_DIR)/%.o, $(SOURCES))
DEBUG_OBJECTS := $(patsubst $(SRC_DIR)/%.asm, $(OUT_DIR)/%_dbg.o, $(SOURCES))

# Default build
all: $(OUT_DIR) $(OUT_BIN)

# Create output directory if it doesn't exist
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Compile normal object files
$(OUT_DIR)/%.o: $(SRC_DIR)/%.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

# Link normal binary
$(OUT_BIN): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

# Clean build artifacts
clean:
	rm -rf $(OUT_DIR)

# Run the compiled binary
run: all
	./$(OUT_BIN)

# Debug build
debug: $(OUT_DIR) $(DEBUG_BIN)
	gdb $(DEBUG_BIN)

# Compile debug object files
$(OUT_DIR)/%_dbg.o: $(SRC_DIR)/%.asm
	$(ASM) $(DEBUG_ASMFLAGS) -o $@ $<

# Link debug binary
$(DEBUG_BIN): $(DEBUG_OBJECTS)
	$(LD) $(DEBUG_LDFLAGS) -o $@ $^
