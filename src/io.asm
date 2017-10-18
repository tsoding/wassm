    ;; -*- mode: asm -*-
    %include "c.inc"
    SECTION .data
hello_world:    db "read_line_fd: Unimplemented", 10, 0

    SECTION .text
    global read_line_fd
read_line_fd:
    push rbp
    mov rbp, rsp

    ;; TODO(#26): implement read_line_fd
    ;;
    ;; This function takes a file descriptor and returns next line from it.
    ;; The returned string should freed manually
    mov rdi, hello_world
    mov rax, 0
    call printf
    ret
