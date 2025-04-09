%ifndef __IO_ASM__
%define __IO_ASM__

section .data

section .text

%macro read 2
    mov rax, 3
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

section .bss

%endif
