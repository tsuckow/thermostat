#pragma once

#include "spr_defs.h"

#define getSPR( reg, value ) \
   asm volatile(             \
      "l.mfspr %0, r0, %1"   \
      :"=r"(value)           \
      :"n"(reg)              \
   );

#define setSPR( reg, value ) \
   asm volatile(             \
      "l.mtspr r0, %0, %1"   \
      :                      \
      :"r"(value), "n"(reg)  \
   );

inline unsigned long spr_int_getmask()
{
   unsigned long value;
   getSPR( SPR_PICMR, value );
   return value;
}

inline void spr_int_setmask( unsigned long mask )
{
   setSPR( SPR_PICMR, mask );
}

inline unsigned long spr_int_getflags()
{
   unsigned long value;
   getSPR( SPR_PICSR, value );
   return value;
}

inline void spr_int_clearflags( unsigned long flags )
{
   setSPR( SPR_PICSR, flags );
}

inline void spr_int_enable()
{
   unsigned long SR;
   getSPR( SPR_SR, SR );
   SR |= SPR_SR_IEE;
   setSPR( SPR_SR, SR );
}

inline void spr_int_disable()
{
   unsigned long SR;
   getSPR( SPR_SR, SR );
   SR &= ~SPR_SR_IEE;
   setSPR( SPR_SR, SR );
}
