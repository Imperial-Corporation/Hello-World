# Hello World as raw x86 (32-bit) machine code (Linux): only the CPU instructions and the data.
# Every line holds hexadecimal bytes; everything after '#' is a comment.
# The build script wraps these bytes into a minimal ELF32 file (headers only).

b8 04 00 00 00                                               # mov eax, 4          ; sys_write
bb 01 00 00 00                                               # mov ebx, 1          ; file descriptor: stdout
e8 00 00 00 00                                               # call next          ; pushes the address of the next instruction
59                                                           # pop ecx            ; ecx = its own address (position independent)
83 c1 14                                                     # add ecx, 20        ; ecx = address of the message
ba 20 00 00 00                                               # mov edx, 32         ; message length
cd 80                                                        # int 0x80            ; system call
b8 01 00 00 00                                               # mov eax, 1          ; sys_exit
31 db                                                        # xor ebx, ebx        ; exit status 0
cd 80                                                        # int 0x80            ; system call
48 65 6c 6c 6f 20 66 72 6f 6d 20 78 38                       # Data - "Hello from x"
36 5f 33 32 20 4d 61 63 68 69 6e 65 20 43 6f 64 65 21 0a     # "86_32 Machine Code!\n"
