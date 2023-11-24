/****************************************************************************/
/*  atoi v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <stdlib.h>
#include <ctype.h>

int atoi(register const char *st)
{
    register long result = 0;
    register char cp;
    register int  sign;

    while (_isspace(*st)) ++st;  /* SKIP WHITE SPACE */

    if (sign = ((cp = *st) == '-')) cp = *++st;
    else if (cp == '+')             cp = *++st;

    while (_isdigit(cp))
    {
        result *= 10;
        result += cp - '0';
        cp = *++st;
    }

    if (sign) result *= -1;
    return result;
}

