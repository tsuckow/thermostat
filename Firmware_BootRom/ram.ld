ENTRY(_reset)

MEMORY    
{
   vectors     : ORIGIN = 0x00000100, LENGTH = 0x00002000 - 0x100
   flash       : ORIGIN = 0x00002000, LENGTH = 0x00400000 - 0x2000
   ram         : ORIGIN = 0x02200000, LENGTH = 0x00600000
}

STACK_SIZE = 0x1000;

/*
  The following section defines where to put the different input sections.
  .text contains the code.
  .data contains the initialized data.
  .bss contains uninitialized data.
  .sdata contains small constant data.
*/

SECTIONS
{
    .vectors :   { *(.vectors) }    > vectors

    .text :
   {
      *(.text .text.*)
   } > flash

    .rodata :
   {
      *(.rodata .rodata.*)
   } > flash
   .gcc_except_table :
   {
      *(.gcc_except_table)
   } > flash

   .ctors :
   {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    /* We don't want to include the .ctor section from
       from the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
   } > ram

   .data :
   {
      __DATA_INIT = LOADADDR( .data );
      __RAM_SDATA = .;
      KEEP(*(.data .data.*))
      __RAM_EDATA = .;
   } > ram AT> flash

    .bss ALIGN(0x4):
   {
      __RAM_SBSS = .;
      *(.bss .bss.*)
      __RAM_EBSS = .;
   } > ram

   .stack ALIGN(0x4): /*Word Align*/
   {
      __STACK_TOP    = . ;
      . = . + STACK_SIZE;
      __STACK_BOTTOM = . ;
   }                               > ram
}

/*
  Definitions of identifiers that control initialization and memory allocation:
  These two symbols must be present.
   __BSS_START  : Start of uninitialized data
   __BSS_END    : End of data to be cleared
*/

__CODE_START  = ADDR( .text );
__CODE_END    = ADDR( .text ) + SIZEOF( .text );

__DATA_START  = ADDR( .bss );
__DATA_END    = ADDR( .bss ) + SIZEOF( .bss );
