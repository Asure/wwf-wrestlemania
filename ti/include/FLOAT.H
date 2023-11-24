/********************************************************************/
/* float.h  v6.10                                                   */
/* Copyright (c) 1991 Texas Instruments Incorporated                */
/*    KEY:  FLT_     - APPLIES TO TYPE FLOAT                        */
/*          DBL_     - APPLIES TO TYPE DOUBLE                       */
/*          LDBL_    - APPLIES TO TYPE LONG DOUBLE                  */
/********************************************************************/
#ifndef _FLOAT
#define _FLOAT

#define FLT_RADIX                         2   /* RADIX OF EXPONENT         */
#define FLT_ROUNDS                        1   /* TRUE IF ADDITION ROUNDS   */

#ifdef _TMS340_IEEE

#define FLT_DIG                           7   /* DECIMAL PRECISION         */
#define FLT_MANT_DIG                     24   /* BITS IN MANTISSA          */
#define FLT_MIN_EXP                    -126   /* SMALLEST EXPONENT         */
#define FLT_MAX_EXP                     127   /* LARGEST EXPONENT          */
#define FLT_EPSILON          1.1920929E-07F   /* SMALLEST X WHERE 1+X != 1 */
#define FLT_MIN              1.1754944E-38F   /* SMALLEST POSITIVE VALUE   */
#define FLT_MAX              3.4028237E+38F   /* LARGEST POSITIVE VALUE    */
#define FLT_MIN_10_EXP                  -38   /* MIN POWER OF 10           */
#define FLT_MAX_10_EXP                   38   /* MAX POWER OF 10           */

#define DBL_MANT_DIG                     53   /* BITS IN MANTISSA          */
#define DBL_DIG                          15   /* DECIMAL PRECISION         */
#define DBL_MIN_EXP                   -1022   /* SMALLEST EXPONENT         */
#define DBL_MAX_EXP                    1023   /* LARGEST EXPONENT          */
#define DBL_EPSILON  2.2204460492503131E-16   /* SMALLEST X WHERE 1+X != 1 */
#define DBL_MIN     2.2253721744038137e-308   /* SMALLEST POSITIVE VALUE   */ 
#define DBL_MAX     1.7976931348623124e+308   /* LARGEST POSITIVE VALUE    */
#define DBL_MIN_10_EXP                 -308   /* MIN POWER OF 10           */
#define DBL_MAX_10_EXP                  308   /* MAX POWER OF 10           */

#define LDBL_MANT_DIG                    53   /* DECIMAL PRECISION         */
#define LDBL_DIG                         15   /* BITS IN MANTISSA          */
#define LDBL_MIN_EXP                  -1022   /* SMALLEST EXPONENT         */
#define LDBL_MAX_EXP                   1023   /* LARGEST EXPONENT          */
#define LDBL_EPSILON 2.2204460492503131E-16   /* SMALLEST X WHERE 1+X != 1 */
#define LDBL_MIN    2.2253721744038137e-308   /* SMALLEST POSITIVE VALUE   */ 
#define LDBL_MAX    1.7976931348623124e+308   /* LARGEST POSITIVE VALUE    */
#define LDBL_MIN_10_EXP                -308   /* MIN POWER OF 10           */
#define LDBL_MAX_10_EXP                 308   /* MAX POWER OF 10           */

#else

#define FLT_DIG                           6   /* DECIMAL PRECISION         */
#define FLT_MANT_DIG                     23   /* BITS IN MANTISSA          */
#define FLT_MIN_EXP                    -126   /* SMALLEST EXPONENT         */
#define FLT_MAX_EXP                     127   /* LARGEST EXPONENT          */
#define FLT_EPSILON          2.3841858E-07F   /* SMALLEST X WHERE 1+X != 1 */
#define FLT_MIN              5.8774720E-39F   /* SMALLEST POSITIVE VALUE   */
#define FLT_MAX              1.7014116E+38F   /* LARGEST POSITIVE VALUE    */
#define FLT_MIN_10_EXP                  -39   /* MIN POWER OF 10           */
#define FLT_MAX_10_EXP                   38   /* MAX POWER OF 10           */

#define DBL_MANT_DIG                     52   /* BITS IN MANTISSA          */
#define DBL_DIG                          15   /* DECIMAL PRECISION         */
#define DBL_MIN_EXP                   -1022   /* SMALLEST EXPONENT         */
#define DBL_MAX_EXP                    1023   /* LARGEST EXPONENT          */
#define DBL_EPSILON  4.4408920985006262E-16   /* SMALLEST X WHERE 1+X != 1 */
#define DBL_MIN     1.1126860872019069e-308   /* SMALLEST POSITIVE VALUE   */ 
#define DBL_MAX     8.9884656743115620e+307   /* LARGEST POSITIVE VALUE    */
#define DBL_MIN_10_EXP                 -308   /* MIN POWER OF 10           */
#define DBL_MAX_10_EXP                  307   /* MAX POWER OF 10           */

#define LDBL_MANT_DIG                    52   /* DECIMAL PRECISION         */
#define LDBL_DIG                         15   /* BITS IN MANTISSA          */
#define LDBL_MIN_EXP                  -1022   /* SMALLEST EXPONENT         */
#define LDBL_MAX_EXP                   1023   /* LARGEST EXPONENT          */
#define LDBL_EPSILON 4.4408920985006262E-16   /* SMALLEST X WHERE 1+X != 1 */
#define LDBL_MIN    1.1126860872019069e-308   /* SMALLEST POSITIVE VALUE   */ 
#define LDBL_MAX    8.9884656743115620e+307   /* LARGEST POSITIVE VALUE    */
#define LDBL_MIN_10_EXP                -308   /* MIN POWER OF 10           */
#define LDBL_MAX_10_EXP                 307   /* MAX POWER OF 10           */
#endif

#endif
