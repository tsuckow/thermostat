#include <stdint.h>
#include <unistd.h>

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

	bob = 5;

   while(1)
   {
      bob++;

      syscall(0x80, bob);
   }
}
