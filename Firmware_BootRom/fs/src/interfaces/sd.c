/*****************************************************************************\
*              efs - General purpose Embedded Filesystem library              *
*          --------------------- -----------------------------------          *
*                                                                             *
* Filename : sd.c                                                             *
* Revision : Initial developement                                             *
* Description : This file contains the functions needed to use efs for        *
*               accessing files on an SD-card.                                *
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
*                                                    (c)2006 Lennart Yseboodt *
*                                                    (c)2006 Michael De Nil   *
\*****************************************************************************/

/*****************************************************************************/
#include "interfaces/sd.h"
/*****************************************************************************/

#define SD_COMMAND_TIMEOUT 5000

#define R1_IDLE_STATE           (1 << 0)
#define R1_ERASE_RESET          (1 << 1)
#define R1_ILLEGAL_COMMAND      (1 << 2)
#define R1_COM_CRC_ERROR        (1 << 3)
#define R1_ERASE_SEQUENCE_ERROR (1 << 4)
#define R1_ADDRESS_ERROR        (1 << 5)
#define R1_PARAMETER_ERROR      (1 << 6)

/*
// Types
//  - v1.x Standard Capacity
//  - v2.x Standard Capacity
//  - v2.x High Capacity
//  - Not recognised as an SD Card
*/

#define SDCARD_FAIL 0
#define SDCARD_V1   1
#define SDCARD_V2   2
#define SDCARD_V2HC 3

int _cmd(int cmd, int arg);
int _cmd8();
int _cmd58();
int _read(char *buffer, int length);
int _write(const char *buffer, int length);

int initialise_card_v1(void)
{
	int i;
    for(i=0; i<SD_COMMAND_TIMEOUT; i++)
	{
        _cmd(55, 0); 
        if(_cmd(41, 0) == 0) { 
            return SDCARD_V1;
        }
    }

    DBG((TXT("Timeout waiting for v1.x card\n")));
    return SDCARD_FAIL;
}

int initialise_card_v2(void)
{
    int i;
    for(i=0; i<SD_COMMAND_TIMEOUT; i++) {
        _cmd(55, 0); 
        if(_cmd(41, 0) == 0) { 
            _cmd58();
            return SDCARD_V2;
        }
    }

    DBG((TXT("Timeout waiting for v2.x card\n")));
    return SDCARD_FAIL;
}

int initialise_card(void)
{
	int i;
	
    // Set to slow clock for initialisation, and clock card with cs = 1
    if_spiSetSpeed(254); 
    if_ss_off();
    for(i=0; i<20; i++) {   
        if_spiSend(0xFF);
    }

    // send CMD0, should return with all zeros except IDLE STATE set (bit 0)
    if(_cmd(0, 0) != R1_IDLE_STATE) { 
        DBG((TXT("No disk, or could not put SD card in to SPI idle state\n")));
        return SDCARD_FAIL;
    }

    // send CMD8 to determine whther it is ver 2.x
    int r = _cmd8();
    if(r == R1_IDLE_STATE) {
        return initialise_card_v2();
    } else if(r == (R1_IDLE_STATE | R1_ILLEGAL_COMMAND)) {
        return initialise_card_v1();
    } else {
        DBG((TXT("Not in idle state after sending CMD8 (not an SD card?)\n")));
        return SDCARD_FAIL;
    }
}

esint8 sd_Init(hwInterface *iface)
{

    int i = initialise_card();

    // Set block length to 512 (CMD16)
    if(_cmd(16, 512) != 0) {
        DBG((TXT("Set 512-byte block timed out\n")));
        return 1;
    }
    
    if_spiSetSpeed(50);
	DBG((TXT("SD INIT DONE")));
    return 0;
}

int sd_write(const char *buffer, int block_number) {
    // set write address for single block (CMD24)
    if(_cmd(24, block_number * 512) != 0) {
        return 1;
    }

    // send the data block
    _write(buffer, 512);    
    return 0;    
}

int sd_read(char *buffer, int block_number) {        
    // set read address for single block (CMD17)
    if(_cmd(17, block_number * 512) != 0) {
        return 1;
    }
    
    // receive the data
    _read(buffer, 512);
    return 0;
}

int _cmd(int cmd, int arg)
{
	int i;
    if_ss_on();

    // send a command
    if_spiSend(0x40 | cmd);
    if_spiSend(arg >> 24);
    if_spiSend(arg >> 16);
    if_spiSend(arg >> 8);
    if_spiSend(arg >> 0);
    if_spiSend(0x95);

    // wait for the repsonse (response[7] == 0)
    for(i=0; i<SD_COMMAND_TIMEOUT; i++) {
        int response = if_spiSend(0xFF);
        if(!(response & 0x80)) {
            if_ss_off();
            if_spiSend(0xFF);
            return response;
        }
    }
    if_ss_off();
    if_spiSend(0xFF);
    return -1; // timeout
}

int _cmd8()
{
	int i;
    if_ss_on();
    
    // send a command
    if_spiSend(0x40 | 8); // CMD8
    if_spiSend(0x00);     // reserved
    if_spiSend(0x00);     // reserved
    if_spiSend(0x01);     // 3.3v
    if_spiSend(0xAA);     // check pattern
    if_spiSend(0x87);     // crc

    // wait for the repsonse (response[7] == 0)
    for(i=0; i<SD_COMMAND_TIMEOUT * 1000; i++) {
        char response[5];
        response[0] = if_spiSend(0xFF);
        if(!(response[0] & 0x80))
		{
			int j;
                for(j=1; j<5; j++) {
                    response[i] = if_spiSend(0xFF);
                }
                if_ss_off();
                if_spiSend(0xFF);
                return response[0];
        }
    }
    if_ss_off();
    if_spiSend(0xFF);
    return -1; // timeout
}

int _cmd58()
{
    int i;
    if_ss_on();
    int arg = 0;
    
    // send a command
    if_spiSend(0x40 | 58);
    if_spiSend(arg >> 24);
    if_spiSend(arg >> 16);
    if_spiSend(arg >> 8);
    if_spiSend(arg >> 0);
    if_spiSend(0x95);

    // wait for the repsonse (response[7] == 0)
    for(i=0; i<SD_COMMAND_TIMEOUT; i++) {
        int response = if_spiSend(0xFF);
        if(!(response & 0x80)) {
            int ocr = if_spiSend(0xFF) << 24;
            ocr |= if_spiSend(0xFF) << 16;
            ocr |= if_spiSend(0xFF) << 8;
            ocr |= if_spiSend(0xFF) << 0;
//            printf("OCR = 0x%08X\n", ocr);
            if_ss_off();
            if_spiSend(0xFF);
            return response;
        }
    }
    if_ss_off();
    if_spiSend(0xFF);
    return -1; // timeout
}

int _read(char *buffer, int length)
{
	int i;
    if_ss_on();

    // read until start byte (0xFF)
    while(if_spiSend(0xFF) != 0xFE);

    // read data
    for(i=0; i<length; i++) {
        buffer[i] = if_spiSend(0xFF);
    }
    if_spiSend(0xFF); // checksum
    if_spiSend(0xFF);

    if_ss_off();
    if_spiSend(0xFF);
    return 0;
}

int _write(const char *buffer, int length)
{
	int i;
    if_ss_on();
    
    // indicate start of block
    if_spiSend(0xFE);
    
    // write the data
    for(i=0; i<length; i++) {
        if_spiSend(buffer[i]);
    }
    
    // write the checksum
    if_spiSend(0xFF); 
    if_spiSend(0xFF);

    // check the repsonse token
    if((if_spiSend(0xFF) & 0x1F) != 0x05) {
        if_ss_off();
        if_spiSend(0xFF);        
        return 1;
    }

    // wait for write to finish
    while(if_spiSend(0xFF) == 0);

    if_ss_off();
    if_spiSend(0xFF);
    return 0;
}