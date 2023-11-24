/****************************************************************************/
/*  strcoll v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <string.h>

int   strcoll(const char *string1, const char *string2)
{
     register const char *r1 = string1 - 1;
     register const char *r2 = string2 - 1;
     register char cp;
 
     while ((*++r2 == (cp = *++r1)) && cp);
     return *r1 - *r2;
}
