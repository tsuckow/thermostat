#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif
 /*  typedef struct
   {
      uint8_t nil;
      uint8_t r;
      uint8_t g;
      uint8_t b;
   } color;
*/
   extern uint8_t const charROM[256][8] asm("_binary_font_pf_start");
   extern uint8_t const snowFlakeStart asm("_binary_snow_flake_png_start");
   extern uint8_t const snowFlakeEnd   asm("_binary_snow_flake_png_end");
   static volatile uint32_t (* const SCREEN)[800] = (volatile uint32_t (* const)[800])0x02000000;

void print(unsigned x, unsigned y,char const * str, ...);
   void printString(unsigned x, unsigned y, unsigned char const * str);

void pngdemo();

   
#ifdef __cplusplus
}
#endif
