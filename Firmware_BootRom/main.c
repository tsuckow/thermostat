#include <stdint.h>
#include <unistd.h>
#include "test.h"
#include "touchscreen.h"
#include "sprs.h"
#include <efs.h>
#include <stdio.h>
#include <stdarg.h>
#include <errno.h>

/*
__uint32_t __attribute__((used,section(".text2"))) Display()
{
	volatile __uint32_t haha;
	haha = 44;
	return haha;
}
*/

int frank = 3;//.data, doesn't actually get initialized
EmbeddedFileSystem efs;
EmbeddedFile filer;

static volatile uint32_t * const SDRAM = (uint32_t * const)0x02000000;

unsigned debug_row;

void Start()
{
   unsigned char buf [30];
   unsigned char buf2[30];

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
   printString(0,479-8*3,"==System Ready==");
   
//   spr_int_setmask( 0x3 );
//   spr_int_enable();


   debug_row = 0;

   color = 0x00FF0000;
   buf[0] = 'z';
   buf[1] = 0;
   
//      syscall(0x80, &bob);
	if ( ( res = efs_init( &efs, 0 ) ) == 0 )
	{
		color = 0x00FFFFFF;
		
		if ( file_fopen( &filer, &efs.myFs , "test.txt" , 'r' ) == 0 )
		{
			unsigned e;
			
			color = 0x0000FF00;
			
			if( (e = file_read( &filer, 29, buf ) ) != 0 )
			{
					buf[e]='\0';
					color = 0x00FFFF00;
			}
			
		  file_fclose( &filer );
	   }
	}
	
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
 while(1)
   {  }

}


void efsl_debug(unsigned char const * format, ...)
{
   char buffer[256];
   va_list args;
   int ret;
   va_start (args, format);

   ret = vsnprintf (buffer,256,format, args);

   printString(20,400-debug_row*8,buffer);

   va_end (args);

   if( ret < 0 )
   {
      printString(210,400-debug_row*8,"vsnprintf error");
   }
   if( ret == -1 )
   {
      printString(400,400-debug_row*8,"-1");
	  buffer[0] = errno;
	  buffer[1] = 0;
	  printString(500,400-debug_row*8,buffer);
   }

   debug_row = (debug_row + 1) % 32;
}
