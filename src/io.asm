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
    read .player_selection, 2
    xor rbx, rbx
    xor rcx, rcx
    mov bl, [.player_selection]
    mov cl, [.player_selection + 1]
    cmp bl, byte 97 ; a = 97, c = 99, 1 = 49, 3 = 51
    jl .err
    cmp bl, byte 99
    jg .err
    cmp cl, byte 49
    jl .err
    cmp cl, byte 51
    jg .err
    sub bl, 97
    sub cl, 49
    pop rdx
    push rcx
    push rbx
    mov rax, 1 ; success !!
    jmp rdx
.err:
    pop rdx
    xor rax, rax
    push rax ; dummy values
    push rax
    jmp rdx

section .bss

.player_selection resb 2

%endif
