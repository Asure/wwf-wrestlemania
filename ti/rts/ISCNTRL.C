/****************************************************************************/
/*  iscntrl v6.10                                                           */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#undef _INLINE
#include <ctype.h> 

int iscntrl(int c)
{
    return(_iscntrl(c));
}

