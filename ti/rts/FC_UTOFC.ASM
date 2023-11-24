*******************************************************************************
*  FD$UTOFC   v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*                              
*  This module converts signed and unsigned integers to single precision
*  IEEE floating point numbers.  The input is passed in register A8, and the
*  result is returned in coprocessor register RA0
*
*******************************************************************************

         .if	  .TMS34082
         .globl   FD$UTOFC          ; CONVERT UNSIGNED NUMBER

	 .even	  32
FSMSB:   .float   4294967296.0 

FD$UTOFC:
         CVIF     A8,RA0,RA0        ; DO SIGNED CONVERT
	 MOVE     A8,A8
         JRNN     SKIP              ; UNSIGNED INT < 2**31

         MOVI     FSMSB,A8          ; PUT 2**32 IN '82 REG 
         MOVF     *A8+,RB0 
         ADDF     RA0,RB0,RA0       ; ADD 2**32 TO NEG NUMBER
SKIP:
         RETS
	 .endif
	 .end
