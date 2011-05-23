
/*****************************************************************************/
#include "sd_spi.h"

#include <stdint.h>
#include <unistd.h>
/*****************************************************************************/

volatile uint32_t * const SDSPI = (uint32_t * const)0xFFFF0000; //SPI Module Address, change this
size_t const SDSPI_Rx0  = 0;
size_t const SDSPI_Tx0  = 0;
size_t const SDSPI_CTRL = 4;
size_t const SDSPI_DIV  = 5;
size_t const SDSPI_SS   = 6;

uint32_t const SDSPI_CTRL_ASS  = (1 << 13); //Auto Slave Select
uint32_t const SDSPI_CTRL_TXNEG= (1 << 10);
uint32_t const SDSPI_CTRL_RXNEG= (1 << 9);
uint32_t const SDSPI_CTRL_BUSY = (1 << 8);  //Busy Flag/Start XFER

void sdspi_ss_on(void)
{
	SDSPI[SDSPI_SS] = 1;
}

void sdspi_ss_off(void)
{
	SDSPI[SDSPI_SS] = 0;
}

void sdspi_ss_auto(void)
{
	uint32_t ctrl = SDSPI[SDSPI_CTRL];
	ctrl |= SDSPI_CTRL_ASS;
	SDSPI[SDSPI_CTRL] = ctrl;
}

void sdspi_ss_manual(void)
{
	uint32_t ctrl = SDSPI[SDSPI_CTRL];
	ctrl &= ~SDSPI_CTRL_ASS;
	SDSPI[SDSPI_CTRL] = ctrl;
}

unsigned sdspi_isBusy(void)
{
	return SDSPI[SDSPI_CTRL] & SDSPI_CTRL_BUSY;
}

void sdspi_startXFER(void)
{
	SDSPI[SDSPI_CTRL] |= SDSPI_CTRL_BUSY;
}

/*****************************************************************************/ 

void sdspi_init()
{
	sdspi_ss_off();
	sdspi_ss_manual();
	
	SDSPI[SDSPI_CTRL] |= 8; //8 bit transfers
	SDSPI[SDSPI_CTRL] |= SDSPI_CTRL_TXNEG; //Transmit changes on negedge / Latch Pos edge
}
/*****************************************************************************/

void sdspi_setSpeed(uint8_t speed)
{
	speed &= 0xFE;
	SDSPI[SDSPI_DIV] = speed;
}

/*****************************************************************************/

uint8_t sdspi_send(uint8_t outgoing)
{
	uint8_t incoming;

	while( if_isBusy() );
	SDSPI[SDSPI_Tx0] = outgoing;
	sdspi_startXFER();
	while( if_isBusy() );
	incoming = SDSPI[SDSPI_Rx0];

	return(incoming);
}
/*****************************************************************************/

