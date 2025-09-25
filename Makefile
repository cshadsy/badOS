# ok so this is a 64 bit designed thing.
# edit CC and LD if you want to use 32 bit but why would you

# cross toolchain VVV
#CC = i386-elf-gcc
#LD  = i386-elf-ld
#OBJCOPY = i386-elf-objcopy

# or just host gcc and 32bit mode
CC = gcc
LD  = ld
OBJCOPY = objcopy

CFLAGS = -m32 -ffreestanding -nostdlib -fno-builtin -Wall -Wextra -O2
LDFLAGS = -m elf_i386 -T linker.ld --oformat elf32-i386

SRC = src/kernel.c src/entry.S
OBJS = kernel.o entry.o
KERNEL = kernel.bin

.PHONY: all clean iso run

all: $(KERNEL)

kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

entry.o: src/entry.S
	nasm -f elf32 $< -o $@

$(KERNEL): entry.o kernel.o linker.ld
	$(LD) $(LDFLAGS) -o kernel.elf entry.o kernel.o
	$(OBJCOPY) -O binary kernel.elf $(KERNEL) || true
	# some systems may provide objcopy as 'objcopy' not OBJCOPY var:
	@if [ ! -f $(KERNEL) ]; then objcopy -O binary kernel.elf $(KERNEL) ; fi

iso: all
	mkdir -p iso/boot/grub
	cp $(KERNEL) iso/boot/boot.bin
	cp $(KERNEL) iso/boot/kernel.bin
	cp iso/boot/boot.bin iso/boot/kernel.bin || true
	cp iso/boot/kernel.bin iso/boot/kernel.bin || true
	cp iso/boot/kernel.bin iso/boot/kernel.bin || true
	# ensure grub.cfg is present
	# grub-mkrescue will look for iso/boot/grub/grub.cfg
	grub-mkrescue -o os.iso iso

run: iso
	qemu-system-i386 -cdrom os.iso -m 512M

clean:
	rm -f *.o *.elf *.bin os.iso
	rm -rf iso
