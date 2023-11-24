/****************************************************************************/
/*  strcspn v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <string.h>

size_t strcspn(register const char *string, const char *chs)
{
     register char ch;
     size_t count = 0;

     while (ch = *string++)  /* FOR EACH CHARACTER IN STRING */
     {
        register const char *check = chs;
	register char  tch         = *check;

        while(tch)    /* FOR EACH CHARACTER IN LOOKUP STRING */
           if (ch == tch) return ((size_t) count);
	   else tch = *++check;

	count++;
     }

     return (size_t) count;
}
