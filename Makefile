# this makefile was fixed by chatgpt (this comment is for transparency)
CC = gcc
LD = ld
OBJCOPY = objcopy
NASM = nasm

CFLAGS = -m32 -ffreestanding -nostdlib -fno-builtin -Wall -Wextra -O2
LDFLAGS = -m elf_i386 -T linker.ld --oformat elf32-i386

SRC = src/kernel.c src/entry.asm
BUILD = build
OBJS = $(BUILD)/entry.o $(BUILD)/kernel.o

KERNEL_ELF = $(BUILD)/kernel.elf
ISO_DIR = $(BUILD)/iso
ISO = $(BUILD)/os.iso
GRUB_CFG_SRC = src/grub.cfg

.PHONY: all clean iso run

all: $(KERNEL_ELF)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/kernel.o: src/kernel.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/entry.o: src/entry.asm | $(BUILD)
	$(NASM) -f elf32 $< -o $@

$(KERNEL_ELF): $(OBJS) linker.ld | $(BUILD)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

iso: $(KERNEL_ELF)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	cp $(GRUB_CFG_SRC) $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(ISO_DIR)

run: iso
	@echo "Starting QEMU VNC server on 127.0.0.1:0"
	@echo "Connect with: vncviewer 127.0.0.1:0"
	qemu-system-i386 -cdrom $(ISO) -m 512M -vnc 127.0.0.1:0

clean:
	rm -rf $(BUILD)
