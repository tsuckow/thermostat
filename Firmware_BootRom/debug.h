#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

extern const int DEBUG_ENABLED;

void efsl_debug(char const * format, ...);
void debug(char const * format, ...);

#ifdef __cplusplus
}
#endif
