#!/bin/sh
nasm -f elf64 -g -F dwarf tictactoe.asm && 
ld tictactoe.o -o tictactoe &&
gdb ./tictactoe