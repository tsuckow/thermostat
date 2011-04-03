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
void Start()
{
	uint32_t bob;
   long i;

	bob = 0xEF;

   while(1)
   {
//      syscall(0x80, &bob);

      for(i = 0; i < 800; ++i)
      {
         setPixel(i, i + bob);
      }

      bob += 1;
   }
}
