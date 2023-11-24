/****************************************************************************/
/*  memchr v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

void *memchr(const void *cs, int c, size_t n)
{
   size_t length;

   if ( (length=n) > 0 )
   {
      const unsigned char *mem = cs;   
      unsigned char       ch   = c;

      do if ( *mem++ == ch ) return mem - 1;
      while (--length != 0);
   }
   
   return NULL;
}
