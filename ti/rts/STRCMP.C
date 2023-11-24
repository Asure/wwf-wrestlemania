/****************************************************************************/
/*  strcmp v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

int   strcmp(const char *string1, const char *string2)
{
   char cp1;
   char cp2;

   while (((cp1 = *string1++) == (cp2 = *string2++)) && cp1);
   return cp1 - cp2;
}

