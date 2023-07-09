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
extern strlen
extern strcmp
extern read
extern isalpha
extern isalnum
extern strchr
extern signal
extern exit
extern setsockopt
extern open
extern lseek
extern sendfile
extern usleep

struc sockaddr_in
.sin_family: resw 1
.sin_port: resw 1
.sin_addr: resd 1
.sin_zero: resq 1
endstruc

%define AF_INET 2
%define SOCK_STREAM 1
%define SOCK_NONBLOCK 2048
%define SOL_SOCKET 1
%define SO_REUSEADDR 2

%define SIGINT 2

%define O_RDONLY 0

%define SEEK_SET 0
%define SEEK_CUR 1
%define SEEK_END 2
