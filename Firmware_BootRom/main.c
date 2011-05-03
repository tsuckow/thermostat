#include <stdint.h>
#include <unistd.h>
#include "test.h"
#include "touchscreen.h"
#include "sprs.h"
#include <efs.h>

/*
__uint32_t __attribute__((used,section(".text2"))) Display()
{
	volatile __uint32_t haha;
	haha = 44;
	return haha;
}
*/

int frank = 3;//.data, doesn't actually get initialized
EmbeddedFileSystem efs;

volatile uint32_t * const SDRAM = (uint32_t * const)0x02000000;

void Start()
{
	
   unsigned long i;
   unsigned long j;
   unsigned long bob;
   int8_t res;
   uint32_t color = 0x00FFFFFF;
   
   //Enable Instruction Cache
   spr_ic_enable();

    for(i = 0; i < 480; ++i)
    {
       for(j = 0; j < 800; ++j)
         {
               SDRAM[i*800+j] = 0x00000080;
         }
      }
   
   //Enable HSync & VSync
//   spr_int_setmask( 0x3 );
//   spr_int_enable();

//      syscall(0x80, &bob);
	if ( ( res = efs_init( &efs, 0 ) ) != 0 )
	{
		color = 0x00FF0000;
	}


   while(1)
   {
      for(i = 0; i < 480; ++i)
      {
         for(j = 0; j < 800; ++j)
         {
            ///*
            if(i == 0 || i == 479 || j == 0 || j == 799)
               SDRAM[i*800+j] = color;
            else
               SDRAM[i*800+j] = (uint8_t)(j+bob+i);
            //*/
            /*
            if(j == 0 || j == 799)
               SDRAM[i*800+j] = 0x00FFFFFF;
            else
               SDRAM[i*800+j] = (uint8_t)(j) | 0xFF00;
            */
         }
      }

      bob++;
   }

}
