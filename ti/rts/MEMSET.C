/****************************************************************************/
/*  memset v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

void *memset(void *mem, register int ch, register size_t length)
{
     register char *result = mem;

     while (length-- > 0) *result++ = ch;
   
     return mem;
}
