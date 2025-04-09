%ifndef __GRID_ASM__
%define __GRID_ASM__

%include "src/io.asm"

section .data

characters:
    db 0x20 ; space
    db 0x58 ; X
    db 0x4F ; O
current_player db 0

grid:
    db "   1   2   3 ", 0x0A ; len 14
    db "a    |   |   ", 0x0A
    db "  ---+---+---", 0x0A
    db "b    |   |   ", 0x0A
    db "  ---+---+---", 0x0A
    db "c    |   |   ", 0x0A
grid_len equ $ - grid

section .text

; Args : x (64 bits reg), y (64 bits reg), v (8 bits reg)
%macro set_case 3
    push rcx
    mov rcx, %2
    imul rcx, rcx, 3
    add rcx, %1
    mov [cases + rcx], %3
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

play_turn: ; rbx rcx
    xor rax, rax
    mov al, [current_player]

    ; switch_players
    inc al
    and al, 0x01
    mov [current_player], al
    ret
display_grid:
    push rax
    push rcx
    push rdx
    push rsi
    xor rax, rax
    mov rcx, 2 ; loop counter
.set_cases: ; loop + unwinding, setting the grid
    xor rdx, rdx
    mov rsi, rcx
    mov dl, [cases + rsi]
    mov dl, [characters + rdx]
    imul rax, rcx, 4
    add rax, 17
    mov [grid + rax], dl

    add rsi, 3
    mov dl, [cases + rsi]
    mov dl, [characters + rdx]
    add rax, 28
    mov [grid + rax], dl

    add rsi, 3
    mov dl, [cases + rsi]
    mov dl, [characters + rdx]
    add rax, 28
    mov [grid + rax], dl

    dec rcx
    jns .set_cases ; jump back (loop)

    ; display the grid
    write grid, grid_len
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
