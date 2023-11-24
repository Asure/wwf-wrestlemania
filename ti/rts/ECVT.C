/****************************************************************************/
/*  ecvt v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include "math.h"

char *ecvt(double value, register int ndigit, int *decpt, int *sign)

{
    static char out[100]; 

    register int   digits = 0;         /* NUMBER OF DIGITS BEFORE .       */
    register char *pos    = out + 1;     
    register int   temp;

    out[0] = '0';                      /* JUST IN CASE WE ROUND.          */
    ndigit++;                          /* DO ONE EXTRA DIGIT FOR ROUNDING */

    /*--------------------------------------------------------------------*/
    /* IF TRYING TO CONVERT INFINITY, RETURN HUGE_VAL OF PROPER SIGN      */
    /*--------------------------------------------------------------------*/
    { 
       int *ptr = (int *)&value;
#if _TMS340_IEEE
       if (((ptr[0] >> 20) & 0x7ff) == 0x7ff) 
	  value = (ptr[0] & 0x80000000) ? -HUGE_VAL : HUGE_VAL;
#else
       if (((ptr[1] >> 20) & 0x7ff) == 0x7ff) 
	  value = (ptr[1] & 0x80000000) ? -HUGE_VAL : HUGE_VAL;
#endif
    }

    /*--------------------------------------------------------------------*/
    /* PERFORM PRESCALING - MAKE SURE NUMBER HAS INTEGRAL WHOLE PART      */
    /*--------------------------------------------------------------------*/
    if (*sign = (value < 0)) value = -value;
    while (value > 0x7FFFFFFF) { value /= 10; digits++; }
    while (value && value < 1) { value *= 10; digits--; }

    /*--------------------------------------------------------------------*/
    /* WRITE OUT INTEGRAL PART OF NUMBER.                                 */
    /*--------------------------------------------------------------------*/
    pos    += temp    = ltoa((int)value, pos);
    *decpt  = digits + temp;
    value  -= (int)value;

    /*--------------------------------------------------------------------*/
    /* WRITE OUT FRACTIONAL PART OF NUMBER                                */
    /*--------------------------------------------------------------------*/
    if (temp >= ndigit) 
	 pos = out + ndigit;
    else
         for (ndigit -= temp, pos--; ndigit--; value -= (int)value) 
              *++pos = (value *= 10) + '0';

    /*--------------------------------------------------------------------*/
    /* PERFORM ROUNDING.  NOTE THAT pos IS CURRENTLY POINTING AT AN EXTRA */
    /* DIGIT WHICH WAS CONVERTED FOR THIS PURPOSE.                        */
    /*--------------------------------------------------------------------*/
    if (*pos >= '5')
    {
	register char *ptr = pos;
	while ((*--ptr += 1) > '9') *ptr = '0';
	if (ptr == out) { *--pos = 0; *decpt += 1; return(out); }
    }
	
    *pos = 0;
    return(out + 1);
}

