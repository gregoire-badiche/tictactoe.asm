section .data
extern characters
extern grid
extern grid_len

section .text
global _start
extern get_case
extern set_case
extern display_grid

_start:
    mov rdi, 1
    mov rsi, 1
    mov rdx, 1
    call set_case
    call display_grid
.exit:
    xor rax, rax ; Set rax to 0
    mov al, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

section .bss
extern cases
