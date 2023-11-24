/****************************************************************************/
/*  memmov v6.10							    */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

void *memcpy(void *s1, const void *s2, register size_t n)
{
    register char *src = s2;
    register char *dest = s1;
    register void *result = dest;

    while (n--) *dest++ = *src++;
    return result;
}

void *memmove(void *s1, const void *s2, size_t n)
{
    register char *src = s2;
    register char *dest = s1;
    register void *result = dest;

    if (src > dest) 
       while (n--) *dest++ = *src++;
    else 
    {
       src += n;
       dest += n;
       while (n--) *--dest = *--src;
    } 

    return result;
}

