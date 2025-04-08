%ifndef __GRID_ASM__
%define __GRID_ASM__

section .data

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

%macro set_case 3
    push rcx
    mov rcx, %2
    imul rcx, rcx, 3
    add rcx, %1
    mov [cases + rcx], byte %3
    pop rcx
%endmacro

%macro get_case 3
    push rcx
    xor rax, rax
    mov rcx, %3
    imul rcx, rcx, 3
    add rcx, %2
    mov %1, [cases + rcx]
    pop rcx
%endmacro

display_grid:
    push rax
    push rcx
    push rdx
    push rsi
    xor rax, rax
    mov rcx, 2 ; loop counter
    xor rdx, rdx
    xor rsi, rsi
.set_cases: ; loop + unwinding, setting the grid
    mov rsi, rcx
    mov dl, [cases + rsi]
    mov dl, [characters + rdx]
    imul rax, rcx, 4
    inc rax
    mov [grid + rax], dl

    add rsi, 3
    mov dl, [cases + rsi]
    mov dl, [characters + rdx]
    add rax, 24
    mov [grid + rax], dl

    add rsi, 3
    mov dl, [cases  + rsi]
    mov dl, [characters + rdx]
    add rax, 24
    mov [grid + rax], dl
    dec rcx
    jns .set_cases ; jump back (loop)

    ; display the grid
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; stdout
    mov rsi, grid ; message
    mov rdx, grid_len ; len
    syscall
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

section .bss
; array of vals
cases:
    resb 9

%endif
