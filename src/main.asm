    %include "c.inc"
    %include "http.inc"

    %define REQUEST_BUFFER_CAPACITY 8192

    SECTION .data

printf_string:
    db "%s", 10, 0
printf_int:
    db "%d", 10, 0

signal_handler_message:
    db "The application was interrupted by a user...", 10, 0
client_socket_error:
    db "Error during reading from the client socket", 10, 0
socket_result_error:
    db "Could not create a server socket", 10, 0
inet_aton_result_error:
    db "Internet address is not correct: %s", 10, 0
bind_result_error:
    db "Could not bind address %s:%d", 10, 0
listen_result_error:
    db "Could not listen on the socket", 10, 0

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

html_content_type:
    db "text/html", 0
css_content_type:
    db "text/css", 0

;;; TODO(#55): Serve 404 response from a file instead of hardcoded content
http_404:
    db "HTTP/1.1 404 Not found", 13, 10
    db "Content-Type: text/plain", 13, 10
    db "Content-Length: 9", 13, 10
    db 13, 10
    db "NOT FOUND", 0
index_route:    db "/", 0
css_route:  db "/main.css", 0
reuseaddr_enabled:
    dd 1
index_html_file:
    db "./static/index.html", 0
main_css_file:
    db "./static/main.css", 0

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
current_route:
    resq 1
request_buffer:
    resb REQUEST_BUFFER_CAPACITY
request_buffer_size:
    resq 1
request_parsing_ptr:
    resq 1
request_uri_end:
    resq 1
prev_byte:
    resb 1
interrupted:
    resb 1

    SECTION .text
    global main

main:
    push rbp

    mov [argc], rdi
    mov [argv], rsi

    mov rdi, SIGINT
    mov rsi, signal_handler
    call signal

    cmp qword [argc], 2
    jge .args_check
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
.args_check:
    mov rdi, [argv]
    mov rdi, [rdi + 8]
    call atoi
    mov [port], rax

;;; server_socket = socket(AF_INET, SOCK_STREAM, 0)
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    or rsi, SOCK_NONBLOCK
    mov rdx, 0
    call socket
    mov [server_socket], rax
;;; ---

;;; setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &reuseaddr_enabled, 4)
    mov rdi, [server_socket]
    mov rsi, SOL_SOCKET
    mov rdx, SO_REUSEADDR
    mov rcx, reuseaddr_enabled
    mov r8, 4
    call setsockopt
;;; --

    cmp rax, 0
    jge .socket_result_check

    mov rdi, 2
    mov rsi, socket_result_error
    call dprintf
    jmp .end

.socket_result_check:

;;; port = htons(server_addr.sin_port)
    mov rdi, [port]
    call htons
    mov [server_addr + sockaddr_in.sin_port], rax
;;; ---

;;; inet_aton(ip_address, &server_addr.sin_addr)
    mov rdi, ip_address
    mov rsi, server_addr + sockaddr_in.sin_addr
    call inet_aton
;;; ---

    cmp rax, 0
    jne .inet_aton_result_check

    mov rdi, 2
    mov rsi, inet_aton_result_error
    mov rdx, ip_address
    call dprintf
    jmp .end

.inet_aton_result_check:

;;; bind(server_socket, &server_addr, 16)
    mov rdi, [server_socket]
    mov rsi, server_addr
    mov rdx, 16
    call bind
;;; ---

    cmp rax, 0
    je .bind_result_check

    mov rdi, 2
    mov rsi, bind_result_error
    mov rdx, ip_address
    mov rcx, [port]
    call dprintf
    jmp .end

.bind_result_check:

;;; listen(server_socket, 50)
    mov rdi, [server_socket]
    mov rsi, 50
    call listen
;;; ---

    cmp rax, 0
    je .listen_result_check

    mov rdi, 2
    mov rsi, listen_result_error
    call dprintf
    jmp .end

.listen_result_check:

    mov rdi, server_started_message
    mov rsi, [port]
    mov rax, 0
    call printf

    ;; TODO(#9): safely quit on SIGINT
.loop:
    mov rdi, [server_socket]
    mov rsi, client_addr
    mov rdx, client_addr_size
    call accept

    cmp rax, 0
    jl .loop_end

    mov [client_socket], rax

;;; printf(html_served_message, inet_ntoa(client_addr.sin_addr))
    mov rdi, [client_addr + sockaddr_in.sin_addr]
    call inet_ntoa

    mov rdi, html_served_message
    mov rsi, rax
    mov rax, 0
    call printf
;;; --

;;; request_buffer_size = read(client_socket, request_buffer, REQUEST_BUFFER_CAPACITY)
    mov rdi, [client_socket]
    mov rsi, request_buffer
    mov rdx, REQUEST_BUFFER_CAPACITY
    call read
    mov [request_buffer_size], rax
;;; --

;;; request_buffer[request_buffer_size] = 0
    mov rax, [request_buffer_size]
    mov byte [request_buffer + rax], 0
;;; --

;;; request_parsing_ptr = request_buffer
    mov qword [request_parsing_ptr], request_buffer
;;; --

;;; request_parsing_ptr = drop_sp(request_parsing_ptr)
    mov rdi, [request_parsing_ptr]
    call drop_sp
    mov [request_parsing_ptr], rax
;;; --

;;; request_parsing_ptr = parse_method(request_parsing_ptr)
    mov rdi, [request_parsing_ptr]
    call parse_method
    mov [request_parsing_ptr], rax
;;; --

;;; request_parsing_ptr = drop_sp(request_parsing_ptr)
    mov rdi, [request_parsing_ptr]
    call drop_sp
    mov [request_parsing_ptr], rax
;;; --

;;; request_uri_end = parse_request_uri(request_parsing_ptr)
    mov rdi, [request_parsing_ptr]
    call parse_request_uri
    mov [request_uri_end], rax
;;; --

;;; prev_byte = *request_uri_end
    mov rax, [request_uri_end]
    mov al, [rax]
    mov byte [prev_byte], al
;;; --

;;; *request_uri_end = 0
    mov rax, [request_uri_end]
    mov byte [rax], 0
;;; ---

    mov rdi, [request_parsing_ptr]
    mov rsi, index_route
    call strcmp
    cmp rax, 0
    jne .check_css_route

;;; http_serve_file(client_socket, html_content_type, index_html_file)
    mov rdi, [client_socket]
    mov rsi, html_content_type
    mov rdx, index_html_file
    call http_serve_file
;;; ---

    jmp .close_socket

.check_css_route:
    mov rdi, [request_parsing_ptr]
    mov rsi, css_route
    call strcmp
    cmp rax, 0
    jne .not_found

;;; http_serve_file(client_socket, css_content_type, main_css_file)
    mov rdi, [client_socket]
    mov rsi, css_content_type
    mov rdx, main_css_file
    call http_serve_file
;;; ---

    jmp .close_socket

.not_found:
;;; dprintf(client_socket, http, css_size, css)
    mov rdi, [client_socket]
    mov rsi, http_404
    mov rax, 0
    call dprintf
;;; --

.close_socket:
    mov rdi, [client_socket]
    call close

.loop_end:
    mov rdi, 10
    call usleep
    cmp byte [interrupted], 0
    je .loop

    mov rdi, [server_socket]
    call close

.end:
    pop rbp

    mov rax, 0
    ret

signal_handler:
    push rbp

    mov rdi, signal_handler_message
    call printf

    mov byte [interrupted], 1

    pop rbp
    ret
