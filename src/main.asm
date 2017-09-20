    struc sockaddr_in
    .sin_family: resw 1
    .sin_port: resw 1
    .sin_addr: resd 1
    .sin_zero: resq 1
    endstruc

    %define AF_INET 2
    %define SOCK_STREAM 1

    extern printf
    extern dprintf
    extern atoi
    extern socket
    extern htons
    extern inet_aton
    extern bind
    extern close

    SECTION .data

program_name:
    db "Program name: %s", 10, 0
number:
    db "Number: %d", 10, 0
usage:
    db "Usage: webapp <port>", 10, 0
ip_address:
    db "0.0.0.0", 0
server_addr:
    istruc sockaddr_in
    at sockaddr_in.sin_family, dw AF_INET
    at sockaddr_in.sin_port, dw 0
    at sockaddr_in.sin_addr, dd 0
    at sockaddr_in.sin_zero, dq 0
    iend
server_addr_size:

    SECTION .php
    SECTION .bss
argc:
    resq 1
argv:
    resq 1
port:
    resq 1
server_socket:
    resq 1

    SECTION .text
    global main

main:
    push rbp

    mov [argc], rdi
    mov [argv], rsi

    cmp qword [argc], 2
    jge args_check
    ;; if argc < 2 then
    ;; begin
    mov rdi, 2
    mov rsi, usage
    call dprintf

    pop rbp
    mov rax, 1
    ret
    ;; end
args_check:

    mov rdi, [argv]
    mov rdi, [rdi + 8]
    call atoi
    mov [port], rax

    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    call socket
    mov [server_socket], rax
    ;; TODO: handle error in creating a socket

    mov rdi, [port]
    call htons
    mov [server_addr + sockaddr_in.sin_port], rax

    mov rdi, ip_address
    mov rsi, server_addr + sockaddr_in.sin_addr
    call inet_aton

    mov rdi, [server_socket]
    mov rsi, server_addr
    mov rdx, 16
    call bind

    mov rdi, [server_socket]
    call close

    pop rbp

    mov rax, 0
    ret
