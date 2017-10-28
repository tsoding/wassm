%include "c.inc"
%include "http.inc"

SECTION .data

drop_sp_test_fmt:
    db "  Running drop_sp_test...", 10, 0
parse_method_test_fmt:
    db "  Running parse_method_test...", 10, 0
parse_request_uri_test_fmt:
    db "  Running parse_request_uri_test...", 10, 0

drop_sp_test_failed_fmt:
    db "    Dropped %d spaces instead of 5", 10, 0
parse_failed_fmt:
    db "    Parsed %d characters, but expect %d", 10, 0

drop_sp_test_data:
    db "     khooy", 0
parse_method_test_data:
    db "GET khooy"
parse_request_uri_test_data:
    db "/khooy/test?arg1=foo&arg2=bar  fsdjkf", 10, 0

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
    je .passed

    mov rdi, drop_sp_test_failed_fmt
    mov rsi, rax
    sub rsi, drop_sp_test_data
    call printf

    pop rbp
    mov rax, 1
    ret

.passed:
    pop rbp
    mov rax, 0
    ret

parse_method_test:
    push rbp

    mov rdi, parse_method_test_fmt
    call printf

    mov rdi, parse_method_test_data
    call parse_method

    cmp rax, parse_method_test_data + 3
    je .passed

    mov rdi, 2
    mov rsi, parse_failed_fmt
    mov rdx, rax
    sub rdx, parse_method_test_data
    mov rcx, 3
    call dprintf

    pop rbp
    mov rax, 1
    ret

.passed:
    pop rbp
    mov rax, 0
    ret

parse_request_uri_test:
    push rbp

    mov rdi, parse_request_uri_test_fmt
    call printf

    mov rdi, parse_request_uri_test_data
    call parse_request_uri

    cmp rax, parse_request_uri_test_data + 29
    je .passed

    mov rdi, 2
    mov rsi, parse_failed_fmt
    mov rdx, rax
    sub rdx, parse_request_uri_test_data
    mov rcx, 29
    call dprintf

    pop rbp
    mov rax, 1
    ret

.passed:
    pop rbp
    mov rax, 0
    ret
