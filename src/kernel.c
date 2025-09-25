/* todo: write an actual kernel */
typedef unsigned int uint32_t;

void kernel_main(void) {
    volatile char *video = (volatile char*)0xB8000;
    const char *msg = "hi bados";
    for (int i = 0; msg[i]; ++i) {
        video[i*2 + 0] = msg[i];   
        video[i*2 + 1] = 0x07;     /* light grey on black */
    }

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
