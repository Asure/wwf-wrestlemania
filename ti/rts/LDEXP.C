/****************************************************************************/
/*  ldexp  v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <math.h>

double ldexp(double x, int exp)
{
     int *ptr = (int *)&x;

#if _TMS340_IEEE
     exp += (ptr[0] >> 20) & 0x7FF;
#else
     exp += (ptr[1] >> 20) & 0x7FF;
#endif
 
     if (exp < 1)     return 0.0;              /* RESULT UNDERFLOWS */
     if (exp > 0x7FF) return HUGE_VAL;         /* RESULT OVERFLOWS  */

#if _TMS340_IEEE
     ptr[0] = (ptr[0] & 0x800FFFFF) | (exp << 20);
#else
     ptr[1] = (ptr[1] & 0x800FFFFF) | (exp << 20);
#endif
     
     return x;
}

