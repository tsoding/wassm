%include "c.inc"

;;; -*- mode: nasm -*-
    SECTION .data
    SECTION .text
    global drop_sp
    global parse_method
    global parse_request_uri

is_uri_char:
    mov rax, 1
    cmp rdi, 0x20
    jne .end
    mov rax, 0
.end:
    ret

drop_sp:
    cmp byte [rdi], 0x20
    jne .end

    inc rdi

    jmp drop_sp

.end:
    mov rax, rdi
    ret

parse_method:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp - 8], rdi

.loop:
    mov rdi, [rbp - 8]
    movzx rdi, byte [rdi]
    call isalpha

    cmp rax, 0
    je .end

    inc qword [rbp - 8]
    jmp .loop

.end:
    mov rax, [rbp - 8]
    mov rsp, rbp
    pop rbp
    ret

parse_request_uri:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp - 8], rdi

.loop:
    mov rdi, [rbp - 8]
    movzx rdi, byte [rdi]
    call is_uri_char

    cmp rax, 0
    je .end

    inc qword [rbp - 8]
    jmp .loop

.end:
    mov rax, [rbp - 8]
    mov rsp, rbp
    pop rbp
    ret
