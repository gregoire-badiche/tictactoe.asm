%ifndef __TICTACTOE_ASM__
%define __TICTACTOE_ASM__

; %include "src/grid.asm"
; %include "src/io.asm"

; Args : x (64 bits reg), y (64 bits reg), v (8 bits reg)
%macro set_case 3
    ; push rcx
    mov rcx, %2
    imul rcx, rcx, 3
    add rcx, %1
    mov [cases + rcx], %3
    ; pop rcx
%endmacro

%macro get_case 3
    ; push rcx
    xor rax, rax
    mov rcx, %3
    imul rcx, rcx, 3
    add rcx, %2
    mov %1, [cases + rcx]
    ; pop rcx
%endmacro

%macro read 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro write 2
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; stdout
    mov rsi, %1 ; message
    mov rdx, %2 ; len
    syscall
%endmacro

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

get_input_text db " 's turn, please enter some coordinates : "
get_input_text_len equ $ - get_input_text

input_not_valid_text db "Please enter some valid coordinates : "
input_not_valid_text_len equ $ - input_not_valid_text

case_already_taken_text db "This case is already taken. Please select a free one : "
case_already_taken_text_len equ $ - case_already_taken_text

section .text
global _start

_start: ;
    ; --------------------------------
    ; display grid
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

    ; Achtually display the grid
    write grid, grid_len
    ; --------------------------------
    ; display who's turn and asks for input
    xor rax, rax
    mov al, [current_player]
    mov al, [characters + rax]
    mov byte [get_input_text], al
    write get_input_text, get_input_text_len
get_input: ; gets the input, valdates it and flushes stdin
    xor rax, rax
    xor rdi, rdi
    mov rsi, player_selection
    mov rdx, 2
    syscall
.flush:
    xor rax, rax
    mov rsi, character
    mov rdx, 1
    syscall
    cmp byte al, 0 ; check for EOF
    je .end_flush
    cmp byte [character], 10 ; check for new line
    jne .flush
.end_flush:
    xor rax, rax
    xor rbx, rbx
    mov al, [player_selection]
    mov bl, [player_selection + 1]
    cmp al, byte 97 ; a = 97, c = 99, 1 = 49, 3 = 51
    jl input_not_valid
    cmp al, byte 99
    jg input_not_valid
    cmp bl, byte 49
    jl input_not_valid
    cmp bl, byte 51
    jg input_not_valid
    sub al, 97
    sub bl, 49
    ; yepeee, the input is valid !!
    ; checking if the case is not already used
    imul rdx, rax, 3
    add rdx, rbx
    mov cl, [cases + rdx]
    cmp cl, 0
    jne case_already_taken
    ; if not,
    ; We change the selected case
    mov dl, [current_player]
    set_case rax, rbx, dl ; TODO : unwind the macro 
    xor rax, rax
    mov al, [n_turns]

    ; switch_players
    inc al
    mov [n_turns], al ; increases the number of turns

    and al, 0x01
    inc al
    mov [current_player], al
    jmp _start
exit:
    ; xor rax, rax ; Set rax to 0
    mov rax, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

input_not_valid:
    write input_not_valid_text, input_not_valid_text_len
    jmp get_input
case_already_taken:
    write case_already_taken_text, case_already_taken_text_len
    jmp get_input

section .bss
player_selection resb 2
character resb 1
n_turns resb 1
cases resb 9

%endif
