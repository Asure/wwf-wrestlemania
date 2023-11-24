/****************************************************************************/
/*  strtod v6.10                                                            */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#include <stdlib.h>
#include <ctype.h>
#include <float.h>
#include <errno.h>
#include <math.h>

/*------------------------------------------------------------------*/
/* DEFINE CONSTANTS WHICH REPRESENT POWER'S OF TEN.                 */
/*------------------------------------------------------------------*/
#ifdef _TMS340_IEEE
static const long table[]    = { 0x40240000, 0x00000000, 
                                 0x40590000, 0x00000000, 
                                 0x40C38800, 0x00000000, 
                                 0x4197D784, 0x00000000, 
                                 0x4341C379, 0x37E08000, 
                                 0x4693B8B5, 0xB5056E16, 
                                 0x4D384F03, 0xE93FF9F4, 
                                 0x5A827748, 0xF9301D36, 
                                 0x75154FDD, 0x7F73BF46, 
                               };
#else
static const long table[]    = { 0x00000000, 0x403A0000,
                                 0x00000000, 0x406C8000,
                                 0x00000000, 0x40D9C400,
                                 0x00000000, 0x41ABEBC2,
                                 0x9BF04000, 0x4358E1BC,
                                 0xDA82B70B, 0x46A9DC5A,
                                 0xF49FFCFA, 0x4D4C2781,
                                 0x7C980E9B, 0x5A993BA4,
                                 0xBFB9DFA3, 0x752AA7EE };
#endif

static const double *const powerof10 = (double *)table;

static const double digits[]   = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

double strtod(const char *st, char **endptr)
{
    double      result = 0;
    char        cp;
    const char *fst    = st;
    int         exp    = 0;               /* EXPONENT              */
    int         count;                    /* EXPONENT CALCULATION  */
    int         value  = 0;               /* SUCCESSFUL PARSE      */
    int         sign;

    while (_isspace(*fst)) ++fst;  /* SKIP WHITE SPACE */
    if ((sign = ((cp = *fst) == '-')) || (cp == '+')) { ++fst; value = 1; }

    /*----------------------------------------------------------------------*/
    /* READ IN FRACTIONAL PART OF NUMBER, UNTIL AN 'E' IS REACHED.          */
    /* COUNT DIGITS AFTER DECIMAL POINT.                                    */
    /*----------------------------------------------------------------------*/
    for (; _isdigit(cp = *fst); ++fst) 
    {
       result = result * 10 + digits[cp - '0']; 
       value  = 1;
    }

    if (cp == '.')
       while (_isdigit(cp = *++fst)) 
       {
          result = result * 10 + digits[cp - '0']; 
          value  = 1;
	  --exp;
       }

    if (sign) result = -result;  /* IF NEGATIVE NUMBER, REVERSE SIGN */

    /*----------------------------------------------------------------------*/
    /* READ IN EXPLICIT EXPONENT AND CALCULATE REAL EXPONENT.               */
    /*----------------------------------------------------------------------*/
    if (value && _toupper(*fst) == 'E')
    {
       if ((sign = ((cp = *++fst) == '-')) || (cp == '+')) cp = *++fst;

       for (count = 0; _isdigit(cp); cp = *++fst)
	  { count *= 10; count += cp - '0'; }

       if (sign) exp -= count;
	    else exp += count;
    }

    /*----------------------------------------------------------------------*/
    /* ADJUST NUMBER BY POWERS OF TEN SPECIFIED BY FORMAT AND EXPONENT.     */
    /*----------------------------------------------------------------------*/
    if (result != 0.0)
    {
       if (exp > DBL_MAX_10_EXP) 
	  { errno = ERANGE; result = (result < 0) ? -HUGE_VAL : HUGE_VAL; }
       else if (exp < DBL_MIN_10_EXP) 
	  { errno = ERANGE; result = 0.0; }

       else if (exp < 0)
	    for (count = 0, exp = -exp; exp; count++, exp >>= 1)
	        { if (exp & 1) result /= powerof10[count]; }
       else for (count = 0; exp; count++, exp >>= 1)
	        { if (exp & 1) result *= powerof10[count]; }
    }

    if (endptr) *endptr = (char *)(value ? fst : st);
    return result;
}
