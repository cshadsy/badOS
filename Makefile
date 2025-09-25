# toolcahin (change if you havbe cros compiler)
CC = gcc
LD = ld
OBJCOPY = objcopy
NASM = nasm

CFLAGS = -m32 -ffreestanding -nostdlib -fno-builtin -Wall -Wextra -O2
LDFLAGS = -m elf_i386 -T linker.ld --oformat elf32-i386

SRC = src/kernel.c src/entry.asm
BUILD = build
OBJS = $(BUILD)/kernel.o $(BUILD)/entry.o

KERNEL_ELF = $(BUILD)/kernel.elf
KERNEL_BIN = $(BUILD)/kernel.bin
ISO = $(BUILD)/os.iso

.PHONY: all clean iso run

all: $(KERNEL_BIN)

# ensure
$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/kernel.o: src/kernel.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/entry.o: src/entry.asm | $(BUILD)
	$(NASM) -f elf32 $< -o $@

$(KERNEL_ELF): $(OBJS) linker.ld | $(BUILD)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

iso: $(KERNEL_BIN)
	mkdir -p iso/boot/grub
	cp $(KERNEL_BIN) iso/boot/kernel.bin
	cp iso/boot/grub/grub.cfg iso/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) iso

run: iso
	qemu-system-i386 -cdrom $(ISO) -m 512M

clean:
	rm -rf $(BUILD) iso
