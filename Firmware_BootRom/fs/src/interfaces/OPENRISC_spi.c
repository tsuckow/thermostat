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
	euint32 sc;
	
	if_spiInit(file); /* init at low speed */
	
	if(sd_Init(file)<0)	{
		DBG((TXT("Card failed to init, breaking up...\n")));
		return(-1);
	}
	if(sd_State(file)<0){
		DBG((TXT("Card didn't return the ready state, breaking up...\n")));
		return(-2);
	}
	
	// file->sectorCount=4; /* FIXME ASAP!! */
	
	sd_getDriveSize(file, &sc);
	file->sectorCount = sc/512;
	if( (sc%512) != 0) {
		file->sectorCount--;
	}
	DBG((TXT("Drive Size is %lu Bytes (%lu Sectors)\n"), sc, file->sectorCount));
	
	 /* increase speed after init */
	if_spiSetSpeed(8);
	// if_spiSetSpeed(100); /* debug - slower */
	
	DBG((TXT("Init done...\n")));
	return(0);
}
/*****************************************************************************/ 

esint8 if_readBuf(hwInterface* file,euint32 address,euint8* buf)
{
	return(sd_readSector(file,address,buf,512));
}
/*****************************************************************************/

esint8 if_writeBuf(hwInterface* file,euint32 address,euint8* buf)
{
	return(sd_writeSector(file,address, buf));
}
/*****************************************************************************/ 

esint8 if_setPos(hwInterface* file,euint32 address)
{
	return(0);
}
/*****************************************************************************/ 

void if_spiInit(hwInterface *iface)
{
	euint8 i; 

	if_ss_off();
	if_ss_manual();
	
	SPI[SPI_CTRL] |= 8; //8 bit transfers
	
	// low speed during init
	if_spiSetSpeed(254); 

	/* Send 20 spi commands with card not selected */
	for(i=0;i<21;i++)
		if_spiSend(iface,0xff);

	// enable automatic slave CS for SSP
	if_ss_auto();
	if_ss_on();
}
/*****************************************************************************/

void if_spiSetSpeed(euint8 speed)
{
	speed &= 0xFE;
	SPI[SPI_DIV] = speed;
}

/*****************************************************************************/

euint8 if_spiSend(hwInterface *iface, euint8 outgoing)
{
	euint8 incoming;

	// SELECT_CARD();  // done by hardware
	while( if_isBusy() );
	SPI[SPI_Tx0] = outgoing;
	if_startXFER();
	while( if_isBusy() );
	incoming = SPI[SPI_Rx0];
	// UNSELECT_CARD();  // done by hardware

	return(incoming);
}
/*****************************************************************************/

