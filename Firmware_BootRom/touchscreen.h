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
   void setPixel(long num, uint32_t clr);

#ifdef __cplusplus
}
#endif
