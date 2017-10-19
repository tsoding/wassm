;;; -*- mode: nasm -*-
    SECTION .data
    SECTION .text
    global route_from_line
    global drop_sp
    global parse_method
    global parse_request_uri
drop_sp:
    ;; TODO(#38): Implement drop_sp function
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
