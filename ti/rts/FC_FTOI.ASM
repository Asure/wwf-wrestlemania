*******************************************************************************
*  FD$FTOI     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*                                                                             
*  This module contains source to the conversion routines for single preci-   
*  sion IEEE floating point to integer or unsigned integer.  The input number 
*  is popped off the stack and the integer is returned in A8.                 
*                                                                             
*******************************************************************************

         .globl   FD$FTOI          ; CONVERT TO SIGNED INTEGER

FD$FTOI:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMULATE

*******************************************************************************
*  34082
*******************************************************************************
         MOVE     CCONFIG,A8
         MOVE     A8,-*SP,1
         MOVI     29h,A8
         MOVE     A8,CCONFIG

         MOVF     *-A14,RA0        ; POP FLOAT OFF STACK
         CVFI     RA0,RA0          ; DO CONVERSION
         MOVE     RA0,A8           ; PUT INT RESULT IN A8

         MOVE     *SP+,CCONFIG
         RETS
	 .endif
         
*******************************************************************************
*  IEEE/GSP EMULATION 
*******************************************************************************
         .globl   _fp_error

BIGPOS   .set     07FFFFFFh

EMULATE:
         MMTM     SP,A0,A3           ; SAVE REGISTERS LISTED
         MOVE     -*A14,A0,1         ; POP FLOATING POINT NUMBER OFF THE STACK
         MOVE     A0,A8              ; SAVE OFF COPY FOR MANTISSA

********************************************************************************
*  ISOLATE SIGN AND EXPONENT
********************************************************************************
         SLL      1,A0
         SUBB     A3,A3              ; A3 FILLED WITH SIGN BIT
NEG_NUMBER:
         SRL      24,A0              ; A0 CONTAINS EXPONENT

********************************************************************************
*  ISOLATE MANTISSA, NORMALIZE IN A FIELD OF 31 BITS                           *
********************************************************************************
         SLL      9,A8
	 .if      .TMS340_IEEE
         SRL      2,A8               ; A8 CONTAINS NORMALIZED IEEE MANTISSA
         ORI      040000000H,A8      ; TACK ON IMPLICIT ONE TO MANTISSA
         ADDK     1,A0               ; AND ADJUST EXPONENT
	 .else
         SRL      1,A8               ; A8 CONTAINS NORMALIZED GSP MANTISSA
	 .endif

********************************************************************************
* CHECK SPECIAL CASES OF EXPONENT
********************************************************************************
         SUBI     127,A0             ; ADJUST EXPONENT TO ACTUAL VALUE
         JRLE     ZERO
         SUBK     31,A0              ; IS EXPONENT = 31
         JRGT     INFIN              ; IF BIGGER THEN ANSWER IS INFINITY
         SRL      A0,A8              ; SHIFT OFF THE OVER SHIFT

********************************************************************************
*  HANDLE THE SIGN BIT AND RETURN.
********************************************************************************
SGNFIX:
         MOVE     A3,A3
         JRZ      DONE
         NEG      A8

DONE:
         MMFM     SP,A0,A3
         MOVE     A8,A8              ; SET STATUS
         RETS

********************************************************************************
* HANDLE SPECIAL CASES, ZERO AND INFINITY    
********************************************************************************
ZERO:
         MMFM     SP,A0,A3
         SUB      A8,A8              ; RESULT IS ZERO, MAKE SURE STATUS IS SET
         RETS

INFIN:
         MOVK     3,A0               ; ERROR CODE IS 3
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error          ; CALL THE ERROR ROUTINE

         XORI     BIGPOS,A3          ; RETURN POSITIVE OR NEGATIVE "BIGPOS"
         MOVE     A3,A8
         MMFM     SP,A0,A3
         RETS

         .end
