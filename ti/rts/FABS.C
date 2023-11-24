/****************************************************************************/
/*  fabs   v6.10                                                            */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#include <math.h>

/****************************************************************************/
/*  FABS() - Floating Point Absolute Value				    */
/*									    */
/*  The definition below is NOT a recursive definition!  The compiler       */
/*  generates calls to fabs() inline, using a single ABS instruction.       */
/****************************************************************************/
double fabs(double x)
{
    return fabs(x);        /* This will be generated inline by the compiler */
}
