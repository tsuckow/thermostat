#include "touchscreen.h"
#include <stdint.h>
#include <unistd.h>

void printString(unsigned x, unsigned y, unsigned char const * str)
{
   int xx, yy;
   while( *str != 0 )
   {
      uint8_t const * chimg = charROM[*str];

      for( yy = 0; yy < 8; ++yy )
      {
         uint8_t row = chimg[yy];

         for(xx = 7; xx >= 0; xx--)
         {
            if( (row & 0x01) == 0x01)
               SCREEN[y-yy][x+xx] = 0x00DDDDDD;
            else
               SCREEN[y-yy][x+xx] = 0x00000000;

           row = row >> 1;
         }
      }

      ++str;
      x += 8;
   }
}
