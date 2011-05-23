#ifndef __SD_SPI_H__
#define __SD_SPI_H__

#include <stdint.h>
#include <unistd.h>

void sdspi_ss_on(void);
void sdspi_ss_off(void);

void sdspi_init();
void sdspi_setSpeed(uint8_t speed);
uint8_t sdspi_send(uint8_t outgoing);

#endif
