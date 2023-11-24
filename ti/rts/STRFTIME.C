/****************************************************************************/
/*  strftime v6.10                                                          */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#include <time.h>
#include <string.h>

extern int  sprintf(char *_string, const char *_format, ...);

static const char *const fday[] = { "Sunday","Monday","Tuesday","Wednesday", 
		                    "Thursday","Friday","Saturday" };
static const char *const fmon[] = { "January","February","March","April","May","June",
		                    "July","August","September","October","November",
                                    "December" };
			

size_t strftime(char            *out,
	        size_t           maxsize, 
	        const char      *format,
	        const struct tm *time)
{
    struct tm temp  = *time; 
    int       count = 0;
    char      buf[30];

    mktime(&temp);     /* MAKE SURE THIS IS A LEGITIMATE TIME */

    for (;;)
    {
          while ((count < maxsize) && *format && (*format != '%'))
	  {
	      count++;
	      *out++ = *format++;
	  }

	  if (count >= maxsize) return 0;
	  if (*format == '\0')  { *out = 0; return count; }

	  switch (*++format)
	  {
               case '%' : strcpy(buf, "%");                            break;
	       case 'z' : strcpy(buf, _tz.dstname);                    break;
	       case 'Z' : strcpy(buf, _tz.tzname);                     break;

	       case 'A' : strcpy(buf, fday[temp.tm_wday]);             break;
	       case 'a' : strcpy(buf, fday[temp.tm_wday]); buf[3] = 0; break;
	       case 'B' : strcpy(buf, fmon[temp.tm_mon]);              break;
	       case 'b' : strcpy(buf, fmon[temp.tm_mon]);  buf[3] = 0; break;
	       case 'c' : strcpy(buf, asctime(&temp));                 break; 

	       case 'I' : sprintf(buf, "%02d", temp.tm_hour % 12);     break;
	       case 'H' : sprintf(buf, "%02d", temp.tm_hour);          break;
	       case 'M' : sprintf(buf, "%02d", temp.tm_min);           break;
	       case 'S' : sprintf(buf, "%02d", temp.tm_sec);           break;
	       case 'j' : sprintf(buf, "%03d", temp.tm_yday + 1);      break;
	       case 'd' : sprintf(buf, "%02d", temp.tm_mday);          break;
	       case 'w' : sprintf(buf, "%1d",  temp.tm_wday);          break;
	       case 'm' : sprintf(buf, "%02d", temp.tm_mon + 1);       break;
	       case 'y' : sprintf(buf, "%02d", temp.tm_year);          break;
	       case 'Y' : sprintf(buf, "%4d", 1900 + temp.tm_year);    break;

	       case 'p' : strcpy(buf, temp.tm_hour >= 12 ? "PM":"AM"); break;

	       case 'W' : sprintf(buf, "%2d", temp.tm_yday / 7
                              + (temp.tm_mday % 7 > temp.tm_wday) 
                              + ( (temp.tm_wday==0) && ((temp.tm_mday % 7)==0) 
                              ? 0: -1) ); break;
	       case 'U' : sprintf(buf, "%2d", temp.tm_yday / 7
                              + (temp.tm_mday % 7 > temp.tm_wday));    break;

	       case 'x' : sprintf(buf, "%3s %d, %d", fmon[temp.tm_mon], 
				temp.tm_mday, temp.tm_year + 1900);    break;
	       case 'X' : sprintf(buf, "%02d:%02d:%02d", temp.tm_hour, 
					   temp.tm_min, temp.tm_sec);  break;
	  }

          /*-------------------------------------------------------------*/
          /* IF THIS STRING WILL FIT IN BUFFER, APPEND IT.               */
          /*-------------------------------------------------------------*/
	  if ((count += strlen(buf)) > maxsize) return 0;
	  strcpy(out, buf);
	  out += strlen(buf);
	  format++;
    }
}
