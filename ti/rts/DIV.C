/****************************************************************************/
/*  div ldiv    v6.10                                                       */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
#include "stdlib.h"

div_t div(register int numer, register int denom)
{
    div_t local;
    local.quot = numer / denom;
    local.rem  = numer % denom;
    return (local);
}

ldiv_t ldiv(register long numer, register long denom)
{
    ldiv_t local;
    local.quot = numer / denom;
    local.rem  = numer % denom;
    return (local);
}

