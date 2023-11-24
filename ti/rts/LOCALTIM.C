/****************************************************************************/
/*  localtime v6.10                                                         */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <time.h>

struct tm *localtime(const time_t *timer)
{
   static struct tm local;
   time_t ltime  = timer ? *timer : 0;

   local.tm_sec  = 0;
   local.tm_min  = 0;
   local.tm_hour = 0;
   local.tm_mday = 1;
   local.tm_mon  = 0;
   local.tm_year = 0;

   if (timer == 0 || ltime == (time_t)-1) return &local;

   /********************************************************************/
   /* MAKE SURE THE NUMBER OF SECONDS SINCE Jan 1, 1900 CAN BE         */
   /* REPRESENTED IN A SIGNED INT.                                     */
   /********************************************************************/
   if ((int)ltime < 0)
   {
       local.tm_sec  = ltime % 60; 
       local.tm_min  = ltime / 60; 
   }
   else local.tm_sec = ltime;

   mktime(&local);
   return &local;
}

