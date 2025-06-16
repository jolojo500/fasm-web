format ELF64 executable

SYS_write equ 1  ;in compile time = will mean it can change so with fasm we can do equ to make it const
SYS_exit equ 60

SYS_socket equ 41 ;is the syscall code so
SYS_accept equ 43
SYS_bind equ 49
SYS_listen equ 50

SYS_close equ 3


AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY equ 0

STDOUT equ 1
STDERR equ 2

EXIT_SUCESS equ 0
EXIT_FAILURE equ 1

MAX_CONN equ 5

macro  write fd, buf, count 
{
    mov rax, 1
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro close fd
{
    mov rax, SYS_close
    mov rdi, fd
    syscall
}

macro socket domain, type, protocol
{
    mov rax, SYS_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
}

macro bind sockfd, addr, addrlen
{
    mov rax, SYS_bind
    mov rdi, sockfd
    mov rsi, addr
    mov rdx, addrlen
    syscall
}

macro listen sockfd, backlog
{
    mov rax, SYS_listen
    mov rdi, sockfd
    mov rsi, backlog
    syscall
}

macro accept sockfd, addr, addrlen
{
    mov rax, SYS_accept
    mov rdi, sockfd
    mov rsi, addr
    mov rdx, addrlen
    syscall
}
macro exit code
{
    mov rax, 60
    mov rdi,code
    syscall
}


segment readable executable
entry main
main:
    
    write STDOUT, start, start_len

    write STDOUT, socket_trace_msg, socket_trace_msg_len
    socket AF_INET, SOCK_STREAM, 0
    ;check the doc file if you will, AF_INET is the domain arg which says that the communication domain (aka prtocol family) is IPV4 internet
    ;since it is a streaming socket on the internet domain pretty much means tcp, no need to specify protocol then (0)
    cmp rax, 0
    jl error    ; if it is other than 0 then jump to error
    mov qword [sockfd], rax

    write STDOUT, bind_trace_msg, bind_trace_msg_len
    mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 0x391B ; or 14619 which is dec for reverse 6969 hex ;; changing it only needs to invert the port in hex so do he then invert the bytes
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, sizeof_servaddr
    cmp rax, 0
    jl error

    write STDOUT, listen_trace_msg, listen_trace_msg_len
    listen [sockfd], MAX_CONN
    cmp rax, 0
    jl error

    write STDOUT, accept_trace_msg, accept_trace_msg_len
    accept [sockfd], cliaddr.sin_family, cliaddr_len
    cmp rax, 0
    jl error

    mov qword [connfd], rax

    write [connfd], hello, hello_len

    write STDOUT, ok_msg, ok_msg_len
    close [connfd]
    close [sockfd]
    exit 0

error: 
    write STDERR, error_msg, error_msg_len
    close [connfd]
    close [sockfd]
    exit 1

; db - 1 byte
; dw - 2 byte
; dd - 4 byte
; dq - 8 byte

segment readable writable

struc servaddr_in
{
    .sin_family dw 0
    .sin_port dw 0
    .sin_addr dd 0
    .sin_zero dq 0
}

sockfd dq -1
connfd dq -1
;servaddr.sin_family dw 0 
;servaddr.sin_port dw 0
;servaddr.sin_addr dd 0 
;servaddr.sin_zero dq 0 
servaddr servaddr_in
sizeof_servaddr = $ - servaddr.sin_family ;;so current address - the begining of the def
cliaddr servaddr_in
cliaddr_len dd sizeof_servaddr

hello db "Hello from flat assembler!", 10
hello_len = $ - hello

start db "INFO: Sarting Web Server!", 10
start_len = $ - start
ok_msg db "INFO: OK!", 10
ok_msg_len = $ - ok_msg
socket_trace_msg db "INFO: Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg
bind_trace_msg db "INFO: Binding the socket...", 10
bind_trace_msg_len = $ - bind_trace_msg
listen_trace_msg db "INFO: Listening to the socket...", 10
listen_trace_msg_len = $ - listen_trace_msg
accept_trace_msg db "INFO: Waiting for client connections...", 10
accept_trace_msg_len = $ - accept_trace_msg
error_msg db "ERROR!", 10
error_msg_len = $ - error_msg