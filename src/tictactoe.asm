%ifndef __TICTACTOE_ASM__
%define __TICTACTOE_ASM__

%include "src/grid.asm"

section .data

section .text
global _start

_start:
    mov rax, 2
    set_case 1, 1, rax
    call display_grid
.exit:
    xor rax, rax ; Set rax to 0
    mov al, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

section .bss

%endif
