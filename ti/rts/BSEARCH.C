/****************************************************************************/
/*  bsearch v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/

/****************************************************************************/
/*  NOTE !!!!! - This function only works on arrays whose elements are      */
/*               a multiple of 8 bits long, since "size" is in bytes.       */
/*               If an "unaligned" array is searched with this function,    */
/*               the results are, at best, unpredictable.                   */
/****************************************************************************/
#include "stdlib.h"

void *bsearch(register const void *key,     /* ITEM TO SEARCH FOR           */
              register const void *base,    /* POINTER TO ARRAY OF ELEMENTS */
              size_t nmemb,                 /* NUMBER OF ELEMENTS TO SORT   */
              size_t size,                  /* SIZE IN BYTES OF EACH ITEM   */
              int (*compar)(const void *,const void *)) /* COMPARE FUNCTION */

{
   register int i       = 0;             /* left scan index  */
   register int j       = nmemb - 1;     /* right scan index */

   while( i <= j )
   {
      register int pivot = (j + i) / 2;            
      int result = (*compar) (key, (char *)base + (pivot * size));
      if (result == 0) return((char *)base + (pivot * size));
      if (result < 0) j = pivot - 1;
		 else i = pivot + 1;
   }

   return ((void *)0);   /* IF WE GET TO HERE, WE FAILED */
}


