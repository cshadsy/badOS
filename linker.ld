OUTPUT_FORMAT(elf32-i386)
ENTRY(start)

SECTIONS
{
  . = 0x00100000; /* load at 1mb so its safe and we dont annoy the gods of the cpu */

  .multiboot ALIGN(4) : {
    *(.multiboot)
  }

  .text ALIGN(4): {
    *(.text)
    *(.rodata)
  }

  .data : {
    *(.data)
  }

  .bss : {
    __bss_start = .;
    *(.bss)
    *(COMMON)
    __bss_end = .;
  }
}
