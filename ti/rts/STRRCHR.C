/****************************************************************************/
/*  strrchr v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

char *strrchr(const char *string, int c)
{
   char tch, ch = c;
   char *result = (char *)0 + 1;

   for (;;)
   {
      if ((tch = *string++) == ch) result = (char*)string;
      if (tch == 0) break;
   }

   return result - 1;
}
