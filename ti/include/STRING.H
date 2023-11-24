/*************************************************************************/
/* string.h  v6.10                                                       */
/* Copyright (c) 1991 Texas Instruments Incorporated                     */
/*************************************************************************/
#ifndef _STRING
#define _STRING
 
#ifndef NULL
#define NULL 0
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#if _INLINE 
#define __INLINE static inline
#else
#define __INLINE
#endif

__INLINE size_t  strlen(const char *_string);
__INLINE char   *strcpy(char *_dest, const char *_src);
__INLINE char   *strncpy(char *_to, const char *_from, size_t _n);
__INLINE char   *strcat(char *_string1, const char *_string2);
__INLINE char   *strncat(char *_to, const char *_from, size_t _n);
__INLINE char   *strchr(const char *_string, int _c);
__INLINE char   *strrchr(const char *_string, int _c);
__INLINE int     strcmp(const char *_string1, const char *_string2);
__INLINE int     strncmp(const char *_string1, const char *_string2, size_t _n);
        
         int     strcoll(const char *_string1, const char *_string2);
         size_t  strxfrm(char *_to, const char *_from, size_t _n);
         char   *strpbrk(const char *_string, const char *_chs);
         size_t  strspn(const char *_string, const char *_chs);
         size_t  strcspn(const char *_string, const char *_chs);
         char   *strstr(const char *_string1, const char *_string2);
         char   *strtok(char *_str1, const char *_str2);
         char   *strerror(int _errno);
        
         void   *memmove(void *_s1, const void *_s2, size_t _n);
__INLINE void   *memcpy(void *_s1, const void *_s2, size_t _n);
__INLINE int     memcmp(const void *_cs, const void *_ct, size_t _n);
__INLINE void   *memchr(const void *_cs, int _c, size_t _n);
__INLINE void   *memset(void *_mem, int _ch, size_t _n);

#if _INLINE

/****************************************************************************/
/*  strlen V6.10                                                            */
/****************************************************************************/
static inline size_t strlen(const char *string)
{
   size_t n = -1;

   do n++; while (*string++);
   return n;
}

/****************************************************************************/
/*  strcpy V6.10                                                            */
/****************************************************************************/
static inline char *strcpy(char *s, const char *from)
{
   char *to;
   char *result = to = s;

   while (*to++ = *from++);
   return result;
}

/****************************************************************************/
/*  strncpy v6.10                                                           */
/****************************************************************************/
static inline char *strncpy(char *dest, const char *src, size_t n)
{
     register char *result = dest;

     if (n == 0) return result; 
 
     while ((*dest++ = *src++) && --n != 0);      /* COPY STRING         */

     src = 0;
     if (n) do *dest++ = (char)src; while (--n);  /* TERMINATION PADDING */

     return result;
}

/****************************************************************************/
/*  strcat V6.10                                                            */
/****************************************************************************/
static inline char *strcat(char *string1, const char *string2)
{
   char *result = string1;

   while (*string1++);			     /* FIND END OF STRING   */
   string1--;				     /* BACK UP OVER NULL    */
   while (*string1++ = *string2++);	     /* APPEND SECOND STRING */
   return result;
}

/****************************************************************************/
/*  strncat v6.10                                                           */
/****************************************************************************/
static inline char *strncat(char *dest, const char *src, size_t n)
{
     char *r1 = dest - 1;

     if (n == 0) return dest;
     while (*++r1);                                  /* FIND END OF STRING   */
     while ((*r1++ = *src++) && --n);                /* APPEND SECOND STRING */
     *r1 = 0;
     return dest;
}

/****************************************************************************/
/*  strchr V6.10                                                            */
/****************************************************************************/
static inline char *strchr(const char *string, int c)
{
   char ch = c;
   char tch;

   for (;;)
     if      ( (tch = *string++) == ch ) return (char*)(string-1);
     else if ( tch == 0 )                return (char*)0;
}

/****************************************************************************/
/*  strrchr V6.10                                                           */
/****************************************************************************/
static inline char *strrchr(const char *string, int c)
{
   char tch, ch = c;
   char *result = (char *)0 + 1;

   for (;;)
   {
      if ((tch = *string++) == ch) result = (char*)string;
      if (tch == 0) break;
   }

   return result - 1;
}

/****************************************************************************/
/*  strcmp V6.10                                                            */
/****************************************************************************/
static inline int strcmp(const char *string1, const char *string2)
{
   char cp1;
   char cp2;

   while (((cp1 = *string1++) == (cp2 = *string2++)) && cp1);
   return cp1 - cp2;
}

/****************************************************************************/
/*  strncmp v6.10                                                           */
/****************************************************************************/
static inline int strncmp(const char *string1, const char *string2, size_t n)
{
     const char *r1 = string1;
     const char *r2 = string2;
     char  cp;
     int  result;

     if (n == 0) return 0; 
     do 
        if (result = *r1++ - (cp = *r2++)) return result;
     while (cp != 0 && --n);

     return 0;
}

/****************************************************************************/
/*  memcpy V6.10							    */
/****************************************************************************/
typedef enum { a, b = 0xFFFFFF } _MEMCPY_ENUM_;    /* 24 bit enumeration */

static inline void *memcpy(void *s, const void *ct, size_t n)
{
   size_t length;
   int *from = ct, *to = s;

   if ((length = (n / 4)) > 0 )
        do *to++ = *from++; while (--length != 0);

   switch(n % 4)
   {
      case 1 : *(char  *)to         = *(char  *)from;          break;
      case 2 : *(short *)to         = *(short *)from;          break;
      case 3 : *(_MEMCPY_ENUM_ *)to = *(_MEMCPY_ENUM_  *)from; break;
   }

   return s;
}

/****************************************************************************/
/*  memcmp V6.10							    */
/****************************************************************************/
static inline int memcmp(const void *cs, const void *ct, size_t n)
{
   const unsigned char *mem1 = cs;
   const unsigned char *mem2 = ct;
   int                 cp;
   size_t              length;

   if ( (length=n) == 0 ) return 0;

   while ( ((cp = *mem1++) == *mem2++) && (--length != 0) );
   cp -= *--mem2;
   return cp;
}

/****************************************************************************/
/*  memchr V6.10                                                            */
/****************************************************************************/
static inline void *memchr(const void *cs, int c, size_t n)
{
   size_t length;

   if ( (length=n) > 0 )
   {
      const unsigned char *mem = cs;   
      unsigned char       ch   = c;

      do if ( *mem++ == ch ) return mem - 1;
      while (--length != 0);
   }
   
   return NULL;
}

/****************************************************************************/
/*  memset V6.10                                                            */
/****************************************************************************/
static inline void *memset(void *s, int c, size_t n)
{
   size_t length;

   if ( (length=n) > 0 )
   {
      char          *mem = s;
      unsigned char ch   = c;

      do *mem++ = ch; while (--length != 0);
   }

   return s;
}

#endif

#undef __INLINE

#endif

