#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

void temperature_init();
uint16_t temperature_convert1();
uint16_t temperature_convert2();

#ifdef __cplusplus
}
#endif