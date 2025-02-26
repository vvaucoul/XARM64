# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: vvaucoul <vvaucoul@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/02/26 15:53:43 by vvaucoul          #+#    #+#              #
#    Updated: 2025/02/26 16:03:45 by vvaucoul         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Compiler and linker
CROSS_COMPILE ?= aarch64-linux-gnu-
CC      = $(CROSS_COMPILE)gcc
AS      = $(CROSS_COMPILE)as
LD      = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

# Cortex-A76 specific flags
CFLAGS  = -mcpu=cortex-a76 -ffreestanding -O2 -Wall -Wextra -std=gnu99
ASFLAGS = -mcpu=cortex-a76
LDFLAGS = -nostdlib

# Directories
SRC_DIR   = kernel
BOOT_DIR  = $(SRC_DIR)/arch/CortexA76/boot
KERNEL_SRCS_DIR = $(SRC_DIR)/srcs
INCLUDE_DIR = $(SRC_DIR)/includes
BUILD_DIR = build

# Source files
ASM_SRC  = $(wildcard $(BOOT_DIR)/*.s)
C_SRC    = $(wildcard $(KERNEL_SRCS_DIR)/*.c)
HEADERS  = $(wildcard $(INCLUDE_DIR)/*.h)

# Object files
ASM_OBJ  = $(patsubst $(BOOT_DIR)/%.s,$(BUILD_DIR)/%.o,$(ASM_SRC))
C_OBJ    = $(patsubst $(KERNEL_SRCS_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SRC))
OBJS     = $(ASM_OBJ) $(C_OBJ)

# Output files
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_IMG = $(BUILD_DIR)/kernel8.img

# Default target
all: dirs $(KERNEL_IMG)

# Create build directories
dirs:
	@mkdir -p $(BUILD_DIR)

# Compile assembly files
$(BUILD_DIR)/%.o: $(BOOT_DIR)/%.s
	$(AS) $(ASFLAGS) -c $< -o $@

# Compile C files
$(BUILD_DIR)/%.o: $(KERNEL_SRCS_DIR)/%.c
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -c $< -o $@

# Link object files
$(KERNEL_ELF): $(OBJS)
	$(LD) $(LDFLAGS) -T $(BOOT_DIR)/linker.ld -o $@ $^
	$(OBJDUMP) -D $@ > $(BUILD_DIR)/kernel.dump

# Create binary image
$(KERNEL_IMG): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

# Clean build files
clean:
	rm -rf $(BUILD_DIR)/*

# Full rebuild
re: clean all

# Run using QEMU (assuming ARM64 system)
run: all
	qemu-system-aarch64 -M virt -cpu cortex-a76 -kernel $(KERNEL_IMG) -nographic

# Debug with GDB
debug: all
	qemu-system-aarch64 -M virt -cpu cortex-a76 -kernel $(KERNEL_IMG) -nographic -s -S &
	gdb-multiarch $(KERNEL_ELF) -ex "target remote localhost:1234"

# Display help
help:
	@echo "Available targets:"
	@echo "  all     - Build the kernel (default)"
	@echo "  clean   - Remove build files"
	@echo "  re      - Rebuild everything"
	@echo "  run     - Run the kernel in QEMU"
	@echo "  debug   - Debug the kernel with GDB"
	@echo "  help    - Display this help message"

.PHONY: all dirs clean re run debug help