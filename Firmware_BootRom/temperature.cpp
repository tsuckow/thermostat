#include "temperature.h"

#include <unistd.h>
#include "debug.h"
#include "touchscreen.h"
#include "sprs.h"
#include "math.h"

namespace
{
   bool temp2_next = false;

   volatile uint32_t * const TEMP_SPI = (uint32_t * const)0xFFFF0040; //SPI Module Address, change this
   size_t const SPI_Rx0  = 0;
   size_t const SPI_Tx0  = 0;
   size_t const SPI_CTRL = 4;
   size_t const SPI_DIV  = 5;
   size_t const SPI_SS   = 6;

   uint32_t const SPI_CTRL_ASS  = (1 << 13); //Auto Slave Select
   uint32_t const SPI_CTRL_TXNEG= (1 << 10);
   uint32_t const SPI_CTRL_RXNEG= (1 << 9);
   uint32_t const SPI_CTRL_BUSY = (1 << 8);  //Busy Flag/Start XFER

   void spi_ss_on()
   {
      TEMP_SPI[SPI_SS] = 1;
   }

   void spi_ss_off()
   {
      TEMP_SPI[SPI_SS] = 0;
   }

   void spi_ss_auto()
   {
      uint32_t ctrl = TEMP_SPI[SPI_CTRL];
      ctrl |= SPI_CTRL_ASS;
      TEMP_SPI[SPI_CTRL] = ctrl;
   }

   void spi_ss_manual()
   {
      uint32_t ctrl = TEMP_SPI[SPI_CTRL];
      ctrl &= ~SPI_CTRL_ASS;
      TEMP_SPI[SPI_CTRL] = ctrl;
   }

   unsigned spi_busy()
   {
      return TEMP_SPI[SPI_CTRL] & SPI_CTRL_BUSY;
   }

   void spi_setSpeed(uint8_t speed)
   {
      speed &= 0xFE;
		TEMP_SPI[SPI_DIV] = speed;
	}
	
	void spi_startXFER(void)
	{
		TEMP_SPI[SPI_CTRL] |= SPI_CTRL_BUSY;
	}
	
	uint16_t spi_send(uint16_t outgoing)
	{
		uint16_t incoming;

		TEMP_SPI[SPI_Tx0] = outgoing;
		spi_startXFER();
		while( spi_busy() );
		incoming = TEMP_SPI[SPI_Rx0];

		return(incoming);
	}
	
	uint32_t const CONVTIME = 4*20000;//20000; //We assume 2 clocks per loop iteration
	
	//NO-OP NU NU CONV4 CONV3 CONV2 CONV1 DV4 DV2 NU NU CHS CAL NUL PDX PD
   uint16_t const ADC_OP         = (1 << 15);
   uint16_t const ADC_CONV_21MS  = (0x9 << 9);
   uint16_t const ADC_CONV_41MS  = (0x3 << 9);
   uint16_t const ADC_CONV_164MS = (0x6 << 9);
   uint16_t const ADC_CONV_205MS = (0x0 << 9);
   uint16_t const ADC_DV4        = (1 << 8);
   uint16_t const ADC_DV2        = (1 << 7);
   uint16_t const ADC_CHS        = (1 << 4);
   uint16_t const ADC_CAL        = (1 << 3);
   uint16_t const ADC_NUL        = (1 << 2);

   //ADC_OP | ADC_CONV_21MS;
   uint16_t ADC_CONFIG = ADC_OP | ADC_CONV_164MS | ADC_DV4;
}

void temperature_init()
{
   spi_ss_off();
   spi_ss_manual();

   TEMP_SPI[SPI_CTRL] |= 16; //16 bit transfers
   TEMP_SPI[SPI_CTRL] |= SPI_CTRL_TXNEG; //Transmit changes on negedge / Latch Pos edge

   spi_setSpeed( 20 );

   spi_ss_on();
   spi_ss_auto();

   //Calibrate CH1

	spr_int_setmask(0x04);//Hackish, clean this up
   spi_send(ADC_CONFIG | ADC_CAL | ADC_NUL); //Step 1/3
   spr_int_clearflags(0x4);
   while( spr_int_getflags() & 0x4 == 0 );
   //for( int volatile i = 0; i < CONVTIME; ++i );
   spi_send(ADC_CONFIG | ADC_CAL          ); //Step 2/3
   spr_int_clearflags(0x4);
   while( spr_int_getflags() & 0x4 == 0 );
   //for( int volatile i = 0; i < CONVTIME*20; ++i );
   spi_send(ADC_CONFIG           | ADC_NUL); //Step 3/3
   spr_int_clearflags(0x4);
   while( spr_int_getflags() & 0x4 == 0 );
   //for( int volatile i = 0; i < CONVTIME; ++i );
   spi_send(ADC_CONFIG); //Step 4/3
   spr_int_clearflags(0x4);
   while( spr_int_getflags() & 0x4 == 0 );
   //for( int volatile i = 0; i < CONVTIME; ++i );
}

int16_t temperature_lastconvert1()
{
   return (int16_t)spi_send(ADC_CONFIG);
}

int16_t temperature_lastconvert2()
{
   return (int16_t)spi_send(ADC_CONFIG | ADC_CHS);
}

float raw_to_celcius(int raw)
{
   const float rinf = 32824.3;
   const float b = -12.6334;
   float tmp;
   tmp = raw/rinf;
   tmp = log(tmp);
   tmp = b/tmp;
   return tmp;
}

int16_t temp1 = 0, temp2 = 0;
void temp_event()
{
   //We alernate what temp we read and queue the next
   if( temp2_next )
   {
      temp2 = temperature_lastconvert1();
   }
   else
   {
      temp1 = temperature_lastconvert2();
   }

   temp2_next = !temp2_next;

   if( temp2 < 0 )
   {
      debug("Neg Temp2");
   }
}
