; Hello World in x86 (32-bit) assembly (NASM syntax, Linux system calls).
global _start

section .rodata
msg:    db "Hello from x86_32 Assembly!", 10
len:    equ $ - msg

section .text
_start:
    mov     eax, 4              ; sys_write
    mov     ebx, 1              ; file descriptor: stdout
    mov     ecx, msg            ; address of the message
    mov     edx, len            ; message length
    int     0x80

    mov     eax, 1              ; sys_exit
    xor     ebx, ebx            ; exit status 0
    int     0x80
