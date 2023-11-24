/****************************************************************************/
/*  ctime   v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <time.h>

char *ctime(const time_t *timer)
{
   return(asctime(localtime(timer)));
}
