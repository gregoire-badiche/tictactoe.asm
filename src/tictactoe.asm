%ifndef __TICTACTOE_ASM__
%define __TICTACTOE_ASM__

%include "src/grid.asm"

section .data

section .text
global _start

_start: ;
    set_case 1, 1, byte 2
    call display_grid
.exit:
    xor rax, rax ; Set rax to 0
    mov al, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

section .bss

%endif
