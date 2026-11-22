; Hello World in x86-64 assembly (NASM syntax, Linux system calls).
global _start

section .rodata
msg:    db "Hello from x86_64 Assembly!", 10
len:    equ $ - msg

section .text
_start:
    mov     eax, 1              ; sys_write
    mov     edi, 1              ; file descriptor: stdout
    lea     rsi, [rel msg]      ; address of the message
    mov     edx, len            ; message length
    syscall

    mov     eax, 60             ; sys_exit
    xor     edi, edi            ; exit status 0
    syscall
