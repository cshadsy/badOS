; mutliboot shit
section .multiboot
align 4
    dd 0x1BADB002          ; magic
    dd 0x00000000          ; flags
    dd -(0x1BADB002 + 0x00000000) ; checksum

section .text
global start
extern kernel_main

start:
    cli                     

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call kernel_main

.hang:
    hlt
    jmp .hang
