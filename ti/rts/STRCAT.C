/****************************************************************************/
/*  strcat v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <string.h>

char *strcat(char *string1, const char *string2)
{
   char *result = string1;

   while (*string1++);			     /* FIND END OF STRING   */
   string1--;				     /* BACK UP OVER NULL    */
   while (*string1++ = *string2++);	     /* APPEND SECOND STRING */
   return result;
}
