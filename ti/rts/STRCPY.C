/****************************************************************************/
/*  strcpy v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

char *strcpy(register char *dest, register const char *src)
{
     register char *result = dest;     

     while (*dest++ = *src++);
     return result;
}
