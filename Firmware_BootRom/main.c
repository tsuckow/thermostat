#include <stdint.h>
#include <unistd.h>
#include "test.h"
#include "touchscreen.h"
#include "sprs.h"

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
   //Enable Instruction Cache
   spr_ic_enable();

   //Enable HSync & VSync
//   spr_int_setmask( 0x3 );
//   spr_int_enable();
/*
   long i;
    unsigned long bob = 0;
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
            setPixel(i % 512, ((uint8_t)(bob + i/512)) << 8);
         }
         else
         {
            setPixel(i % 512, 0xFF0000);
         }

         ++bob;
      }
   }
   */

   unsigned long i;
   unsigned long j;
   unsigned long bob;
   //while(1)
   {
      for(i = 0; i < 480; ++i)
      {
         for(j = 0; j < 800; ++j)
         {
            SDRAM[i*800+j] = (uint8_t)(j);
         }
      }

      bob++;
   }

   while(1);

}
