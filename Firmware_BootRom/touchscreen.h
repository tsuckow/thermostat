#pragma once

#include <stdint.h>
#include <stddef.h>

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
   extern uint8_t const downStart asm("_binary___down_png_start");
   extern uint8_t const downEnd   asm("_binary___down_png_end");
   extern uint8_t const upStart asm("_binary___up_png_start");
   extern uint8_t const upEnd   asm("_binary___up_png_end");
   extern uint8_t const heatStart asm("_binary___heat_png_start");
   extern uint8_t const heatEnd   asm("_binary___heat_png_end");
   static volatile uint32_t (* const SCREEN)[800] = (volatile uint32_t (* const)[800])0x02000000;

   void setPixel(size_t x, size_t y, uint32_t color);

   void print(unsigned x, unsigned y,char const * str, ...);
   void printEx(unsigned x, unsigned y, unsigned size,char const * str, ...);
   void printCenterEx(unsigned center, unsigned top, unsigned size,char const * format, ...);
   void printString(unsigned x, unsigned y, unsigned char const * str);
   void printStringEx(unsigned x, unsigned y, unsigned size, unsigned char const * str);

   void clearArea(unsigned left, unsigned top, unsigned width, unsigned height, uint32_t color);
   void clearScreen(uint32_t color);

   void pngdemo();

#ifdef __cplusplus
}
#endif
