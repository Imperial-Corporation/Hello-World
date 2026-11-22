# Hello World as raw x86-64 machine code (Linux): only the CPU instructions and the data.
# Every line holds hexadecimal bytes; everything after '#' is a comment.
# The build script wraps these bytes into a minimal ELF64 file (headers only).

b8 01 00 00 00                                               # mov eax, 1          ; sys_write
bf 01 00 00 00                                               # mov edi, 1          ; file descriptor: stdout
48 8d 35 10 00 00 00                                         # lea rsi, [rip+16] ; address of the message (position independent)
ba 20 00 00 00                                               # mov edx, 32         ; message length
0f 05                                                        # syscall
b8 3c 00 00 00                                               # mov eax, 60         ; sys_exit
31 ff                                                        # xor edi, edi        ; exit status 0
0f 05                                                        # syscall
48 65 6c 6c 6f 20 66 72 6f 6d 20 78 38                       # Data - "Hello from x"
36 5f 36 34 20 4d 61 63 68 69 6e 65 20 43 6f 64 65 21 0a     # "86_64 Machine Code!\n"
