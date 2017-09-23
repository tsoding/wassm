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
    extern inet_ntoa
    extern bind
    extern close
    extern listen
    extern accept
    extern dprintf
    extern strlen
    extern read

    SECTION .data

printf_string:
    db "%s", 10, 0
server_started_message:
    db "The server was started on port %d", 10, 0
html_served_message:
    db "Served Cyka Blyat to %s", 10, 0
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
client_addr:
    istruc sockaddr_in
    at sockaddr_in.sin_family, dw 0
    at sockaddr_in.sin_port, dw 0
    at sockaddr_in.sin_addr, dd 0
    at sockaddr_in.sin_zero, dq 0
    iend
client_addr_size:
    dd 16
html:
    db "<!DOCTYPE html>", 10
    db "<html>", 10
    db "  <head>", 10
    db "    <title>Hello, World</title>", 10
    db "  </head>", 10
    db "  <body>", 10
    db "    <h1>Cyka, blyat!</h1>", 10
    db "    <h2>Rush B</h2>", 10
    db "  </body>", 10
    db "</html>", 10, 0
html_size:
    dq 0
http:
    db "HTTP/1.1 200 OK", 13, 10
    db "Content-Type: text/html", 13, 10
    db "Content-Length: %d", 13, 10
    db 13, 10
    db "%s", 0

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
client_socket:
    resq 1
request_buffer:
    resb 256
request_buffer_size:    equ $-request_buffer-1

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
    mov rax, 0
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
    mov rsi, 50
    call listen

    mov rdi, server_started_message
    mov rsi, [port]
    mov rax, 0
    call printf

    ;; TODO(#9): safely quit on SIGINT
loop:
    mov rdi, [server_socket]
    mov rsi, client_addr
    mov rdx, client_addr_size
    call accept
    mov [client_socket], rax

;; printf(html_served_message, inet_ntoa(client_addr.sin_addr))
    mov rdi, [client_addr + sockaddr_in.sin_addr]
    call inet_ntoa

    mov rdi, html_served_message
    mov rsi, rax
    mov rax, 0
    call printf
;; --

    mov rdi, html
    call strlen
    mov [html_size], rax

;; n = read(client_socket, &request_buffer, request_buffer_size)
;; request_buffer[n] = 0A
    mov rdi, [client_socket]
    mov rsi, request_buffer
    mov rdx, request_buffer_size
    call read
    mov byte [request_buffer + rax], 0
    ;; TODO: check if read returns -1 and report an error
;; --

;; printf("%s\n", request_buffer)
    mov rdi, printf_string
    mov rsi, request_buffer
    mov rax, 0
    call printf
;; --

;; dprintf(client_socket, http, html_size, html)
    mov rdi, [client_socket],
    mov rsi, http
    mov rdx, [html_size]
    mov rcx, html
    mov rax, 0
    call dprintf
;; --

    mov rdi, [client_socket]
    call close

    jmp loop

    mov rdi, [server_socket]
    call close

    pop rbp

    mov rax, 0
    ret
