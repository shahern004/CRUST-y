/*
 * Linker script for STM32H573I-DK
 * ARM Cortex-M33 with FPU
 *
 * Memory Layout:
 *   Flash: 2048 KB at 0x08000000
 *   RAM:    640 KB at 0x20000000
 *
 * Stack Size: 32 KB
 * Heap Size:  64 KB (for Rust embedded-alloc)
 */

/* Entry point */
ENTRY(Reset_Handler)

/* Memory regions */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 2048K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 640K
}

/* Stack and heap sizes */
_stack_size = 32K;
_heap_size  = 64K;

/* Top of stack (grows downward from end of RAM) */
_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    /* Vector table and code in Flash */
    .text :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))    /* Vector table must be first */
        . = ALIGN(4);
        *(.text)                /* Program code */
        *(.text*)
        *(.rodata)              /* Read-only data */
        *(.rodata*)
        . = ALIGN(4);
        _etext = .;             /* End of code/rodata */
    } > FLASH

    /* ARM exception unwinding info (C++ exceptions, if used) */
    .ARM.exidx :
    {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } > FLASH

    /* Initialized data (copied from Flash to RAM at startup) */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;             /* Start of .data in RAM */
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;             /* End of .data in RAM */
    } > RAM AT > FLASH

    _sidata = LOADADDR(.data);  /* Source address in Flash */

    /* Uninitialized data (zero-initialized at startup) */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;              /* Start of .bss */
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;              /* End of .bss */
    } > RAM

    /* Heap (for Rust embedded-alloc, grows upward) */
    .heap :
    {
        . = ALIGN(4);
        _sheap = .;
        . = . + _heap_size;
        . = ALIGN(4);
        _eheap = .;
    } > RAM

    /* Stack (grows downward from _estack) */
    /* No section needed - space reserved by _estack and _stack_size */

    /* Sanity check: ensure heap doesn't collide with stack */
    ASSERT((_eheap + _stack_size) <= _estack, "Heap + Stack overflow RAM")

    /* Discard debugging information (keep binary small) */
    /DISCARD/ :
    {
        libc.a (*)
        libm.a (*)
        libgcc.a (*)
    }
}
