#!/bin/sh
nasm -f elf64 tictactoe.asm && 
ld -s -no-pie -z noseparate-code tictactoe.o -o tictactoe &&
rm tictactoe.o &&
./tictactoe