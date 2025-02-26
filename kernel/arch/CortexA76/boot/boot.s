//
// boot.s - Entry point for CortexA76 kernel
//

// Set the architecture to aarch64
.arch armv8-a

// Make the _start function available to the linker
.global _start

// Set section to .text.boot so linker puts this at start of binary
.section .text.boot

_start:
	// Check processor ID, stop all but primary core (CPU 0)
	mrs     x0, mpidr_el1        // Read Multiprocessor Affinity Register
	and     x0, x0, #3           // Mask out lower bits to get CPU ID
	cbz     x0, 2f               // If CPU 0, branch forward to label 2
1:  wfe                          // Wait for event if not CPU 0
	b       1b                   // Loop back to wait
2:  // CPU 0 continues here

	// Setup stack pointer for EL1
	ldr     x0, =_start          // Load address of _start
	mov     sp, x0               // Set stack to start of code (grows downwards)

	// Clear BSS section
	ldr     x0, =__bss_start     // Start address of BSS
	ldr     x1, =__bss_end       // End address of BSS
	bl      clear_bss

	// Jump to C code
	bl      xarm64_main

	// If kernel_main returns, halt the processor
halt:
	wfe                          // Wait for event
	b       halt                 // Loop if woken up

// Function to clear the BSS section
clear_bss:
	cmp     x0, x1               // Compare start and end address
	b.ge    1f                   // Exit if start >= end
	str     xzr, [x0], #8        // Store zero and increment by 8
	b       clear_bss            // Loop
1:  ret                          // Return

// Architecture-specific memory layout
.section .rodata
.align 12

// Some basic message for debugging
boot_message:
	.ascii "CortexA76 Kernel Booting...\0"