#include <stdint.h>
#include "test.h"
#include "exceptions.h"

class HEHE
{
int i;
public:
   int doit(int num)
   {
      ++i;
      return num + i;
   }
};

int test(int bob)
{
   static HEHE mine;
   return mine.doit(bob) + 23;
}

/*
long exception_system_call(long arg1, long arg2, long arg3, long arg4, long arg5, long arg6)
{
   register long code __asm__ ("r11");
   if( code == 0x80 )
   {
      uint32_t * tmp = reinterpret_cast<uint32_t *>(arg1);
      *tmp = *tmp + 1;
   }
   return 0;
}
*/