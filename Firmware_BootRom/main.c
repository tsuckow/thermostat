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
unsigned hightemp = 25;
unsigned lowtemp  = 20;

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
      uint32_t oldval = *THERMO;

      float temp1c = raw_to_celcius(temp1);
      float temp2c = raw_to_celcius(temp2);
      unsigned temp1ci = temp1c;
      unsigned temp2ci = temp2c;
      printCenterEx(234,479-32,4," %0.1føC ", raw_to_celcius(temp1) );
      printCenterEx(566,479-32,4," %0.1føC ", raw_to_celcius(temp2) );

//      print(400,28,"TEMP1: %hd     ",temp1);
//      print(400,20,"TEMP2: %hd     ",temp2);
      if( temp1ci < lowtemp || (temp1ci == lowtemp && (oldval & 0x2)) ) newval |= 0x2;//Heat
      if( temp2ci < lowtemp || (temp2ci == lowtemp && (oldval & 0x1)) ) newval |= 0x1;
      if( temp1ci > hightemp|| (temp1ci == hightemp && (oldval & 0xA0)) ) newval |= 0xA0;//AC & Fan
      if( temp2ci > hightemp|| (temp2ci == hightemp && (oldval & 0x48)) ) newval |= 0x48;
      if( temp1ci > (hightemp + 1) ) newval |= 0x10;//High Fan
      if( temp2ci > (hightemp + 1) ) newval |= 0x04;

      if( oldval != newval )
      {
         (*THERMO) = newval;
         //Update image

         if(newval & 0x2)
         {
            printImage( 100, 350, &heatStart, &heatEnd );
         }
         else if(newval & 0xA0)
         {
            printImage( 100, 350, &snowFlakeStart, &snowFlakeEnd );
         }
         else
         {
            clearArea(100-64,350+64,128,128,0);
         }

         if(newval & 0x1)
         {
            printImage( 700, 350, &heatStart, &heatEnd );
         }
         else if(newval & 0x48)
         {
            printImage( 700, 350, &snowFlakeStart, &snowFlakeEnd );
         }
         else
         {
            clearArea(700-64,350+64,128,128,0);
         }
      }

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

