/********************************************************************/
/* math.h   v6.10                                                   */
/* Copyright (c) 1991 Texas Instruments Incorporated                */
/********************************************************************/
#ifndef _MATH
#define _MATH

#ifdef _TMS340_IEEE
#define HUGE_VAL  1.7976931348623124e+308   /* SAME AS DBL_MAX */
#else
#define HUGE_VAL  8.9884656743115620e+307   /* SAME AS DBL_MAX */
#endif

#ifndef EDOM
#define EDOM   1
#endif

#ifndef ERANGE
#define ERANGE 2
#endif

#if _INLINE
#define __INLINE static inline
#else
#define __INLINE
#endif

/***************************************************************/
/* FUNCTION DEFINITIONS.                                       */
/***************************************************************/
         double asin(double _x);
         double acos(double _x);
         double atan(double _x);
         double atan2(double _y, double _x);
__INLINE double ceil(double _x);
         double cos(double _x);
         double cosh(double _x);
         double exp(double _x);
         double fabs(double _x); 
__INLINE double floor(double _x);
__INLINE double fmod(double _x, double _y);
         double frexp(double _x, int *_exp);
         double ldexp(double _x, int _exp);
         double log(double _x);
         double log10(double _x);
         double modf(double _x, double *_y); 
         double pow(double _x, double _y);
         double sin(double _x);
         double sinh(double _x);
         double tan(double _x);
         double tanh(double _x);

/***************************************************************/
/* TWO VERSIONS OF sqrt ARE PROVIDED -                         */
/*     sqrt - Checks for negative numbers, sets errno = EDOM.  */
/*    _sqrt - Error checking not performed, this version is    */
/*            generally faster (inlined with 34082 support).   */
/*                                                             */
/* By default, calls to "sqrt" are converted into calls to     */
/* "_sqrt" (see #define below).  To override this, #define     */
/* the flag _SLOW_SQRT.                                        */
/*                                                             */
/***************************************************************/
         double sqrt(double _x);   /* sqrt WITH RANGE CHECKING */
         double _sqrt(double _x);  /* sqrt WITHOUT CHECKING    */

#ifndef _SLOW_SQRT
#define sqrt _sqrt         /* BY DEFAULT, USE THE FAST VERSION */
#endif


#if _INLINE

/****************************************************************************/
/*  floor  v6.10                                                            */
/****************************************************************************/
static inline double floor(double x) 
{
     double y; 
     return (modf(x, &y) < 0 ? y - 1 : y);
}

/****************************************************************************/
/*  ceil   v6.10                                                            */
/****************************************************************************/
static inline double ceil(double x)
{
     double y; 
     return (modf(x, &y) > 0 ? y + 1 : y);
}


/****************************************************************************/
/*  fmod   v6.10                                                            */
/****************************************************************************/
static inline double fmod(double x, double y)
{
     double d = fabs(x); 
     if (d - fabs(y) == d) return (0);
     modf(x/y, &d);  
     return (x - d * y);
}

#endif

#undef __INLINE

#endif 
