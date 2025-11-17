ENTRY(_start)

SECTIONS
{
	. = 2M;

    . = ALIGN(0x1000);
	.text : {
		*(.multiboot .multiboot.*)
		*(.text .text.*)
	}

	/* Read-only data. */
    . = ALIGN(0x1000);
	.rodata : {
		*(.rodata .rodata.*)
	}

	/* Read-write data (initialized) */
    . = ALIGN(0x1000);
	.data : {
		*(.data .data.*)
	}

    /* Uninitialized data */
    . = ALIGN(0x1000);
	.bss : {
		*(COMMON)
		*(.bss .bss.*)
	}
}