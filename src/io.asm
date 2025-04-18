%ifndef __IO_ASM__
%define __IO_ASM__

section .data

input_text:
    db "Please enter some coordinates : "
input_text_len equ $ - input_text

section .text

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

get_input: ; pushes y, x in the stack, returns error with rax
    write input_text, input_text_len
    xor rax, rax
    xor rdi, rdi
    mov rsi, .player_selection
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
    mov al, [.player_selection]
    mov bl, [.player_selection + 1]
    cmp al, byte 97 ; a = 97, c = 99, 1 = 49, 3 = 51
    jl .err
    cmp al, byte 99
    jg .err
    cmp bl, byte 49
    jl .err
    cmp bl, byte 51
    jg .err
    sub al, 97
    sub bl, 49
    ret ; success !!
.err:
    jmp get_input

section .bss

.player_selection resb 2
character resb 1

%endif
