arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
target ?= $(arch)-unkwown-linux-gnu
c_os := $(wildcard src/arch/$(arch)/*.c)

linker_script := src/arch/$(arch)/linker.ld 
grub_cfg := src/arch/$(arch)/grub.cfg
assembly_sources_files := $(wildcard src/arch/$(arch)/*.asm)
assembly_object_files := $(patsubst src/arch/$(arch)/%.asm, \
	build/arch/$(arch)/%.o, $(assembly_sources_files))
c_os_obj := $(patsubst src/arch/$(arch)/%.c, build/arch/$(arch)/%.o, $(c_os))

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -hda $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

$(kernel): $(assembly_object_files) $(c_os_obj) $(linker_script)
	@x86_64-elf-ld -n -T $(linker_script) -o $(kernel) $(assembly_object_files) $(c_os_obj)

build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@

build/arch/$(arch)/%.o: src/arch/$(arch)/%.c
	@mkdir -p $(shell dirname $@)
	@gcc -m64 -c $< -o $@
