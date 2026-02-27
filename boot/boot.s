# boot.s
# -----------------------
# 64-bit long mode boot, Multiboot2 header
# -----------------------

# Multiboot2 header magic
.set MULTIBOOT_MAGIC, 0xE85250D6

.section .multiboot
.align 8
.long MULTIBOOT_MAGIC
.long 0                           # architecture
.long 24                          # header length
.long -(MULTIBOOT_MAGIC + 0 + 24) # checksum

.section .boot
.code32
.global _start
.extern kernel_main

_start:
    cli
    mov $stack_top, %esp

    call load_gdt
    call setup_paging

    # Enable PAE
    mov %cr4, %eax
    or $0x20, %eax
    mov %eax, %cr4

    # Load PML4
    mov $pml4_table, %eax
    mov %eax, %cr3

    # Enable Long Mode
    mov $0xc0000080, %ecx
    rdmsr
    or $0x100, %eax
    wrmsr

    # Enable Paging + Protected mode
    mov %cr0, %eax
    or $0x80000001, %eax
    mov %eax, %cr0

    # Long jump to 64-bit code
    ljmp $0x08, $long_mode_entry

.code64
long_mode_entry:
    mov $stack_top, %rsp
	movabs $kernel_main, %rax
    call *%rax

1:
    hlt
    jmp 1b

# ----------------
# GDT
# ----------------
gdt:
    .quad 0                  # 空描述符
    .quad 0x00af9a000000ffff # 代码段
    .quad 0x00af92000000ffff # 数据段

gdt_descriptor:
    .word 24-1
    .long gdt

load_gdt:
    lgdt gdt_descriptor
    ret

# ----------------
# Paging (identity map first 2MB)
# ----------------
.align 4096
pml4_table:
    .quad pdpt_table + 0x03
    .zero 4096-8

.align 4096
pdpt_table:
    .quad pd_table + 0x03
    .zero 4096-8

.align 4096
pd_table:
    .quad 0x00000000 + 0x83
    .org pd_table + 8*256
    .quad 0x00000000 + 0x83
    .zero 4096-(8*257)

setup_paging:
    ret

# ----------------
# Stack
# ----------------
.section .bss
.align 16
stack_bottom:
.space 16384
stack_top:
