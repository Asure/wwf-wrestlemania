/****************************************************************************/
/*  atol v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <stdlib.h>

long atol(register const char *st)
{
    return atoi(st);
}
