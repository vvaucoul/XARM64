/* 
 * linker.ld - Linker script for XARM64 kernel on Cortex A76
 */

ENTRY(_start)

SECTIONS {
	/* Kernel starts at this physical address for Cortex A76 */
	. = 0x80000;

	/* Boot code section */
	.text.boot : {
		*(.text.boot)
	}

	/* Main code section */
	.text : {
		*(.text)
	}

	/* Read-only data section */
	.rodata : {
		*(.rodata)
	}

	/* Read-write data section */
	.data : {
		*(.data)
	}

	/* Ensure aligned to 8 bytes */
	. = ALIGN(8);
	__bss_start = .;
	
	/* BSS section (zero-initialized data) */
	.bss : {
		*(.bss)
		*(COMMON)
	}
	. = ALIGN(8);
	__bss_end = .;

	/* Set end of kernel */
	__kernel_end = .;
}