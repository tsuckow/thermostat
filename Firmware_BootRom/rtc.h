#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

void rtcInit();
void rtcRead( uint8_t address, uint8_t * const data, unsigned int num );
void rtcWrite( uint8_t address, uint8_t * const data, unsigned int num );

#ifdef __cplusplus
}
#endif

