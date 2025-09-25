/* multiboot stuff for grub */
    .section .multiboot
    .align 4
    .long 0x1BADB002        /* magic */
    .long 0x00000000        /* flags */
    .long -(0x1BADB002 + 0x00000000)

    .section .text
    .global start
    .extern kernel_main

start:
    cli                     
    /* set data segment reggie fils aime to 0x10 we rely on something in qemu and gtub*/
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    call kernel_main

.hang:
    hlt
    jmp .hang
