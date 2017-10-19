;;; -*- mode: nasm -*-

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
    extern strcmp
    extern read

    struc sockaddr_in
    .sin_family: resw 1
    .sin_port: resw 1
    .sin_addr: resd 1
    .sin_zero: resq 1
    endstruc

    %define AF_INET 2
    %define SOCK_STREAM 1
