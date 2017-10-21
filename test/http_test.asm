%include "c.inc"
%include "http.inc"

SECTION .data

drop_sp_test_fmt:
    db "  Running drop_sp_test...", 10, 0
parse_method_test_fmt:
    db "  Running parse_method_test...", 10, 0
parse_request_uri_test_fmt:
    db "  Running parse_request_uri_test_fmt...", 10, 0

drop_sp_test_data:
    db "     khooy"
drop_sp_test_failed_fmt:
    db "    Droped %d spaces instead of 5", 10, 0

SECTION .text

global drop_sp_test
global parse_method_test
global parse_request_uri_test

drop_sp_test:
    push rbp

    mov rdi, drop_sp_test_fmt
    call printf

    mov rdi, drop_sp_test_data
    call drop_sp

    cmp rax, drop_sp_test_data + 5
    je drop_sp_test_passed

    mov rdi, drop_sp_test_failed_fmt
    mov rsi, rax
    sub rsi, drop_sp_test_data
    call printf

    pop rbp
    mov rax, 1
    ret

drop_sp_test_passed:
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
