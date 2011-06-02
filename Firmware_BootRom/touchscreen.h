#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

   typedef struct
   {
      uint8_t a;
      uint8_t r;
      uint8_t g;
      uint8_t b;
   } color;

   extern uint8_t const charROM[256][8] asm("_binary_font_pf_start");
   extern uint8_t const snowFlakeStart asm("_binary_snow_flake_png_start");
   extern uint8_t const snowFlakeEnd   asm("_binary_snow_flake_png_end");
   static volatile uint32_t (* const SCREEN)[800] = (volatile uint32_t (* const)[800])0x02000000;

   void print(unsigned x, unsigned y,char const * str, ...);
   void printEx(unsigned x, unsigned y, unsigned size,char const * str, ...);
   void printCenterEx(unsigned center, unsigned top, unsigned size,char const * format, ...);
   void printString(unsigned x, unsigned y, unsigned char const * str);
   void printStringEx(unsigned x, unsigned y, unsigned size, unsigned char const * str);

   void clearScreen(uint32_t color);

   void pngdemo();

#ifdef __cplusplus
}
#endif
