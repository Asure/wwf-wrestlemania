/****************************************************************************/
/*  time v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/

/****************************************************************************/
/* OBVIOUSLY, THIS IS SIMPLY A STUB, WHICH BY DEFINITION RETURNS -1         */
/* IF THE SYSTEM TIME IS UNAVAILABLE.                                       */ 
/****************************************************************************/
#include <time.h> 

time_t time(time_t *timer)
{
    if (timer) *timer = -1;
    return -1;
}
