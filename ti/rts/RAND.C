/****************************************************************************/
/*  rand.c v6.10							    */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <stdlib.h>

/***************************************************************/
/* THIS IS AN IMPLEMENTATION WHICH IS INTENDED TO BE PORTABLE, */
/* AS PER THE ANSI STANDARD C SPECIFICATION                    */
/***************************************************************/
static unsigned long next = 1;

int rand(void)
{
     next = next * 1103515245 + 12345;
     return (unsigned int)(next/65536) % (RAND_MAX + 1);
}

void srand(unsigned seed)
{
     next = seed;
}

