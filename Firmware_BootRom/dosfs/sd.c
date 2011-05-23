
/*****************************************************************************/
#include "sd.h"
#include <stdio.h>
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

int sd_cmd(int cmd, int arg);
int sd_cmd8();
int sd_cmd58();
int sd_read(char *buffer, int length);
int sd_write(const char *buffer, int length);

int sd_initialise_card_v1(void)
{
	int i;
    for(i=0; i<SD_COMMAND_TIMEOUT; i++)
	{
        sd_cmd(55, 0); 
        if(sd_cmd(41, 0) == 0) { 
            return SDCARD_V1;
        }
    }

    printf("Timeout waiting for v1.x card\n");
    return SDCARD_FAIL;
}

int sd_initialise_card_v2(void)
{
    int i;
    for(i=0; i<SD_COMMAND_TIMEOUT; i++) {
        sd_cmd(55, 0); 
        if(sd_cmd(41, 0) == 0) { 
            sd_cmd58();
            return SDCARD_V2;
        }
    }

    printf("Timeout waiting for v2.x card\n");
    return SDCARD_FAIL;
}

int sd_initialise_card(void)
{
	int i;
	
    // Set to slow clock for initialisation, and clock card with cs = 1
    sdspi_setSpeed(254); 
    sdspi_ss_off();
    for(i=0; i<20; i++) {   
        sdspi_send(0xFF);
    }

    // send CMD0, should return with all zeros except IDLE STATE set (bit 0)
    if(sd_cmd(0, 0) != R1_IDLE_STATE) { 
        printf("No disk, or could not put SD card in to SPI idle state\n");
        return SDCARD_FAIL;
    }

    // send CMD8 to determine whther it is ver 2.x
    int r = _cmd8();
    if(r == R1_IDLE_STATE) {
        return sd_initialise_card_v2();
    } else if(r == (R1_IDLE_STATE | R1_ILLEGAL_COMMAND)) {
        return sd_initialise_card_v1();
    } else {
        printf("Not in idle state after sending CMD8 (not an SD card?)\n");
        return SDCARD_FAIL;
    }
}

uint8_t sd_init()
{

    int i = sd_initialise_card();

    // Set block length to 512 (CMD16)
    if(sd_cmd(16, 512) != 0) {
        printf("Set 512-byte block timed out\n");
        return 1;
    }
    
    sdspi_setSpeed(50);
	printf("SD INIT DONE\n");
    return 0;
}

uint32_t DFS_ReadSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count)
{
	if( count != 1 )
	{
		printf("Multiple Sector Read Not Implemented\n");
	}
	
	// set read address for single block (CMD17)
    if(sd_cmd(17, sector * 512) != 0) {
        return 1;
    }
    
    // receive the data
    sd_read_internal(buffer, 512);
    return 0;
}

uint32_t DFS_WriteSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count)
{
	if( count != 1 )
	{
		printf("Multiple Sector Write Not Implemented\n");
	}
	
	// set write address for single block (CMD24)
    if(sd_cmd(24, sector * 512) != 0) {
        return 1;
    }

    // send the data block
    sd_write_internal(buffer, 512);    
    return 0;
}

int sd_cmd(int cmd, int arg)
{
	int i;
    sdspi_ss_on();

    // send a command
    sdspi_send(0x40 | cmd);
    sdspi_send(arg >> 24);
    sdspi_send(arg >> 16);
    sdspi_send(arg >> 8);
    sdspi_send(arg >> 0);
    sdspi_send(0x95);

    // wait for the repsonse (response[7] == 0)
    for(i=0; i<SD_COMMAND_TIMEOUT; i++) {
        int response = sdspi_send(0xFF);
        if(!(response & 0x80)) {
            sdspi_ss_off();
            sdspi_send(0xFF);
            return response;
        }
    }
    sdspi_ss_off();
    sdspi_send(0xFF);
    return -1; // timeout
}

int sd_cmd8()
{
	int i;
    sdspi_ss_on();
    
    // send a command
    sdspi_send(0x40 | 8); // CMD8
    sdspi_send(0x00);     // reserved
    sdspi_send(0x00);     // reserved
    sdspi_send(0x01);     // 3.3v
    sdspi_send(0xAA);     // check pattern
    sdspi_send(0x87);     // crc

    // wait for the repsonse (response[7] == 0)
    for(i=0; i<SD_COMMAND_TIMEOUT * 1000; i++) {
        char response[5];
        response[0] = sdspi_send(0xFF);
        if(!(response[0] & 0x80))
		{
			int j;
                for(j=1; j<5; j++) {
                    response[i] = sdspi_send(0xFF);
                }
                sdspi_ss_off();
                sdspi_send(0xFF);
                return response[0];
        }
    }
    sdspi_ss_off();
    sdspi_send(0xFF);
    return -1; // timeout
}

int sd_cmd58()
{
    int i;
    sdspi_ss_on();
    int arg = 0;
    
    // send a command
    sdspi_send(0x40 | 58);
    sdspi_send(arg >> 24);
    sdspi_send(arg >> 16);
    sdspi_send(arg >> 8);
    sdspi_send(arg >> 0);
    sdspi_send(0x95);

    // wait for the repsonse (response[7] == 0)
    for(i=0; i<SD_COMMAND_TIMEOUT; i++) {
        int response = sdspi_send(0xFF);
        if(!(response & 0x80)) {
            int ocr = sdspi_send(0xFF) << 24;
            ocr |= sdspi_send(0xFF) << 16;
            ocr |= sdspi_send(0xFF) << 8;
            ocr |= sdspi_send(0xFF) << 0;
//            printf("OCR = 0x%08X\n", ocr);
            sdspi_ss_off();
            sdspi_send(0xFF);
            return response;
        }
    }
    sdspi_ss_off();
    sdspi_send(0xFF);
    return -1; // timeout
}

int sd_read_internal(char *buffer, int length)
{
	int i;
    sdspi_ss_on();

    // read until start byte (0xFF)
    while(sdspi_send(0xFF) != 0xFE);

    // read data
    for(i=0; i<length; i++) {
        buffer[i] = sdspi_send(0xFF);
    }
    sdspi_send(0xFF); // checksum
    sdspi_send(0xFF);

    sdspi_ss_off();
    sdspi_send(0xFF);
    return 0;
}

int sd_write_internal(const char *buffer, int length)
{
	int i;
    sdspi_ss_on();
    
    // indicate start of block
    sdspi_send(0xFE);
    
    // write the data
    for(i=0; i<length; i++) {
        sdspi_send(buffer[i]);
    }
    
    // write the checksum
    sdspi_send(0xFF); 
    sdspi_send(0xFF);

    // check the repsonse token
    if((sdspi_send(0xFF) & 0x1F) != 0x05) {
        sdspi_ss_off();
        sdspi_send(0xFF);        
        return 1;
    }

    // wait for write to finish
    while(sdspi_send(0xFF) == 0);

    sdspi_ss_off();
    sdspi_send(0xFF);
    return 0;
}