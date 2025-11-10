ARCH	:= x86_64
IMAGE	:= Image

ifeq ($(RUST_TARGET),)
    override RUST_TARGET := $(ARCH)-unknown-none
endif

ifeq ($(RUST_PROFILE),)
    override RUST_PROFILE := dev
endif

override RUST_PROFILE_SUBDIR := $(RUST_PROFILE)
ifeq ($(RUST_PROFILE),dev)
    override RUST_PROFILE_SUBDIR := debug
endif

all: $(IMAGE).iso

clean:
	cargo clean
	rm -rf kernel
	rm -rf iso_root $(IMAGE).iso
	
distclean: clean
	rm -rf limine ovmf

ovmf/omvf-code-$(ARCH).fd:
	mkdir -p ovmf
	curl Lo $@ https://github.com/osdev0/edk2-ovmf-nightly/releases/latest/download/ovmf-vars-$(KARCH).fd

limine:
	rm -rf limine
	git clone https://github.com/limine-bootloader/limine.git --branch=v9.x-binary --depth=1
	$(MAKE) -C limine

kernel:
	RUSTFLAGS="-C relocation-model=static" cargo build --target $(RUST_TARGET) --profile $(RUST_PROFILE)
	cp target/$(RUST_TARGET)/$(RUST_PROFILE_SUBDIR)/$$(cd target/$(RUST_TARGET)/$(RUST_PROFILE_SUBDIR) && find -maxdepth 1 -perm -111 -type f) kernel

$(IMAGE).iso: limine kernel
	rm -rf iso_root
	mkdir -p iso_root/boot
	cp -v kernel iso_root/boot
	mkdir -p iso_root/boot/limine
	cp -v conf/limine.conf iso_root/boot/limine
	mkdir -p iso_root/EFI/BOOT
ifeq ($(ARCH), x86_64)
	cp -v limine/limine-bios.sys limine/limine-bios-cd.bin limine/limine-uefi-cd.bin iso_root/boot/limine/
	cp -v limine/BOOTX64.EFI iso_root/EFI/BOOT/
	cp -v limine/BOOTIA32.EFI iso_root/EFI/BOOT/
	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o $(IMAGE).iso
	./limine/limine bios-install $(IMAGE).iso
endif

.PHONY: all clean distclean kernel