#include <stdint.h>
#include <unistd.h>
#include "test.h"
#include "touchscreen.h"
#include "sprs.h"

void external_exception()
{
   unsigned long inter;
   inter = spr_int_getflags();
   spr_int_clearflags( inter );
}

/*
__uint32_t __attribute__((used,section(".text2"))) Display()
{
	volatile __uint32_t haha;
	haha = 44;
	return haha;
}
*/

volatile uint32_t * const SDRAM = (uint32_t * const)0x01000000;

void Start()
{
   volatile unsigned long ints;
   ints = spr_int_getmask();
   //Enable HSync & VSync
   spr_int_setmask( 0x3 );
   ints = spr_int_getmask();

   spr_int_enable();

   long i;
   /*volatile*/ unsigned long bob = 0;
   for(i = 0; i < 0x7FFFFF/4; ++i)
   {
      SDRAM[i] = 0xDEADBEEF + i;
   }

   while(1)
   {
//      syscall(0x80, &bob);
      for(i = 0; i < 0x7FFFFF/4; ++i)
      {
         if( SDRAM[i] == (0xDEADBEEF+i) )
         {
            setPixel(i % 512, 0, bob + i/512, 0);
         }
         else
         {
            setPixel(i % 512, 0xFF, 0, 0);
         }

         ++bob;
      }
   }
}
