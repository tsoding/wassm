%include "c.inc"

SECTION .data

drop_sp_test_fmt:
    db "  Running drop_sp_test...", 10, 0
parse_method_test_fmt:
    db "  Running parse_method_test...", 10, 0
parse_request_uri_test_fmt:
    db "  Running parse_request_uri_test_fmt...", 10, 0

SECTION .text

global drop_sp_test
global parse_method_test
global parse_request_uri_test

drop_sp_test:
    push rbp

    mov rdi, drop_sp_test_fmt
    call printf

    pop rbp
    mov rax, 0
    ret

parse_method_test:
    push rbp

    mov rdi, parse_method_test_fmt
    call printf

    pop rbp
    mov rax, 0
    ret

parse_request_uri_test:
    push rbp

    mov rdi, parse_request_uri_test_fmt
    call printf

    pop rbp
    mov rax, 0
    ret
