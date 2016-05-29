ENTRY(start)

SECTIONS {
    . = 1M;

    .boot :
    {
        /*start with multiboot header so the bootloader can see the kernel*/
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }
}
