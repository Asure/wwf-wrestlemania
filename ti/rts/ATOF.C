/****************************************************************************/
/*  atof v6.10                                                              */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include "stdlib.h"

double atof(const char *st)
{
    return strtod(st, (char **)0);
}
