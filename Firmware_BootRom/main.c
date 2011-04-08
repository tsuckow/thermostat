#include <stdint.h>
#include <unistd.h>
#include "test.h"
#include "touchscreen.h"

uint32_t gPicSr, gsr;

void external_exception()
{
	register uint8_t i;
	register uint32_t PicSr, sr;
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
   long i;
   volatile unsigned long bob = 0;
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
            setPixel(i % 512, 0, 0xFF, 0);
         }
         else
         {
            setPixel(i % 512, 0xFF, 0, 0);
         }
      }

      for(i = 0; i < bob; ++i);

      ++bob;

      uint8_t color = (bob%2==0)?0xFF:0x00;

      for(i = 0; i < 10; ++i)
      {
         setPixel(600+i, color, color, color);
      }
   }
}
