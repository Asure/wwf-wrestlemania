/****************************************************************************/
/*  ceil   v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <math.h>    

double ceil(double x)
{
     double y; 
     return (modf(x, &y) > 0 ? y + 1 : y);
}
