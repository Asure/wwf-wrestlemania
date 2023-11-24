/****************************************************************************/
/*  gmtime v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <time.h>

struct tm *gmtime(const time_t *timer)
{
    time_t gtime = _tz.timezone; /* DIFFERENCE BETWEEN CURRENT TIME ZONE    */
				 /* AND GMT IN SECONDS                      */

    if (timer) gtime += *timer;
    return (localtime(&gtime));
}
