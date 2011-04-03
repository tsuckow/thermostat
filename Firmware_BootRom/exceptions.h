#ifndef EXCEPTIONS_H
#define EXCEPTIONS_H

#ifdef __cplusplus
extern "C"
{
#endif

//void external_exception();

long exception_system_call(long arg1, long arg2, long arg3, long arg4, long arg5, long arg6);

#ifdef __cplusplus
}
#endif

#endif
