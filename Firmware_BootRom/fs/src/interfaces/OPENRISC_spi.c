/*****************************************************************************\
*              efs - General purpose Embedded Filesystem library              *
*          --------------------- -----------------------------------          *
*                                                                             *
* Filename : OPENRISC_spi.c                                                    *
* Description : This file contains the functions needed to use efs for        *
*               accessing files on an SD-card connected to an OPENRISC.       *
*                                                                             *
* This program is free software; you can redistribute it and/or               *
* modify it under the terms of the GNU General Public License                 *
* as published by the Free Software Foundation; version 2                     *
* of the License.                                                             *
                                                                              *
* This program is distributed in the hope that it will be useful,             *
* but WITHOUT ANY WARRANTY; without even the implied warranty of              *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               *
* GNU General Public License for more details.                                *
*                                                                             *
* As a special exception, if other files instantiate templates or             *
* use macros or inline functions from this file, or you compile this          *
* file and link it with other works to produce a work based on this file,     *
* this file does not by itself cause the resulting work to be covered         *
* by the GNU General Public License. However the source code for this         *
* file must still be made available in accordance with section (3) of         *
* the GNU General Public License.                                             *
*                                                                             *
* This exception does not invalidate any other reasons why a work based       *
* on this file might be covered by the GNU General Public License.            *
*                                                                             *
*                                                    (c)2005 Martin Thomas    *
\*****************************************************************************/

/*****************************************************************************/
#include "interfaces/OPENRISC_spi.h"
#include "interfaces/sd.h"
#include "config.h"
#include <stdint.h>
#include <unistd.h>
/*****************************************************************************/

volatile uint32_t * const SPI = (uint32_t * const)0xFFFF0000; //SPI Module Address, change this
size_t const SPI_Rx0  = 0;
size_t const SPI_Tx0  = 0;
size_t const SPI_CTRL = 4;
size_t const SPI_DIV  = 5;
size_t const SPI_SS   = 6;

uint32_t const SPI_CTRL_ASS  = (1 << 13); //Auto Slave Select
uint32_t const SPI_CTRL_TXNEG= (1 << 10);
uint32_t const SPI_CTRL_RXNEG= (1 << 9);
uint32_t const SPI_CTRL_BUSY = (1 << 8);  //Busy Flag/Start XFER


#ifndef HW_ENDPOINT_OPENRISC_SD
#error "HW_ENDPOINT_OPENRISC_SD has to be defined in config.h"
#endif

void if_ss_on(void)
{
	SPI[SPI_SS] = 1;
}

void if_ss_off(void)
{
	SPI[SPI_SS] = 0;
}

void if_ss_auto(void)
{
	uint32_t ctrl = SPI[SPI_CTRL];
	ctrl |= SPI_CTRL_ASS;
	SPI[SPI_CTRL] = ctrl;
}

void if_ss_manual(void)
{
	uint32_t ctrl = SPI[SPI_CTRL];
	ctrl &= ~SPI_CTRL_ASS;
	SPI[SPI_CTRL] = ctrl;
}

unsigned if_isBusy(void)
{
	return SPI[SPI_CTRL] & SPI_CTRL_BUSY;
}

void if_startXFER(void)
{
	SPI[SPI_CTRL] |= SPI_CTRL_BUSY;
}

esint8 if_initInterface(hwInterface* file, eint8* opts)
{
	if_spiInit(file); /* init at low speed */
	return sd_Init(file);
}
/*****************************************************************************/ 

esint8 if_readBuf(hwInterface* file,euint32 address,euint8* buf)
{
	//DBG((TXT("if_readBuf::Trying to read sector %u and store it at %p.\n"),address,buf));
	return(sd_read(buf,address));
}
/*****************************************************************************/

esint8 if_writeBuf(hwInterface* file,euint32 address,euint8* buf)
{
	//DBG((TXT("Trying to write %u to sector %u.\n"),buf,address));
	return(sd_write(buf,address));
}
/*****************************************************************************/ 

esint8 if_setPos(hwInterface* file,euint32 address)
{
	return(0);
}
/*****************************************************************************/ 

void if_spiInit(hwInterface *iface)
{
	if_ss_off();
	if_ss_manual();
	
	SPI[SPI_CTRL] |= 8; //8 bit transfers
	SPI[SPI_CTRL] |= SPI_CTRL_TXNEG; //Transmit changes on negedge / Latch Pos edge
}
/*****************************************************************************/

void if_spiSetSpeed(euint8 speed)
{
	speed &= 0xFE;
	SPI[SPI_DIV] = speed;
}

/*****************************************************************************/

euint8 if_spiSend(euint8 outgoing)
{
	euint8 incoming;

	while( if_isBusy() );
	SPI[SPI_Tx0] = outgoing;
	if_startXFER();
	while( if_isBusy() );
	incoming = SPI[SPI_Rx0];

	return(incoming);
}
/*****************************************************************************/

