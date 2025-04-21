%ifndef __TICTACTOE_ASM__
%define __TICTACTOE_ASM__

; %include "src/grid.asm"
; %include "src/io.asm"

; Args : x (64 bits reg), y (64 bits reg), v (8 bits reg)
%macro set_case 3
    mov rcx, %2
    imul rcx, rcx, 3
    add rcx, %1
    mov [cases + rcx], %3
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

tie_text db "That's a tie", 0x0A
tie_text_len equ $ - tie_text

win_text db "Victory for  !", 0x0A
win_text_len equ $ - win_text

section .text
global _start

_start:
    ; Achtually display the grid
    write grid, grid_len

    ; display who's turn and asks for input
    xor rax, rax
    mov al, [current_player]
    mov al, [characters + rax]
    mov byte [get_input_text], al
    write get_input_text, get_input_text_len
get_input: ; using rax, rbx, rsi, rdi, 
    ; gets the input, valdates it and flushes stdin
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
check_case_valid: ; using rax, rbx, rcx, rdx
    imul rdx, rbx, 3
    add rdx, rax
    mov cl, [cases + rdx]
    cmp cl, 0
    jne case_already_taken
    ; if not, we change the selected case
    mov dl, [current_player]
    ; Sets case in the case grid
    mov rcx, rbx
    imul rcx, rcx, 3
    add rcx, rax
    mov [cases + rcx], dl
    ; Sets the case in the displayed string
    inc rax
    imul rax, rax, 4
    imul rbx, rbx, 28
    add rbx, 13
    add rax, rbx
    mov dl, [characters + rdx]
    mov [grid + rax], dl

    mov byte [current_player], 2
    call minimax_max
    mov byte [cases + rbx], 2

    mov rax, rbx
    xor rbx, rbx
.modulo:
    cmp rax, 3
    jl .end_modulo
    inc rbx
    sub rax, 3
    jmp .modulo
.end_modulo:
    ; Sets the case in the displayed string
    mov rdx, 2
    inc rax
    imul rax, rax, 4
    imul rbx, rbx, 28
    add rbx, 13
    add rax, rbx
    mov dl, [characters + rdx]
    mov [grid + rax], dl

    mov al, [n_turns]
    inc al
    mov [n_turns], al

    ; Check for a win
    call check_win
    cmp rax, 1
    je win
end_turn:
    ; switch_players and increments turn counter
    xor rax, rax
    mov al, [n_turns]
    inc al
    cmp al, 9
    je tie
    mov [n_turns], al ; increases the number of turns

    and al, 0x01 ; we take the parity of the n of turns, 0 = X, 1 = O
    inc al ; increments as X = 1 and 0 = 2
    mov [current_player], al
    jmp _start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; useful jumps

input_not_valid:
    write input_not_valid_text, input_not_valid_text_len
    jmp get_input
case_already_taken:
    write case_already_taken_text, case_already_taken_text_len
    jmp get_input

win: ; player win in cl, or assume current player won
    mov bl, [current_player]
    write grid, grid_len
    mov bl, [characters + rbx]
    mov [win_text + 12], bl
    write win_text, win_text_len
    jmp exit

tie:
    write grid, grid_len
    write tie_text, tie_text_len
    jmp exit

exit:
    ; xor rax, rax ; Set rax to 0
    mov rax, 60 ; set rax to 60 (exit syscall)
    xor rdi, rdi ; set rdi to 0 (exit code 0)
    syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions

check_win: ; using rax, rbx, rcx, returns in rax, trashes rbx and rcx
    ; columns
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    mov cl, [current_player]
.l1:
    ; check rows
    mov bl, al
    cmp cl, [cases + rbx]
    jne .l2
    inc bl
    cmp cl, [cases + rbx]
    jne .l2
    inc bl
    cmp cl, [cases + rbx]
    je .win
    ; won !!
.l2:
    ; check columns
    mov bl, al
    cmp cl, [cases + rbx]
    jne .l3
    add bl, 3
    cmp cl, [cases + rbx]
    jne .l3
    add bl, 3
    cmp cl, [cases + rbx]
    je .win
.l3:
    ; increments counter
    inc al
    cmp al, 3
    jne .l1
    ; diagonal
    cmp cl, [cases]
    jne .l4
    cmp cl, [cases + 4]
    jne .l4
    cmp cl, [cases + 8]
    je .win
.l4:
    ; antidiagonal
    cmp cl, [cases + 2]
    jne .no_win
    cmp cl, [cases + 4]
    jne .no_win
    cmp cl, [cases + 6]
    jne .no_win
.win:
    mov rax, 1
    ret
.no_win:
    mov rax, 0
    ret

; stack :
; current_player, best_score, best_pos, loop_counter
minimax_max:
    call check_win
    cmp rax, 1
    je .immediate_return
    cmp byte [n_turns], 9
    je .return_zero

    ; for each possible case, 
    xor rdx, rdx
    xor rbx, rbx

    ; increases turn by 1
    mov bl, [current_player]
    push rbx ; save current_player
    mov bl, [n_turns]
    push rbx ; save n_turns
    inc bl
    mov [n_turns], bl
    and bl, 0x01
    inc bl
    mov [current_player], bl
    push -11 ; save best_score
    push -11 ; save best_pos
.loop:
    cmp byte [cases + rdx], 0
    jne .loop_end
    
    ; fake placing
    mov [cases + rdx], bl
    push rdx ; save loop_counter
    call minimax_min
    pop rdx ; retrieve loop_counter
    
    pop rbx ; retrieve best_pos
    pop rcx ; retrieve best_score
    ; remove fake placing
    mov byte [cases + rdx], 0
    cmp rcx, rax
    jg .loop_end_save ; if the score is greater, we save it
    mov rcx, rax
    mov rbx, rdx
.loop_end_save:
    push rcx ; save best_score
    push rbx ; save best_pos
.loop_end:
    
    mov bl, [current_player]
    inc rdx
    cmp rdx, 9
    jne .loop
    ; decrease n_turns
    mov bl, [n_turns]
    dec bl
    mov [n_turns], bl
    pop rbx ; retrieve best_pos
    pop rax ; retrieve best_score
    pop rdx ; retrieve n_turns
    mov [n_turns], dl
    pop rdx ; retrieve current_player
    mov [current_player], dl
    ret

.immediate_return:
    mov rax, 10
    sub rax, [n_turns]
    ret
.return_zero:
    xor rax, rax
    ret



minimax_min:
    call check_win
    cmp rax, 1
    je .immediate_return
    cmp byte [n_turns], 9
    je .return_zero

    ; for each possible case, 
    xor rdx, rdx
    xor rbx, rbx

    ; increases turn by 1
    mov bl, [current_player]
    push rbx ; save current_player
    mov bl, [n_turns]
    push rbx ; save n_turns
    inc bl
    mov [n_turns], bl
    and bl, 0x01
    inc bl
    mov [current_player], bl
    push 11 ; save best_score
    push 11 ; save best_pos
.loop:
    cmp byte [cases + rdx], 0
    jne .loop_end
    
    ; fake placing
    mov [cases + rdx], bl
    push rdx ; save loop_counter
    call minimax_max
    pop rdx ; retrieve loop_counter
    
    pop rbx ; retrieve best_pos
    pop rcx ; retrieve best_score
    ; remove fake placing
    mov byte [cases + rdx], 0
    cmp rcx, rax
    jl .loop_end_save ; if the score is smaller, we save it
    mov rcx, rax
    mov rbx, rdx
.loop_end_save:
    push rcx ; save best_score
    push rbx ; save best_pos
.loop_end:
    
    mov bl, [current_player]
    inc rdx
    cmp rdx, 9
    jne .loop
    ; decrease n_turns
    mov bl, [n_turns]
    dec bl
    mov [n_turns], bl
    pop rbx ; retrieve best_pos
    pop rax ; retrieve best_score
    pop rdx ; retrieve n_turns
    mov [n_turns], dl
    pop rdx ; retrieve current_player
    mov [current_player], dl
    ret

.immediate_return:
    mov rax, [n_turns]
    sub rax, 10
    ret
.return_zero:
    xor rax, rax
    ret

section .bss
player_selection resb 2
character resb 1
n_turns resb 1
cases resb 9

%endif
