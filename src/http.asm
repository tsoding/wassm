    ;; -*- mode: asm -*-
    SECTION .data
route:
    db "/", 0
    SECTION .text
    global route_from_line
    ;; route_from_line should deallocate input string
route_from_line:
    mov rax, route
    ret
