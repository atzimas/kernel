# Kernel

A kernel is the core of every operating system. Its job is to
provide high level abstractions for user-level (or userspace)
applications to use the underline hardware without concering
them with implementation details. It is also responsible for
providing memory and resource protection for and from the
user.

This project is an operating system kernel that boots using the
[Multiboot standard](https://en.wikipedia.org/wiki/Multiboot_specification),
hops from x86 Assembler code to C code and prints simple strings
to the screen.

**Warning**: When jumping from the Multiboot entrypoint, we still
operate at [Ring 0](https://en.wikipedia.org/wiki/Protection_ring),
which is _very, very, very bad_. A standard kernel would:
- set the system to its 64-bit (long) mode (applicable for x86 mostly),
- setup paging and the MMU (i.e. establish Ring 3),
- initialize a working stack and heap,
- print the memory map of the system,
- initialize the _userspace_,
- map all I/O and provide safe handles for any userspace application,
- and _many, many more_ things.

## Building
To build the kernel image, run make with:

    zig build-exe -target x86-freestanding -T linker.lds


After successfully building the raw kernel 64-bit ELF image,
run the helpful `scripts/make-iso` script to create a bootable
ISO image:

    ./scripts/make-iso

Then you can run the kernel by launching QEMU:

    qemu-system-x86_64 -machine q35 -cdrom Image.iso
