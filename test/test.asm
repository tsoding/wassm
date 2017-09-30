    %include "c.inc"
    section .data
splash: db "Running unit tests...", 10, 0
    section .text
    global main
main:
    push rbp

    mov rdi, splash
    mov rax, 0
    call printf

    pop rbp
    mov rax, 0
    ret
