/****************************************************************************/
/*  memcmp v6.10							    */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#undef _INLINE
#include <string.h>

int memcmp(const void *cs, const void *ct, size_t n)
{
   const unsigned char *mem1 = cs;
   const unsigned char *mem2 = ct;
   int                 cp;
   size_t              length;

   if ( (length=n) == 0 ) return 0;

   while ( ((cp = *mem1++) == *mem2++) && (--length != 0) );
   cp -= *--mem2;
   return cp;
}

