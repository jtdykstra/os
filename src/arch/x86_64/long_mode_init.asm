global long_mode_start
extern main

section .text
bits 64
long_mode_start:
    call main
    mov dword [0xb8000], 0x2f4b2f4f
    hlt

