/****************************************************************************/
/*  exit v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include <stdlib.h>

#define MAX_FUN   32
static int    at_exit_count = 0;
static void (*at_exit_fun[MAX_FUN])();

void exit(int status)        
{
    register int i = at_exit_count;
    /*********************************************************************/
    /* HANDLE FUNCTIONS REGISTERED THROUGH atexit().                     */
    /*********************************************************************/
    while (i) (*at_exit_fun[--i])(); 

    for (;;);   /* CURRENTLY, THIS SPINS FOREVER */
}

/****************************************************************************/
/* atexit - attempt to register a function for calling at program end       */
/****************************************************************************/
int atexit(void (*fun)())

{
   if (at_exit_count >= 32) return 1;
   at_exit_fun[at_exit_count++] = fun;
   return 0;
}

/****************************************************************************/
/* abort - currently the same as exit.                                      */
/****************************************************************************/
void abort(void)
{
    exit(EXIT_FAILURE); 
}

