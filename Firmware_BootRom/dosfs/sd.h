#ifndef __SD_H__
#define __SD_H__

#include <stdint.h>
#include <unistd.h>

uint8_t sd_Init();
uint32_t DFS_ReadSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count);
uint32_t DFS_WriteSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count);

#endif
