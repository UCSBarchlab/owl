OUTPUT_ARCH( "riscv" )
ENTRY(_start)  

/*
Worth to discuss the choice between von-newman arch or harvard one
*/

MEMORY
{
  ROM   (rx)  : ORIGIN = 0x0, LENGTH = 0x3000
  RAM   (rw)  : ORIGIN = 0x3100, LENGTH = 0x2100
}

SECTIONS
{
  . = 0x0;

  .text : { *(.text) } > ROM
  . = ALIGN(0x1000);

  _rodata_begin = .;
  .sha256_rodata : { *(.sha256_rodata) } > ROM
  . = ALIGN(0x1000);
  _rodata_end = .;
  
  _ram_data_begin = .;

  .data : { *(.data) } > RAM
  .bss : { *(.bss) } > RAM
  . = ALIGN(0x1000);
  
  _stack_end = .;
  . = 0x5100;
  _stack_begin = .;

  _ram_data_end = .;
}

