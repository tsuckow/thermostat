#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

void temperature_init();
float raw_to_celcius(int raw);
extern int16_t temp1, temp2;

#ifdef __cplusplus
}
#endif