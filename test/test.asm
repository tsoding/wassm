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
    jne main_end
    inc qword [counter]

    call parse_method_test
    cmp rax, 0
    jne main_end
    inc qword [counter]

    call parse_request_uri_test
    cmp rax, 0
    jne main_end
    inc qword [counter]

main_end:

    mov rdi, passed_tests_fmt
    mov rsi, [counter]
    mov rdx, EXPECTED_TEST_COUNT
    mov rax, 0
    call printf

    cmp qword [counter], EXPECTED_TEST_COUNT
    je main_passed

    pop rbp
    mov rax, 1
    ret

main_passed:
    pop rbp
    mov rax, 0
    ret
