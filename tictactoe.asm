section .data

.characters:
    db 0x20 ; space
    db 0x58 ; X
    db 0x4F ; O
.grid:
    db "   |   |   ", 0x0A
    db "---+---+---", 0x0A
    db "   |   |   ", 0x0A
    db "---+---+---", 0x0A
    db "   |   |   ", 0x0A
.grid_len equ $ - .grid

section .text
global _start

_start:
.display:
    mov rcx, 2
.set_cases: ; loop + unwinding
    xor rdx, rdx
    mov r9, rcx
    mov dl, [.cases + r9]
    mov dl, [.characters + rdx]
    imul r8, rcx, 4
    inc r8
    mov [.grid + r8], dl

    add r9, 3
    mov dl, [.cases + r9]
    mov dl, [.characters + rdx]
    add r8, 24
    mov [.grid + r8], dl

    add r9, 3
    mov dl, [.cases  + r9]
    mov dl, [.characters + rdx]
    add r8, 24
    mov [.grid + r8], dl
    dec rcx
    jns .set_cases
.display_grid:
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; stdout
    mov rsi, .grid ; message
    mov rdx, .grid_len ; len
    syscall
.exit:
    xor rax, rax ; Set rax to 0
    mov al, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

section .bss
; array of vals
.cases:
    resb 9
