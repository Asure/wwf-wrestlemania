/****************************************************************************/
/*  strlen v6.10                                                            */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#undef _INLINE
#include <string.h>

size_t strlen(const char *string)
{
   size_t n = -1;

   do n++; while (*string++);
   return n;
}
