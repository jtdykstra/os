global start
extern long_mode_start

section .text
bits 32
start:
    mov esp, stack_top
    ;print ok to screen
    call test_multiboot
    call test_cpuid
    call test_long_mode

    call setup_page_tables
    call enable_paging
    
    ;GDT setup. Legacy compatability stuff, we're using paging NOT segmentation 
    lgdt [gdt64.pointer]

    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax

    jmp gdt64.code:long_mode_start

error:
    mov dword [0xb8000], 0x4f484f53
    mov dword [0xb8004], 0x4f544f49
    mov dword [0xb8008], 0x4f204f2C
    mov dword [0xb800C], 0x4f524f45
    mov dword [0xb8010], 0x4f3A4f52
    mov word [0xb8014], ax
    hlt

test_multiboot:
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret

.no_multiboot:
    mov al, "0"
    jmp error

test_cpuid:
    pushfd               ; Store the FLAGS-register.
    pop eax              ; Restore the A-register.
    mov ecx, eax         ; Set the C-register to the A-register.
    xor eax, 1 << 21     ; Flip the ID-bit, which is bit 21.
    push eax             ; Store the A-register.
    popfd                ; Restore the FLAGS-register.
    pushfd               ; Store the FLAGS-register.
    pop eax              ; Restore the A-register.
    push ecx             ; Store the C-register.
    popfd                ; Restore the FLAGS-register.
    xor eax, ecx         ; Do a XOR-operation on the A-register and the C-register.
    jz .no_cpuid         ; The zero flag is set, no CPUID.
    ret                  ; CPUID is available for use.
.no_cpuid:
    mov al, "1"
    jmp error

test_long_mode:
    mov eax, 0x80000000    ; Set the A-register to 0x80000000.
    cpuid                  ; CPU identification.
    cmp eax, 0x80000001    ; Compare the A-register with 0x80000001.
    jb .no_long_mode       ; It is less, there is no long mode.
    mov eax, 0x80000001    ; Set the A-register to 0x80000001.
    cpuid                  ; CPU identification.
    test edx, 1 << 29      ; Test if the LM-bit, which is bit 29, is set in the D-register.
    jz .no_long_mode       ; They aren't, there is no long mode.
    ret
.no_long_mode:
    mov al, "2"
    jmp error

setup_page_tables:
    ;map first p4 entry to p3 table
    mov eax, p3_table
    or eax, 0b11 ;present + writable
    mov [p4_table], eax
    
    ;map first P3 entry to P2 table
    mov eax, p2_table
    or eax, 0b11
    mov [p3_table], eax
    
   ;map each P2 entry to a 2MB page
   mov ecx, 0 ;counter
   
.map_p2_table:
    ;map the ecx-th p2 entry to a huge page that starts at 2MB*ecx
    mov eax, 0x200000 ;2MB
    mul ecx ;sets eax to eax * ecx
    or eax, 0b10000011 ;present + writable + huge
    mov [p2_table + ecx*8], eax ;fill in entry
    inc ecx 
    cmp ecx, 512 ; see if we're done
    jne .map_p2_table
    ret

enable_paging:
    ; load P4 to cr3 register
    mov eax, p4_table
    mov cr3, eax
    
    ;enable PAE-flag in cr4 (physical address extension)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ;set the long mode bit in the EFER MSR (model specific register)
    mov ecx, 0xC0000080
    rdmsr ;read model specific register
    or eax, 1 << 8
    wrmsr

   ;enable paging in the cr0 register
   mov eax, cr0
   or eax, 1 << 31
   mov cr0, eax
   
   ret

section .rodata
gdt64:
    dq 0
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
stack_bottom:
    resb 64
stack_top:































