# Makefile for building src/tictactoe.asm into out/tictactoe

ASM_SRC := src/tictactoe.asm
OUT_DIR := out
OUT_BIN := $(OUT_DIR)/tictactoe

NASM := nasm
LD := ld

.PHONY: all clean run debug

# Default target
all:
	@mkdir -p $(OUT_DIR)
	$(NASM) -f elf64 $(ASM_SRC) -o $(OUT_DIR)/tictactoe.o
	$(LD) -static -s -no-pie -z noseparate-code -o $(OUT_BIN) $(OUT_DIR)/tictactoe.o

clean:
	rm -rf $(OUT_DIR)

run: all
	./$(OUT_BIN)

debug: $(OUT_DIR)
	$(NASM) -f elf64 -g -F dwarf $(ASM_SRC) -o $(OUT_DIR)/tictactoe.o
	$(LD) -o $(OUT_BIN) $(OUT_DIR)/tictactoe.o
	gdb $(OUT_BIN)
