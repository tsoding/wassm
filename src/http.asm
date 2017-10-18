    ;; -*- mode: asm -*-
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
    ;; TODO: implement parse_method function
    mov rax, rdi
    ret
parse_request_uri:
    ;; TODO: implement parse_request_uri function
    mov rax, rdi
    ret
