#ifndef __INSN_H__
#define __INSN_H__

#include <hbird_sdk_soc.h>


__STATIC_FORCEINLINE void jlsd(int addr)
{
    int zero = 0;
    
    asm volatile (
       ".insn r 0x7b, 2, 0, x0, %1, x0"
           :"=r"(zero)
           :"r"(addr)
     );
}

__STATIC_FORCEINLINE void fconv(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 1, x0, %1, x0"
           :"=r"(zero)
           :"r"(addr)
     );
}

__STATIC_FORCEINLINE void sconv(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 2, x0, %1, x0"
           :"=r"(zero)
           :"r"(addr)
     );
}


__STATIC_FORCEINLINE void jlweight(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 3, x0, %1, x0"
           :"=r"(zero)
           :"r"(addr)
     );
}
__STATIC_FORCEINLINE void jact()
{


    asm volatile (
       ".insn r 0x7b, 0, 6, x0, x0, x0"

     );
}


__STATIC_FORCEINLINE unsigned  int  jconv(void )
{
	unsigned int result = 0;
    int zero = 0;
    asm volatile (
       ".insn r 0x7b, 4, 7, %0, %1, x0"
           :"=r"(result)
           :"r"(zero)
     );
    return result;
}

#endif

