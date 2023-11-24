/********************************************************************/
/* stdarg.h v6.10                                                   */
/* Copyright (c) 1991 Texas Instruments Incorporated                */
/********************************************************************/
#ifndef _STDARG
#define _STDARG

typedef char *va_list;

#define va_start(_ap, _parmN) (_ap = (char *)&_parmN)
#define va_end(_ap)

/********************************************************************/
/* WARNING - va_arg will not work for "float" type, must use double */
/********************************************************************/
#define va_arg( _ap, _type)  ((_ap -= (sizeof(_type) > sizeof(int))  \
				    ?  sizeof(_type) : sizeof(int)), \
				       (*(_type *)(_ap)))
#endif

