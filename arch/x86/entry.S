/* SPDX-License-Identifier: GPL-v2.0-only */
/* 
 * entry.S: Multiboot-compliant kernel entry.
 * Follows from the example: https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Examples
 */

#define __ASSEMBLER__
#include <multiboot.h>

/* Kernel's stack size is 4KiB. */
#define STACK_SIZE 0x4000

/* Make kernel's multiboot header flags. */
#ifdef __ELF__
#define AOUT_KLUDGE 0
#else
#define AOUT_KLUDGE MULTIBOOT_AOUT_KLUDGE
#endif
#define MULTIBOOT_FLAGS \
	MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO | MULTIBOOT_VIDEO_MODE | AOUT_KLUDGE

.section .multiboot
multiboot_header:
	/* magic */
	.long	MULTIBOOT_HEADER_MAGIC
	/* flags */
	.long	MULTIBOOT_FLAGS
	/* checksum */
	.long 	-(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_FLAGS)
#ifdef __ELF__
	/* header_addr */
        .long   multiboot_header
        /* load_addr */
        .long   _start
        /* load_end_addr */
        .long   0
        /* bss_end_addr */
        .long   0
        /* entry_addr */
        .long   multiboot_entry
#else
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
#endif
	/* mode */
	.long	0
	/* width */
	.long	1024
	/* height */
	.long	768
	/* depth */
	.long	32

.section .text
.global _start
_start:
	jmp	multiboot_entry

.section .text
multiboot_entry:
	/* Init C stack. */
	movl	$(stack + STACK_SIZE), %esp

	/* Reset eflags. */
	push	$0
	popf

	/* Start the kernel. */
	call	kernel_start
0:
	/* Something went terribly wrong. */
	cli
	hlt
	jmp	0b

/* Kernel's stack area. */
.comm	stack, STACK_SIZE
