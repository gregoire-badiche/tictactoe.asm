%ifndef __TICTACTOE_ASM__
%define __TICTACTOE_ASM__

%include "src/grid.asm"
%include "src/io.asm"

section .data

section .text
global _start

_start: ;
    call display_grid
    call get_input ; rax, rbx now contains the coordinates
    mov dl, [current_player]
    inc dl
    set_case rax, rbx, dl
    call display_grid
    ; jmp _start
.exit:
    xor rax, rax ; Set rax to 0
    mov al, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

section .bss
.player_selection resb 2

%endif
