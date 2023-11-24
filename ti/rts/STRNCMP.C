/****************************************************************************/
/*  strncmp v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

int  strncmp(const char *string1, const char *string2, register size_t n)
{
     register const char *r1 = string1;
     register const char *r2 = string2;
     register char  cp;
     register int  result;

     if (n == 0) return 0; 
     do 
        if (result = *r1++ - (cp = *r2++)) return result;
     while (cp != 0 && --n);

     return 0;
}
