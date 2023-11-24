/****************************************************************************/
/*  strpbrk v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <string.h>

char *strpbrk(const char *string, const char *chs)
{
     register char *str = (char *)string - 1;
     register char ch;

     while (ch = *++str)         /* FOR EACH CHARACTER IN STRING */
     {
        register char *check = (char *)chs;     
	register char  tch;

        while(tch = *check++)    /* FOR EACH CHARACTER IN LOOKUP STRING */
           if (ch == tch) return str;
     }

     return 0;
}
