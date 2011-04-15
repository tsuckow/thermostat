#include "touchscreen.h"

//The graphics buffers
volatile uint32_t * const buffer1 = reinterpret_cast<uint32_t * const>(0xFFFF0000);
volatile uint32_t * const buffer2 = reinterpret_cast<uint32_t * const>(0xFFFF4000);

void setPixel(long num, uint32_t clr)
{
   buffer1[num] = clr;
}
