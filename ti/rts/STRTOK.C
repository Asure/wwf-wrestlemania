/****************************************************************************/
/*  strtok v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <string.h>

char *strtok(char *str1, const char *str2)
{
     static char *last_end;
     char        *start; 

     if (str1) last_end = str1;

     last_end += strspn(last_end, str2);
     if (*last_end == '\0') return (NULL);

     start = last_end;
     last_end += strcspn(last_end, str2);

     if (*last_end != '\0') *last_end++ = '\0'; 

     return start;
}

