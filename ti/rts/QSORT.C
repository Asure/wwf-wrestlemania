/****************************************************************************/
/*  qsort v6.10                                                             */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <stdlib.h>

static void swap_item();

void qsort(void *base, size_t nmemb, size_t size, int (*compar)())

{
   register char *basep  = base;         /* POINTER TO ARRAY OF ELEMENTS */
   register int   i      = 0;             /* left scan index  */
   register int   j      = nmemb - 1;     /* right scan index */
   register int   pivot  = (nmemb / 2);
   register char *pivp   = basep + (pivot * size);

   while( i < j )
   {
      while( (*compar) (basep + (i * size), pivp) < 0 ) ++i;
      while( (*compar) (basep + (j * size), pivp) > 0 ) --j;
      if( i < j )
      {
	 swap_item(basep + (i * size), basep + (j * size), size);
	 if     ( pivot == i ) { pivot = j; pivp = basep + (pivot * size); }
	 else if( pivot == j ) { pivot = i; pivp = basep + (pivot * size); } 
	 ++i; --j;
      }
      else if ( i == j ) { ++i; --j;  break; }
   }

   if( j > 0)       qsort(basep, j + 1, size, compar);
   if( i < nmemb-1) qsort(basep + (i * size), nmemb - i, size, compar);
}


static void swap_item(register char *src, 
                      register char *dest, 
                      register size_t size)
{
    while (size--)
    {
        register int temp = *src;       
        *src++            = *dest;
        *dest++           = temp;
    }
}

