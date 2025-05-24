format ELF64 executable

macro  write fd, buf, count ;we define a macro to not have to write the entire thing down there (sort of like a func)
{
    mov rax, 1
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro exit code
{
    mov rax, 60
    mov rdi,code
    syscall
}


segment readable executable ;linux has two segment, this one is for accessing stuff afaik
entry main
main:
    ;if we wanted to we could have then done
    ;write 1, msg, msg_len
    ;exit 0

    mov rax, 1 ;rax register is a register of the cpu, we move there to tell the cpu what syscall (number) we want go see chromium os  (linux) syscalls
    mov rdi, 1  ;we are onw moving in the right registers to provide all the arguments needed afaik this one is output code so 1 being standard
    mov rsi, msg ;pointer to the "buffer" aka our in memory saved stuff
    mov rdx, 14  ;size of the "buffer", here literally counted chars + new line
    syscall  ;and this is how it is "launched"

    mov rax, 60 
    mov rdi, 0
    syscall ;we moved to exit here

segment readable writable ;this one is for declaring stuff
msg db "Hello, World!", 10
;we could do msg_len = $ - msg which tells it to look into the address of the current line - msg so we use it in rdx instead of hard coding