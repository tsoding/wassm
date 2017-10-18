    ;; -*- mode: asm -*-
    SECTION .data
    SECTION .text
    global route_from_line
    global drop_sp
    global parse_method
    global parse_request_uri
drop_sp:
    mov rax, rdi
    ret
parse_method:
    mov rax, rdi
    ret
parse_request_uri:
    mov rax, rdi
    ret
