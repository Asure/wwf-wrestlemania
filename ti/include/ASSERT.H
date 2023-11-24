/********************************************************************/
/* assert.h v6.10                                                   */
/* Copyright (c) 1991 Texas Instruments Incorporated                */
/********************************************************************/
#ifndef _ASSERT
#define _ASSERT

#ifdef NDEBUG
#define assert(_ignore) ((void)0)
#else
#define assert(_expr) ((!(_expr)) ? \
          ( printf("Assertion failed, (" #_expr "), file %s, line %d\n", \
		    __FILE__, __LINE__),                            \
		    abort(), (void)0) : (void)0)
#endif
#endif

