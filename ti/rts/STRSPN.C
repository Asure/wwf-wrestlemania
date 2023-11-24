/****************************************************************************/
/*  strspn  v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <string.h>

size_t strspn(register const char *string, const char *chs)
{
     size_t count = 0;

     for (;;)            /* FOR EACH CHARACTER IN STRING */
     {
	register char  ch    = *string++;
        register char *check = (char *)chs;
	register char  tch   = *check++;                

        while (tch)      /* FOR EACH CHARACTER IN LOOKUP STRING */
        {
	   if (ch == tch) break;
           tch = *check++;
        }

        if (!ch || ch != tch) return(count);
	count++;
     }
}
