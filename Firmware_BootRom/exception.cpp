#include <stdint.h>
#include <unistd.h>
#include "string.h"
#include "sprs.h"

#include "touchscreen.h"
#include <stdio.h>

//Forward
extern "C"
{
   void external_exception();
   void exception_bus_error();
   void exception_data_page_fault();
   void exception_instruction_page_fault();
   void exception_tick_timer();
   void exception_unaligned_access();
   void exception_illegal_instruction();
   void exception_data_tlb_miss();
   void exception_instruction_tlb_miss();
   void exception_range();
   void exception_floating_point();
   void exception_trap();
   void exception_unknown();
   long exception_system_call(long arg1, long arg2, long arg3, long arg4, long arg5, long arg6);
}

inline uint32_t getExceptionEA()
{
	register uint32_t tmp;
	asm("l.mfspr %0,r0,%1":"=r"(tmp):"n"(SPR_EEAR_BASE):);
	return tmp;
}

inline uint32_t getExceptionPC()
{
	register uint32_t tmp;
	asm("l.mfspr %0,r0,%1":"=r"(tmp):"n"(SPR_EPCR_BASE):);
	return tmp;
}

void touch_event();
void touch_debounce();
void temp_event();

void external_exception()
{
   unsigned long inter;
   inter = spr_int_getflags();

   if( inter & 0x1 )
   {
      touch_event();
   }

   if( inter & 0x4 )
   {
      touch_debounce();
      temp_event();
   }

   spr_int_clearflags( 0x0 );//Stupid OR1200. OR1000 states use 1 to clear but OR1200 just takes the value.
}

void printExceptionError(char const * str)
{
	size_t len = strlen(str);
	printString(800/2 - len*8/2,480/2+4, reinterpret_cast<unsigned char const *>(str) );
	
	char buf[30];
	snprintf( buf, 30, "0x%X", getExceptionEA() );
	
	len = strlen(buf);
	printString(800/2 - len*8/2,480/2-4, reinterpret_cast<unsigned char const *>(buf) );
	
	snprintf( buf, 30, "0x%X", getExceptionPC() );
	
	len = strlen(buf);
	printString(800/2 - len*8/2,480/2-12, reinterpret_cast<unsigned char const *>(buf) );

   register uint32_t stack asm("r1");
   snprintf( buf, 30, "0x%X", stack );

   len = strlen(buf);
	printString(800/2 - len*8/2,480/2-20, reinterpret_cast<unsigned char const *>(buf) );
	
	while(true);
}

long exception_system_call(long arg1, long arg2, long arg3, long arg4, long arg5, long arg6)
{
	printExceptionError("Exception: System Call");
	
	return 0;
}

void exception_bus_error()
{
	printExceptionError("Exception: Bus Error");
}

void exception_data_page_fault()
{
	printExceptionError("Exception: Data Page Fault");
}

void exception_instruction_page_fault()
{
	printExceptionError("Exception: Instruction Page Fault");
}

void exception_tick_timer()
{
	printExceptionError("Exception: Tick Timer");
}

void exception_unaligned_access()
{
	printExceptionError("Exception: Unaligned Access");
}

void exception_illegal_instruction()
{
	printExceptionError("Exception: Illegal Instruction");
}

void exception_data_tlb_miss()
{
	printExceptionError("Exception: Data TLB Miss");
}

void exception_instruction_tlb_miss()
{
	printExceptionError("Exception: Instruction TLB Miss");
}

void exception_range()
{
	printExceptionError("Exception: Range");
}

void exception_floating_point()
{
	printExceptionError("Exception: Floating Point");
}

void exception_trap()
{
	printExceptionError("Exception: Trap");
}

void exception_unknown()
{
	printExceptionError("Exception: Unknown ???");
}
