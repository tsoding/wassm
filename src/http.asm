;;; -*- mode: nasm -*-
    SECTION .data
    SECTION .text
    global drop_sp
    global parse_method
    global parse_request_uri

drop_sp:
    cmp byte [rdi], 0x20
    jne .end

    inc rdi

    jmp drop_sp

.end:
    mov rax, rdi
    ret

parse_method:
    ;; TODO(#39): Implement parse_method function
    mov rax, rdi
    ret
parse_request_uri:
    ;; TODO(#40): Implement parse_request_uri function
    mov rax, rdi
    ret
