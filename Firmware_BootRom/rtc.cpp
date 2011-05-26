#include "rtc.h"
#include <unistd.h>
#include "debug.h"

namespace
{
   uint8_t volatile * const RTC_I2C = (uint8_t * const)0xFFFFFFF0;

   size_t const I2C_PRElo = 0;
   size_t const I2C_PREhi = 1;
   size_t const I2C_CTR   = 2;
   size_t const I2C_DAT   = 3;
   size_t const I2C_CSR   = 4;

   inline int i2cBusy()
   {
      return RTC_I2C[I2C_CSR] & 0x02;
   }
}

void rtcInit()
{
   RTC_I2C[I2C_CTR]  = 0x00;//Disable
   RTC_I2C[I2C_PREhi]= 0x00;//Set prescale
   RTC_I2C[I2C_PRElo]= 0x63;//Set prescale
   RTC_I2C[I2C_CTR]  = 0x80;//Enable
   RTC_I2C[I2C_CSR]  = 0x68;//stop, read, nack
   while ( i2cBusy() );

   //Turn on RTC
   uint8_t dat;
   rtcRead( 0, &dat, 1 );
   dat &= ~0x80;
   rtcWrite( 0, &dat, 1 );
   rtcRead( 0, &dat, 1 );
}

void rtcRead( uint8_t address, uint8_t * const data, unsigned int num )
{
   unsigned int i, end;

   RTC_I2C[I2C_DAT] = 0xD0;
   RTC_I2C[I2C_CSR] = 0x90;
   while( i2cBusy() );

   RTC_I2C[I2C_DAT] = address;//Register address
   RTC_I2C[I2C_CSR] = 0x10;//write
   while( i2cBusy() );
   RTC_I2C[I2C_DAT] = 0xD1;//Device address,read
   RTC_I2C[I2C_CSR] = 0x90;//start,write
   while( i2cBusy() );

   if(num)
   {
      end = num-1;
      for (i=0; i<end; ++i)
      {
         RTC_I2C[I2C_CSR] = 0x20;//read
         while( i2cBusy() );
         data[i] = RTC_I2C[I2C_DAT];
      }
      RTC_I2C[I2C_CSR] = 0x68;//stop, read, nack
      while( i2cBusy() );
      data[end] = RTC_I2C[I2C_DAT];
   }
}

void rtcWrite(uint8_t address, uint8_t * const data, unsigned int num)
{
   unsigned int i, end;
   RTC_I2C[I2C_DAT] = 0xD0;//Device address,write
   RTC_I2C[I2C_CSR] = 0x90;//start,write
   while( i2cBusy() );
   RTC_I2C[I2C_DAT] = address;//Register address
   RTC_I2C[I2C_CSR] = 0x10;//write
   while( i2cBusy() );
   if (num) {
      end = num-1;
      for (i=0; i<end; ++i) {
         RTC_I2C[I2C_DAT] = data[i];//Data
         RTC_I2C[I2C_CSR] = 0x10;//write
         while( i2cBusy() );
      }
      RTC_I2C[I2C_DAT] = data[end];//Data
      RTC_I2C[I2C_CSR] = 0x58;//stop, write, nack
      while( i2cBusy() );
   }
}
