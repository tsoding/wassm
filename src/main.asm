    extern printf
    extern dprintf
    extern atoi

    SECTION .data

program_name:
    db "Program name: %s", 10, 0
number:
    db "Number: %d", 10, 0
usage:
    db "Usage: webapp <port>", 10, 0

    SECTION .php
    SECTION .bss
argc:
    resq 1
argv:
    resq 1
port:
    resq 1

    SECTION .text
    global main

main:
    push rbp

    mov [argc], rdi
    mov [argv], rsi

    cmp qword [argc], 2
    jge args_check
    ;; if argc < 2 then
    ;; begin
    mov rdi, 2
    mov rsi, usage
    call dprintf

    pop rbp
    mov rax, 1
    ret
    ;; end
args_check:

    mov rdi, [argv]
    mov rdi, [rdi + 8]
    call atoi

    pop rbp

    mov rax, 0
    ret
