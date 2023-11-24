/*************************************************************************/
/* stdlib.h  v6.10                                                       */
/* Copyright (c) 1991 Texas Instruments Incorporated                     */
/*************************************************************************/
#ifndef _STDLIB
#define _STDLIB

typedef struct { int quot, rem; } div_t, ldiv_t;

#define MB_CUR_MAX    1

#ifndef NULL
#define NULL          0
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned int size_t;
#endif

#ifndef _WCHAR_T
#define _WCHAR_T
typedef char wchar_t;
#endif

#define EXIT_FAILURE  0
#define EXIT_SUCCESS  1

#define RAND_MAX 32767

#if _INLINE
#define __INLINE static inline
#else
#define __INLINE
#endif

/*---------------------------------------------------------------*/
/* NOTE - Normally, abs, labs, and fabs are expanded inline, so  */
/*        no formal definition is really required. However, ANSI */
/*        requires that they exist as separate functions.        */
/*---------------------------------------------------------------*/
         int    abs(int _val); 
         long   labs(long _val);
        
         int    atoi(const char *_st);
__INLINE long   atol(const char *_st);
__INLINE double atof(const char *_st);

         long   strtol(const char *_st, char **_endptr, int _base);
         unsigned long strtoul(const char *_st, char **_endptr, int _base);
         double strtod(const char *_st, char **_endptr);

         int    rand(void);
         void   srand(unsigned _seed);

         void  *calloc(size_t _num, size_t _size);
         void  *malloc(size_t _size);
         void  *realloc(void *_ptr, size_t _size);
         void   free(void *_ptr);

         void   abort(void); 
         int    atexit(void (*_func)(void));
         void  *bsearch(const void *_key, const void *_base, size_t _nmemb, 
	               size_t _size, int (*compar)(const void *,const void *)); 
         void   qsort(void *_base, size_t _nmemb, size_t _size, int (*_compar)());
         void   exit(int _status);

         div_t  div(int _numer, int _denom);
         ldiv_t ldiv(long _numer, long _denom);

         char  *getenv(const char *_string);
	 int    system(const char *_name);

#if _INLINE

/****************************************************************************/
/*  atof v6.10                                                              */
/****************************************************************************/
static inline double atof(const char *_st)
{
    return strtod(_st, (char **)0);
}

/****************************************************************************/
/*  atol v6.10                                                              */
/****************************************************************************/
static inline long atol(register const char *st)
{
    return atoi(st);
}

#endif
#undef __INLINE

#endif
