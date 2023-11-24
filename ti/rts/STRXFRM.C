/****************************************************************************/
/*  strxfrm v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <stddef.h>
#include <string.h>

size_t strxfrm(register char *to, register const char *from, register size_t n)
{
     register int count = 0;     
     while (*from++) count++;                       /* GET LENGTH OF STRING */
     from -= count;
     from--;

     if (n) while ((*to++ = *from++) && --n);       /* COPY STRING          */

     return (count);
}
