#include "touchscreen.h"

struct color
{
   uint8_t r;
   uint8_t g;
   uint8_t b;
   uint8_t nil;
};

//The graphics buffers
volatile color * const buffer1 = reinterpret_cast<color * const>(0xFFFF0000);
volatile color * const buffer2 = reinterpret_cast<color * const>(0xFFFF4000);

void setPixel(long num, uint8_t r, uint8_t g, uint8_t b)
{
   buffer1[num].r = r;
   buffer1[num].g = g;
   buffer1[num].b = b;
   buffer2[num].r = r;
   buffer2[num].g = g;
   buffer2[num].b = b;
}
