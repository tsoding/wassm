%include "c.inc"

;;; -*- mode: nasm -*-
SECTION .data

;;; https://www.ietf.org/rfc/rfc2396.txt
non_alnum_uri_chr:
    db ";/?:@&=+$,"             ;reserved
    db "-_.!~*'()"              ;unreserved
    db "%", 0                   ;escaped
http:
    db "HTTP/1.1 200 OK", 13, 10
    db "Content-Type: %s", 13, 10
    db "Content-Length: %d", 13, 10
    db 13, 10, 0

SECTION .text
global drop_sp
global parse_method
global parse_request_uri
global http_serve_file
global file_size

is_uri_char:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp - 8], rdi

    call isalnum
    cmp rax, 0
    jne .end

    mov rdi, non_alnum_uri_chr
    mov rsi, [rbp - 8]
    call strchr

.end:
    mov rsp, rbp
    pop rbp
    ret

drop_sp:
    cmp byte [rdi], 0x20
    jne .end

    inc rdi

    jmp drop_sp

.end:
    mov rax, rdi
    ret

parse_method:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp - 8], rdi

.loop:
    mov rdi, [rbp - 8]
    movzx rdi, byte [rdi]
    call isalpha

    cmp rax, 0
    je .end

    inc qword [rbp - 8]
    jmp .loop

.end:
    mov rax, [rbp - 8]
    mov rsp, rbp
    pop rbp
    ret

parse_request_uri:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp - 8], rdi

.loop:
    mov rdi, [rbp - 8]
    movzx rdi, byte [rdi]
    call is_uri_char

    cmp rax, 0
    je .end

    inc qword [rbp - 8]
    jmp .loop

.end:
    mov rax, [rbp - 8]
    mov rsp, rbp
    pop rbp
    ret

file_size:
    push rbp

    mov rbp, rsp
    sub rsp, 32
    mov [rbp - 8], rdi          ; fd
    mov qword [rbp - 16], 0     ; current_offset
    mov qword [rbp - 24], 0     ; file_size

    mov rdi, [rbp - 8]
    mov rsi, 0
    mov rdx, SEEK_CUR
    call lseek
    cmp rax, 0
    jl .failed
    mov [rbp - 16], rax

    mov rdi, [rbp - 8]
    mov rsi, 0
    mov rdx, SEEK_END
    call lseek
    cmp rax, 0
    jl .failed
    mov [rbp - 24], rax

    mov rdi, [rbp - 8]
    mov rsi, [rbp - 16]
    mov rdx, SEEK_SET
    call lseek
    cmp rax, 0
    jl .failed

    mov rax, [rbp - 24]

    mov rsp, rbp
    pop rbp
    ret

.failed:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret


http_serve_file:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp - 8], rdi          ; socket_fd
    mov [rbp - 16], rsi         ; content_type
    mov [rbp - 24], rdx         ; file_path
    mov qword [rbp - 32], 0     ; file_fd
    mov qword [rbp - 40], 0     ; file_size

;;; file_fd = open(file_path, O_RDONLY);
    mov rdi, [rbp - 24]
    mov rsi, O_RDONLY
    call open
    mov [rbp - 32], rax
    cmp rax, 0
    jl .failed
;;; --

;;; file_size = file_size(file_fd)
    mov rdi, [rbp - 32]
    call file_size
    cmp rax, 0
    jl .failed
    mov [rbp - 40], rax
;;; --



;;; dprintf(file_fd, http, content_type, file_size)
    mov rdi, [rbp - 8]
    mov rsi, http
    mov rdx, [rbp - 16]
    mov rcx, [rbp - 40]
    mov rax, 0
    call dprintf
    cmp rax, 0
    jl .failed
;;; --

;;; TODO(#53): Employ TCP_CORK option (see man 2 sendfile NOTES section)
;;; sendfile(socket_fd, file_fd, NULL, file_size);
    mov rdi, [rbp - 8]
    mov rsi, [rbp - 32]
    mov rdx, 0
    mov rcx, [rbp - 40]
    call sendfile
    cmp rax, 0
    jl .failed
    ; TODO: retry if sendfile has written fewer bytes then requested
;;; --

;;; close(file_fd)
    mov rdi, [rbp - 32]
    call close
    cmp rax, 0
    jl .failed
;;; --

    mov rsp, rbp
    pop rbp
    ret

.failed:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
