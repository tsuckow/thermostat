#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include "touchscreen.h"
#include "sprs.h"
#include <stdarg.h>
#include "temperature.h"
#include "rtc.h"
#include "debug.h"
#include "math.h"

static volatile uint32_t * const SDRAM = (uint32_t * const)0x02000000;

static volatile uint32_t * const THERMO = (uint32_t * const)0xFFFF0020;

unsigned debug_row;

void Start()
{
   unsigned char buf [30];

   unsigned long i;
   unsigned long j;
   unsigned long bob;
   int8_t res;
   uint32_t color = 0x00FF0000;
   unsigned int clear;

   //Enable Instruction Cache
   spr_ic_enable();

   for(i = 0; i < 480; ++i)
   {
      for(j = 0; j < 800; ++j)
      {
         SDRAM[i*800+j] = 0x00400000;
      }
   }

   
   
   printString(0,479-8*0,"Tom OS v0.1");
   printString(0,479-8*1,"Author: Thomas Suckow");
   
   temperature_init();
   
   printString(0,479-8*3,"==System Ready==");
  


   debug_row = 0;

   color = 0x00FF0000;
   buf[0] = 'z';
   buf[1] = 0;
    
   spr_int_clearflags( 0x4 | 0x02 | 0x1 );
   spr_int_setmask( 0x4 | 0x1 );
   spr_int_enable();

	  
pngdemo();
	  
	  
	  
/*	  
	  
	      if (!(infile = fopen(filename, "rb"))) {
        fprintf(stderr, PROGNAME ":  can't open PNG file [%s]\n", filename);
        ++error;
    } else {
        if ((rc = readpng_init(infile, &image_width, &image_height)) != 0) {
            switch (rc) {
                case 1:
                    fprintf(stderr, PROGNAME
                      ":  [%s] is not a PNG file: incorrect signature\n",
                      filename);
                    break;
                case 2:
                    fprintf(stderr, PROGNAME
                      ":  [%s] has bad IHDR (libpng longjmp)\n", filename);
                    break;
                case 4:
                    fprintf(stderr, PROGNAME ":  insufficient memory\n");
                    break;
                default:
                    fprintf(stderr, PROGNAME
                      ":  unknown readpng_init() error\n");
                    break;
            }
            ++error;
        }
        if (error)
            fclose(infile);
    }


    if (error) {
        fprintf(stderr, PROGNAME ":  aborting.\n");
        exit(2);
    }



    if (have_bg) {
        unsigned r, g, b; 

        sscanf(bgstr+1, "%2x%2x%2x", &r, &g, &b);
        bg_red   = (uch)r;
        bg_green = (uch)g;
        bg_blue  = (uch)b;
    } else if (readpng_get_bgcolor(&bg_red, &bg_green, &bg_blue) > 1) {
        readpng_cleanup(TRUE);
        fprintf(stderr, PROGNAME
          ":  libpng error while checking for background color\n");
        exit(2);
    }

    Trace((stderr, "calling readpng_get_image()\n"))
    image_data = readpng_get_image(display_exponent, &image_channels,
      &image_rowbytes);
    Trace((stderr, "done with readpng_get_image()\n"))



    readpng_cleanup(FALSE);
    fclose(infile);

    if (!image_data) {
        fprintf(stderr, PROGNAME ":  unable to decode PNG image\n");
        exit(3);
    }

        free(image_data);

  */





   rtcInit();

   while(1)
   {
      volatile uint32_t l;
      //for(l = 0; l < 100000; ++l);
      uint32_t newval = 0;

      extern uint16_t temp1,temp2;
      /*
	  temp1 = temperature_convert1();
      efsl_debug("TEMP1: %04x     ",temp1);
      temp2 = temperature_convert2();
      efsl_debug("TEMP2: %04x     ",temp2);
	  */
	  
      newval = 0x00;

      {
         float tmp;
         tmp = temp1/4123.57;
         tmp = log(tmp);
         tmp = -18.98/tmp;
         print(20,30,"TEMP1: %0.2f     ",tmp);
      }

      print(20,20,"TEMP1: %d     ",temp1);
      print(400,20,"TEMP2: %d     ",temp2);
      if( temp1 < 0x3a00 ) newval |= 0x2;//Heat
      if( temp2 < 0x3a00 ) newval |= 0x1;
      if( temp1 > 0x3b00 ) newval |= 0xA0;//AC & Fan
      if( temp2 > 0x3b00 ) newval |= 0x48;
      if( temp1 > 0x3e00 ) newval |= 0x10;//High Fan
      if( temp2 > 0x3e00 ) newval |= 0x04;

      (*THERMO) = newval;

      uint8_t dat[4];
      rtcRead( 0, dat, 4 );

      efsl_debug("Time: %02x:%02x:%02x",dat[2],dat[1],dat[0]);
   }
}

int puts (__const char *__s)
{
	printString(40,400-debug_row*8,__s);
	debug_row = (debug_row + 1) % 32;
}

//deprecated
void efsl_debug(char const * format, ...)
{
   char buffer[100];
   va_list args;
   va_start (args, format);

   vsnprintf (buffer,100,format, args);

   printString(20,400-debug_row*8,buffer);

   va_end (args);

   debug_row = (debug_row + 1) % 32;
}

void debug(char const * format, ...)
{
   char buffer[100];
   va_list args;
   va_start (args, format);

   vsnprintf (buffer,100,format, args);

   printString(20,400-debug_row*8,buffer);

   va_end (args);

   debug_row = (debug_row + 1) % 32;
}

void debugregistersin(uint32_t * stack)
{
   char buf[10*9+1];
   int i = 0;
   debug("Enter Exception                                                  ");
   debug("Enter Exception %.8x %.8x                             ",stack[-1],spr_int_getflags() );
   debug("Enter Exception                                                  ");
   for(i = 0; i < 10; i++)
   {
      snprintf(buf+i*9,10,"%.8x ",stack[i]);
   }
   debug(buf);

   for(i = 10; i < 20; i++)
   {
      snprintf(buf+(i-10)*9,10,"%.8x ",stack[i]);
   }
   debug(buf);

   for(i = 20; i < 29; i++)
   {
      snprintf(buf+(i-20)*9,10,"%.8x         ",stack[i]);
   }

   debug(buf);
}
void debugregistersout(uint32_t * stack)
{
   char buf[10*9+1];
   int i = 0;
   debug("Leave Exception                                                  ");
   for(i = 0; i < 10; i++)
   {
      snprintf(buf+i*9,10,"%.8x ",stack[i]);
   }
   debug(buf);

   for(i = 10; i < 20; i++)
   {
      snprintf(buf+(i-10)*9,10,"%.8x ",stack[i]);
   }
   debug(buf);

   for(i = 20; i < 29; i++)
   {
      snprintf(buf+(i-20)*9,10,"%.8x         ",stack[i]);
   }

   debug(buf);
}
