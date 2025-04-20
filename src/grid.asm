%ifndef __GRID_ASM__
%define __GRID_ASM__

%include "src/io.asm"

section .data

characters:
    db 0x20 ; space
    db 0x58 ; X
    db 0x4F ; O
current_player db 1

grid:
    db "   a   b   c ", 0x0A ; len 14
    db "1    |   |   ", 0x0A
    db "  ---+---+---", 0x0A
    db "2    |   |   ", 0x0A
    db "  ---+---+---", 0x0A
    db "3    |   |   ", 0x0A
grid_len equ $ - grid

message_turn db " 's turn", 0x0A
message_turn_len equ $ - message_turn

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

change_turn: ; rbx rcx
    xor rax, rax
    mov al, [n_turns]

    ; switch_players
    inc al
    mov [n_turns], al ; increases the number of turns

    and al, 0x01
    mov [current_player], al
    ret
display_grid:
    ;push rax
    ;push rcx
    ;push rdx
    ;push rsi
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
    ;pop rsi
    ;pop rdx
    ;pop rcx
    ;pop rax
display_whos_turn:
    xor rax, rax
    mov al, [current_player]
    mov al, [characters + rax]
    mov byte [message_turn], al
    write message_turn, message_turn_len
    ret

section .bss
; array of vals
n_turns resb 1
cases:
    resb 9

%endif
