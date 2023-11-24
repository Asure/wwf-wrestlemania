/****************************************************************************/
/*  frexp  v6.10                                                            */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/
double frexp(double value, int *exp)
{
     int *ptr;

     if (value == 0) 
        { *exp = 0; return (value); }

     ptr = (int *)&value;
#ifdef _TMS340_IEEE
     *exp = ((ptr[0] >> 20) & 0x000007FF) - 0x000003FE;
     ptr[0] = (ptr[0] & 0x800FFFFF) + 0x3FE00000;
#else
     *exp = ((ptr[1] >> 20) & 0x000007FF) - 0x000003FF;
     ptr[1] = (ptr[1] & 0x800FFFFF) + 0x3FF00000;
#endif
     return *(double *)ptr; /* AVOID ALIASING PROBLEMS */
}
