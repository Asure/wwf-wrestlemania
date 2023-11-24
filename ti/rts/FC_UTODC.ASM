*******************************************************************************
*  FD$UTODC   v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*                              
*  This module converts signed and unsigned integers to double precision
*  IEEE floating point numbers.  The input is passed in register A8, and the
*  result is returned in RA0     
*
*******************************************************************************

	 .if	  .TMS34082
         .globl   FD$UTODC          ; CONVERT UNSIGNED NUMBER

	 .even	  32
FDMSB:   .double  4294967296.0 

FD$UTODC:
         CVID     A8,RA0,RA0        ; DO SIGNED CONVERT
	 MOVE     A8,A8
         JRNN     SKIP              ; UNSIGNED INT < 2**31

         MOVI     FDMSB,A8          ; PUT 2**32 IN '82 REG 
         MOVD     *A8+,RB0 
         ADDD     RA0,RB0,RA0       ; ADD 2**32 TO NEG NUMBER
SKIP:
         RETS
	 .endif
	 .end
    
