****************************************************************************
*  s$check  v6.10                                                          *
*  Copyright (c) 1991 Texas Instruments Incorporated                       *
****************************************************************************

****************************************************************************
*
*   s$check : this function may be called at the beginning of a function
*             after the registers are saved and local frame allocated to
*             check for a stack overflow.
*
****************************************************************************

STK     .set     A14                        ; PROGRAM STACK POINTER
        .globl   s$check

s$check:
        CMP      STK,SP                     ; COMPARE BOTH STACK POINTERS
        JRHI     okay
        TRAP     29                         ; OR SOME SUCH ERROR PANIC
okay:   RETS                                ; return to caller

        .end
