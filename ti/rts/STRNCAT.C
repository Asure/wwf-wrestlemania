/****************************************************************************/
/*  strncat v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

char *strncat(char *dest, register const char *src, register size_t n)
{
     register char *r1 = dest - 1;

     if (n == 0) return dest;
     while (*++r1);                                  /* FIND END OF STRING   */
     while ((*r1++ = *src++) && --n);                /* APPEND SECOND STRING */
     *r1 = 0;
     return dest;
}

