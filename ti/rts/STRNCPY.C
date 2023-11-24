/****************************************************************************/
/*  strncpy v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

char *strncpy(register char *dest, register const char *src, register size_t n)
{
     register char *result = dest;

     if (n == 0) return result; 
 
     while ((*dest++ = *src++) && --n != 0);      /* COPY STRING         */

     src = 0;
     if (n) do *dest++ = (char)src; while (--n);  /* TERMINATION PADDING */

     return result;
}
