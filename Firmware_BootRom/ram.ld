ENTRY(_reset)

MEMORY    
{
    vectors     : ORIGIN = 0x00000100, LENGTH = 0x00002000 - 0x100
    flash       : ORIGIN = 0x00002000, LENGTH = 0x00020000
    /*ram         : ORIGIN = 0x10004000, LENGTH = 0x00002000*/
	ram         : ORIGIN = 0x02200000, LENGTH = 0x00600000
}
 
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
	
	/* This does not actually get initilized */
	.data :
	{
		KEEP(*(.data))
	} > ram AT> flash
	
    .bss :      { *(.bss)   }       > ram
     
    .stack ALIGN(0x4): /*Word Align*/
    {
        __STACK_TOP    = . ;
        . = . + 0x00001000;
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
