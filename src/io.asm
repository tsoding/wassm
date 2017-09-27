    ;; -*- mode: asm -*-
    %include "c.hsm"
    SECTION .data
hello_world:    db "read_line_fd", 10, 0

    SECTION .text
    global read_line_fd
read_line_fd:
    mov rdi, hello_world
    mov rax, 0
    call printf
    ret
