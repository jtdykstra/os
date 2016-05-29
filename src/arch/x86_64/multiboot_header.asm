;A multiboot header
header_start:
    dd 0xe85250d6                                                       ;magic number for multiboot 2
    dd 0                                                                ;architecture 0, i386
    dd header_end - header_start                                        ; header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))     ;checksum
    
    ;multiboot tags go here

    dw 0                                                                ;type
    dw 0                                                                ;flags
    dw 8                                                                ;size
header_end:
