#include <stdint.h>
#include <unistd.h>
#include "sprs.h"

//Forward
extern "C"
{
   void external_exception();
}

inline void setPixel(long num, uint32_t clr);

//Line
size_t linenumber;
size_t offset;

void external_exception()
{
   unsigned long inter;
   inter = spr_int_getflags();

   if( inter & 0x1 )
   {
      //Vertical Sync

      linenumber = 0;
      offset++;

      spr_int_clearflags( 0x01 );
   }

   if( inter & 0x2 )
   {
      int i;

      register uint8_t val = linenumber;// + offset;
      for(i=0; i < 800; i+=4)
      {
         setPixel(i+0, val);
         setPixel(i+1, val);
         setPixel(i+2, val);
         setPixel(i+3, val);
      }
      /*asm volatile(
      "
      l.mtspr r0, %0, %1;

      "
      :
      :"r"(val),
      );
      */
      linenumber++;

      spr_int_clearflags( 0x02 );
   }
}

//Touchscreen Stuff
volatile uint32_t * const buffer1 = reinterpret_cast<uint32_t * const>(0xFFFF0000);
volatile uint32_t * const buffer2 = reinterpret_cast<uint32_t * const>(0xFFFF4000);

inline void setPixel(long num, uint32_t clr)
{
   buffer1[num] = clr;
}
