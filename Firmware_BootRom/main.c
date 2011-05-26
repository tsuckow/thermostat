#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include "touchscreen.h"
#include "sprs.h"
#include <efs.h>
#include <stdarg.h>
#include <ls.h>
#include "dosfs/filesystem.h"
#include "temperature.h"
#include "rtc.h"

EmbeddedFileSystem efs;
EmbeddedFile filer;
DirList list;

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
   
   
//   spr_int_setmask( 0x3 );
//   spr_int_enable();


   debug_row = 0;

   color = 0x00FF0000;
   buf[0] = 'z';
   buf[1] = 0;
   
   if(spr_is_little_endian())
	printf("Little Endian\n");
   else
	printf("Big Endian\n");
	
	uint8_t test[4];
	test[0] = 0x00;
	test[1] = 0x11;
	test[2] = 0x22;
	test[3] = 0x33;
	efsl_debug("%02x %2x %2x %2x",test[0],test[1],test[2],test[3]);
	
	uint32_t * test32 = (uint32_t*)test;
	efsl_debug("%08x",*test32);
   
   filesystem_init();
   
//      syscall(0x80, &bob);

	if ( ( res = efs_init( &efs, 0 ) ) == 0 )
	{
		color = 0x00FFFFFF;
		
		ls_openDir(&list,&(efs.myFs),"/");
		
		while (ls_getNext(&list)==0)
		{
			DBG((TXT("DIR: %s (%li bytes)\n"),list.currentEntry.FileName,list.currentEntry.FileSize));
		}
		
		if ( file_fopen( &filer, &efs.myFs , "test.txt" , 'r' ) == 0 )
		{
			unsigned e;
			efsl_debug("File Opened");
			color = 0x0000FF00;
			
			if( (e = file_read( &filer, 29, buf ) ) != 0 )
			{
					buf[e]='\0';
					color = 0x00FFFF00;
					DBG((TXT("Read: %d bytes\n"),e));
			}
			
		  file_fclose( &filer );
	   }
	}
	fs_umount(&efs.myFs);
	
   /*
      for(i = 0; i < 480; ++i)
      {
         for(j = 0; j < 800; ++j)
         {
            if(i == 0 || i == 479 || j == 0 || j == 799)
               SDRAM[i*800+j] = color;
            else if( clear == 0 )
               SDRAM[i*800+j] = (uint8_t)(j+bob+i);
         }
      }

     */
	 printString(20,440,buf);
      printString(20,420,"This is a test! 1234567890");

      bob++;
      clear = (clear + 1)%10;
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
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
      for(l = 0; l < 100000; ++l);
      uint32_t newval = 0;

      uint16_t temp1;
      temp1 = temperature_convert1();
      efsl_debug("TEMP1: %04x     ",temp1);
      temp1 = temperature_convert2();
      efsl_debug("TEMP2: %04x     ",temp1);

      newval = 0x28; //Fans always on

      if( temp1 < 0x3c00 ) newval |= 0x2;//Heat
      if( temp1 < 0x3c00 ) newval |= 0x1;
      if( temp1 > 0x3c00 ) newval |= 0x80;//AC
      if( temp1 > 0x3c00 ) newval |= 0x40;
      if( temp1 > 0x3c00 ) newval |= 0x10;//High Fan
      if( temp1 > 0x3c00 ) newval |= 0x04;

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

void efsl_debug(unsigned char const * format, ...)
{
   char buffer[100];
   va_list args;
   va_start (args, format);

   vsnprintf (buffer,100,format, args);

   printString(20,400-debug_row*8,buffer);

   va_end (args);

   debug_row = (debug_row + 1) % 32;
}
