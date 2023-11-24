/****************************************************************************/
/*  fmod   v6.10                                                            */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#undef _INLINE          /* DISABLE INLINE EXPANSION */
#include <math.h>

/****************************************************************************/
/*  FMOD() - Floating point remainder                                       */
/*									    */
/*  Returns the remainder after dividing x by y an integral number of times.*/
/*                                                                          */
/****************************************************************************/
double fmod(double x, double y)
{
   double d = fabs(x); 

   /*************************************************************************/
   /* if y is too small, any remainder is negligible.                       */
   /*************************************************************************/
   if (d - fabs(y) == d) return (0.0);

   /*************************************************************************/
   /* otherwise, divide; result = dividend - (quotient * divisor)           */
   /*************************************************************************/
   modf(x/y, &d);
   return (x - d * y);
}
