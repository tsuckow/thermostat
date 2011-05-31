#include "touchscreen.h"
#include "debug.h"
#include <stdint.h>
#include <unistd.h>
#include <stdarg.h>
#include <stdio.h>

namespace
{
   static volatile uint32_t * const TOUCHREG = (uint32_t * const)0xFFFFFFE0;
}

void print(unsigned x, unsigned y, char const * format, ...)
{
   char buffer[100];
   va_list args;
   va_start (args, format);

   vsnprintf (buffer,100,format, args);

   printString(x,y,(unsigned char *)buffer);

   va_end (args);
}

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

void touch_event()
{
   uint32_t val = *TOUCHREG;
   debug("Touched %08x", val);
   debug("          ");
}

