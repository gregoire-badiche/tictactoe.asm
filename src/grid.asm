section .data
global characters
global grid
global grid_len

characters:
    db 0x20 ; space
    db 0x58 ; X
    db 0x4F ; O

grid:
    db "   |   |   ", 0x0A
    db "---+---+---", 0x0A
    db "   |   |   ", 0x0A
    db "---+---+---", 0x0A
    db "   |   |   ", 0x0A
grid_len equ $ - grid

section .text
global set_case
global get_case
global display_grid

set_case:
    imul si, si, 3
    add dil, sil
    mov [cases + rdi], dl
    ret

get_case:
    xor rax, rax
    imul si, si, 3
    add dil, sil
    mov rax, [cases + rdi]
    ret

display_grid:
    mov rcx, 2 ; loop counter
.set_cases: ; loop + unwinding, setting the grid
    xor rdx, rdx
    mov r9, rcx
    mov dl, [cases + r9]
    mov dl, [characters + rdx]
    imul r8, rcx, 4
    inc r8
    mov [grid + r8], dl

    add r9, 3
    mov dl, [cases + r9]
    mov dl, [characters + rdx]
    add r8, 24
    mov [grid + r8], dl

    add r9, 3
    mov dl, [cases  + r9]
    mov dl, [characters + rdx]
    add r8, 24
    mov [grid + r8], dl
    dec rcx
    jns .set_cases ; jump back (loop)

    ; display the grid
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; stdout
    mov rsi, grid ; message
    mov rdx, grid_len ; len
    syscall
    ret

section .bss
; array of vals
global cases
cases:
    resb 9
