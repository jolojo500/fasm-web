format ELF64 executable

SYS_write equ 1  ;in compile time = will mean it can change so with fasm we can do equ to make it const
SYS_exit equ 60
SYS_socket equ 41 ;is the syscall code so

AF_INET equ 2
SOCK_STREAM equ 1

STDOUT equ 1
STDERR equ 2

EXIT_SUCESS equ 0
EXIT_FAILURE equ 1


macro  write fd, buf, count 
{
    mov rax, 1
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
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
    mov dword [sockfd], eax
    
    write STDOUT, ok_msg, ok_msg_len
    exit 0

error: 
    write STDERR, error_msg, error_msg_len

; db - 1 byte
; dw - 2 byte
; dd - 4 byte
; dq - 8 byte

segment readable writable
sockfd dd 0
start db "INFO: Sarting Web Server!", 10
start_len = $ - start
ok_msg db "INFO: OK!", 10
ok_msg_len = $ - ok_msg
socket_msg db "INFO: Creating a socket...", 10
socket_msg_len = $ - socket_msg
error_msg db "ERROR!", 10
error_msg_len = $ - error_msg