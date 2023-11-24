/****************************************************************************/
/*  difftime v6.10                                                          */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <time.h> 

double difftime(time_t time1, time_t time0)
{
    return ((double)time1 - (double)time0);
}
