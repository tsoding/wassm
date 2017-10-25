%include "c.inc"
%include "http_test.inc"
%define EXPECTED_TEST_COUNT 3

SECTION .data

splash_fmt:
    db "Running unit tests...", 10, 0
passed_tests_fmt:
    db "Passed tests: %d/%d", 10, 0

SECTION .bss
counter: resq 1

SECTION .text

global main

main:
    push rbp

    mov rdi, splash_fmt
    mov rax, 0
    call printf

    call drop_sp_test
    cmp rax, 0
    jne .end
    inc qword [counter]

    call parse_method_test
    cmp rax, 0
    jne .end
    inc qword [counter]

    call parse_request_uri_test
    cmp rax, 0
    jne .end
    inc qword [counter]

.end:

    mov rdi, passed_tests_fmt
    mov rsi, [counter]
    mov rdx, EXPECTED_TEST_COUNT
    mov rax, 0
    call printf

    cmp qword [counter], EXPECTED_TEST_COUNT
    je .passed

    pop rbp
    mov rax, 1
    ret

.passed:
    pop rbp
    mov rax, 0
    ret
