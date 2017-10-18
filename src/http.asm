    ;; -*- mode: asm -*-
    SECTION .data
route:
    db "/", 0
    SECTION .text
    global route_from_line
    global drop_sp
    global parse_method
    global parse_request_uri
    ;; route_from_line should deallocate input string
route_from_line:
    ;; TODO(#27): Implement route_from_line
    ;;
    ;; This function takes a string that represents a status line of an HTTP request and
    ;; returns the route of the request. It also frees the input string. The output string should be
    ;; freed by the caller
    mov rax, route
    ret
drop_sp:
    mov rax, rdi
    ret
parse_method:
    mov rax, rdi
    ret
parse_request_uri:
    mov rax, rdi
    ret
