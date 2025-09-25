# toolchain im gonna stop these
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
ISO_DIR = $(BUILD)/iso
ISO = $(BUILD)/os.iso

.PHONY: all clean iso run

all: $(KERNEL_BIN)

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
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/kernel.bin
	cp src/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(ISO_DIR)

run: iso
	qemu-system-i386 -cdrom $(ISO) -m 512M

clean:
	rm -rf $(BUILD)
