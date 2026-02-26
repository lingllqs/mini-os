ENTRY(_start)

KERNEL_BASE = 0xffffffff80000000

SECTIONS
{
	. = 1M;
	
	.boot :
	{
		*(.multiboot)
		*(.boot*)
	}

	. += KERNEL_BASE

	.text : AT(ADDR(.text) - KERNEL_BASE)
	{
		*(.text*)
	}

	.rodata : AT(ADDR(.rodata) - KERNEL_BASE)
	{
		*(.rodata*)
	}

	.data : AT(ADDR(.data) - KERNEL_BASE)
	{
		*(.data*)
	}

	.bss : AT(ADDR(.bss) - KERNEL_BASE)
	{
		*(COMMON)
		*(.bss*)
	}
}
