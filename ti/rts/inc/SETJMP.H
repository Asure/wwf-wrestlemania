/****************************************************************************/
/*  setjmp.h v6.10                                                          */
/*  Copyright (c) 1991 Texas Instruments Incorporated                       */
/****************************************************************************/
#ifndef _SETJMP
#define _SETJMP

#if _TMS34082
typedef long jmp_buf[16 + 18];
#else
typedef long jmp_buf[16];
#endif

int  _setjmp(jmp_buf _env); 
void longjmp(jmp_buf _env, int _val);

#define setjmp(_x) _setjmp(_x)

#endif

