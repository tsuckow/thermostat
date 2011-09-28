#include "touchscreen.h"
#include "debug.h"
#include <stdint.h>
#include <unistd.h>
#include <stdarg.h>
#include <stdio.h>
#include "ui.h"

namespace
{
   static volatile uint32_t * const TOUCHREG = (uint32_t * const)0xFFFFFFE0;
   unsigned touch_state = 0;
   uint32_t touch_val = 0;

   void vprintEx(unsigned x, unsigned y, unsigned size,char const * format, va_list args)
   {
      char buffer[100];
      vsnprintf (buffer,100,format, args);
      printStringEx(x,y,size,(unsigned char *)buffer);
   }

   void vprintCenterEx(unsigned center, unsigned top, unsigned size,char const * format, va_list args)
   {
      char buffer[100];
      int num = vsnprintf(buffer,100,format, args);
      int x = center - (num*8*size)/2;
      printStringEx(x,top,size,(unsigned char *)buffer);
   }
}

void setPixel(size_t x, size_t y, uint32_t color)
{
   if( y >= 0 && x >= 0 && y < 480 && x < 800 )
      SCREEN[y][x] = color;
}



void print(unsigned x, unsigned y, char const * format, ...)
{
   va_list args;
   va_start (args, format);

   vprintEx(x,y,1,format,args);

   va_end (args);
}

void printEx(unsigned x, unsigned y, unsigned size,char const * format, ...)
{
   va_list args;
   va_start (args, format);

   vprintEx(x,y,size,format,args);

   va_end (args);
}

void printCenterEx(unsigned center, unsigned top, unsigned size,char const * format, ...)
{
   va_list args;
   va_start (args, format);

   vprintCenterEx(center,top,size,format,args);

   va_end (args);
}

void printString(unsigned x, unsigned y, unsigned char const * str)
{
	printStringEx( x, y, 1, str );
}

void printStringEx(unsigned x, unsigned y, unsigned size, unsigned char const * str)
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
            for(int ys = 0; ys < size; ++ys)
            {
               for(int xs = 0; xs < size; ++xs)
               {
                  if( (row & 0x01) == 0x01)
                     setPixel( x+xx*size+xs, y-yy*size-ys, 0x00DDDDDD);
                  else
                     setPixel( x+xx*size+xs, y-yy*size-ys, 0x00000000);
               }
            }
           row = row >> 1;
         }
      }

      ++str;
      x += 8*size;
   }
}

void clearArea(unsigned left, unsigned top, unsigned width, unsigned height, uint32_t color)
{
   for(size_t yy = 0; yy < height; ++yy)
   {
      for(size_t xx = 0; xx < width; ++xx)
      {
         setPixel( left+xx, top-yy, color );
      }
   }
}
void clearScreen(uint32_t color)
{
   for(size_t y = 0; y < 480; ++y)
   {
      for(size_t x = 0; x < 800; ++x)
      {
         setPixel( x, y, color );
      }
   }
}

void touch_tap(unsigned x, unsigned y)
{
   UI_handleClick( x, y );
}

void touch_event()
{
   uint32_t val = *TOUCHREG;
   bool touched = val >> 31;
   if(touched)
   {
      touch_state = 1;
   }
   else
   {
      if(touch_state > 1)
      {
         uint32_t x = ( 800 * static_cast<uint32_t>((touch_val >> 16) & 0x0FFF) ) / 0x0FFF;
         uint32_t y = ( 480 * static_cast<uint32_t>((touch_val >> 00) & 0x0FFF) ) / 0x0FFF;
         touch_tap(x,y);
      }
      touch_state = 0;
   }

}

void touch_debounce()
{
   if(touch_state > 0)
   {
      touch_state = 2;
      touch_val = *TOUCHREG;
   }
}
