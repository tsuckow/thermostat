#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include "touchscreen.h"
#include "sprs.h"
#include <stdarg.h>
#include "temperature.h"
#include "rtc.h"
#include "debug.h"

static volatile uint32_t * const SDRAM = (uint32_t * const)0x02000000;

static volatile uint32_t * const THERMO = (uint32_t * const)0xFFFF0020;

unsigned debug_row = 0;

void Start()
{
   //Enable Instruction Cache
   spr_ic_enable();

   clearScreen(0x00400000);

   printString(0,479-8*0,"Loading...");

   temperature_init();

   spr_int_clearflags( 0x4 | 0x02 | 0x1 );
   spr_int_setmask( 0x4 | 0x1 );
   spr_int_enable();

   pngdemo();

   rtcInit();

   printString(0,479-8*0,"          ");

   while(1)
   {
      uint32_t newval = 0;

      printCenterEx(234,479-32,4," %0.1føC ", raw_to_celcius(temp1) );
      printCenterEx(566,479-32,4," %0.1føC ", raw_to_celcius(temp2) );

      print(400,28,"TEMP1: %hd     ",temp1);
      print(400,20,"TEMP2: %hd     ",temp2);
      if( temp1 < 0x3a00 ) newval |= 0x2;//Heat
      if( temp2 < 0x3a00 ) newval |= 0x1;
      if( temp1 > 0x3b00 ) newval |= 0xA0;//AC & Fan
      if( temp2 > 0x3b00 ) newval |= 0x48;
      if( temp1 > 0x3e00 ) newval |= 0x10;//High Fan
      if( temp2 > 0x3e00 ) newval |= 0x04;

      (*THERMO) = newval;

      //Time
      uint8_t dat[4];
      rtcRead( 0, dat, 4 );
      printCenterEx(400,479,2,"%02x:%02x:%02x",dat[2],dat[1],dat[0]);
   }
}

int puts (__const char *__s)
{
   debug("printf deprecated: %s", __s);
}

void debug(char const * format, ...)
{
   char buffer[100];
   va_list args;
   va_start (args, format);

   vsnprintf (buffer,100,format, args);

   printString(0,479-8-debug_row*8,buffer);

   va_end (args);

   debug_row = (debug_row + 1) % 58;
}

