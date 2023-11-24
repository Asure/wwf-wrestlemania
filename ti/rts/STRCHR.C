/****************************************************************************/
/*  strchr v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

char *strchr(const char *string, int c)
{
   char ch = c;
   char tch;

   for (;;)
     if      ( (tch = *string++) == ch ) return (char*)(string-1);
     else if ( tch == 0 )                return (char*)0;
}
