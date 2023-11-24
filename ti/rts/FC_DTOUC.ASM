*******************************************************************************
*  FD$DTOUC    v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*                                                                             
*  This module contains source to the conversion routines for single preci-   
*  sion IEEE floating point to integer or unsigned integer.  The input number 
*  is passed in RA0, and the result is returned in A8.                        
*                                                                             
*******************************************************************************

         .if      .TMS34082
         .globl   FD$DTOUC         ; CONVERT TO UNSIGNED INTEGER
         .globl   _fp_error

BIGPOS   .set     07FFFFFFh
MSBIT    .set    080000000h
STK      .set     A14


*************************************************************************
*  ENTRY POINT
*************************************************************************
FD$DTOUC:
         MMTM     SP,A0,A3
         MOVD     RA0,A0,A8          ; PUT EXPONENT IN A0, EXTENSION IN A8
         SRL      20,A8              ; WE CAN THROW AWAY MOST OF MANTISSA
         MOVE     A0,A3
         SLL      12,A3
         OR       A3,A8              ; TOP 32 BITS OF MANTISSA IN A8

*************************************************************************
* ISOLATE EXPONENT IN A0, SIGN BIT IN A3.
* IF NEGATIVE NUMBER, HANDLE LIKE A SIGNED NEGATIVE NUMBER
*************************************************************************
         SLL      1,A0
         SUBB     A3,A3
         JRNZ     NEG_NUMBER
         SRL      21,A0              ; ISOLATE THE EXPONENT IN A0
         SRL      1,A8               ; TACK IMPLICIT ONE TO FRONT OF MANTISSA
         ORI      080000000H,A8      ;
         ADDK     1,A0               ; AND ADJUST EXPONENT

*************************************************************************
* NORMALIZE EXPONENT AND CHECK FOR BOUNDS ERRORS AND SPECIAL CASES
*************************************************************************
         SUBI     1023,A0            ; ADJUST EXPONENT TO ACTUAL VALUE
         JRLE     ZERO
         SUBK     32,A0              ; IS EXPONENT = 32
         JRGT     INFIN2             ; IF BIGGER THEN ANSWER IS INFINITY
         SRL      A0,A8              ; SHIFT OFF THE OVER SHIFT

UDONE:
         MMFM     SP,A0,A3
         MOVE     A8,A8              ; SET STATUS FLAGS ACCORDING TO WHAT IS
         RETS                        ; IN A8

*************************************************************************
* HANDLE NEGATIVE NUMBERS
*************************************************************************
NEG_NUMBER:                          ; ENTRY POINT FROM UNSIGNED CONVERT
         SRL      21,A0              ; ISOLATE THE EXPONENT IN A0
         SRL      2,A8               ; NORMALIZE IEEE MANTISSA IN FIELD OF 31 BITS
         ORI      040000000H,A8      ; TACK IMPLICIT ONE ON MANTISSA
         ADDK     1,A0               ; AND ADJUST EXPONENT

*************************************************************************
* NORMALIZE EXPONENT AND CHECK FOR BOUNDS ERRORS AND SPECIAL CASES
*************************************************************************
         SUBI     1023,A0            ; ADJUST EXPONENT TO ACTUAL VALUE
         JRLE     ZERO
         SUBK     31,A0              ; SUBTRACT SHIFT VALUE (ASSUMED 31)
         JRGT     INFIN2             ; IF > 31 THEN ANSWER IS INFINITY
         SRL      A0,A8              ; SHIFT OFF THE OVER SHIFT

*************************************************************************
* MAKE RESULT THE CORRECT SIGN
*************************************************************************
         MOVE     A3,A3              ; CMPI 0,A3
         JRZ      DONE
         NEG      A8

*************************************************************************
* NORMAL RETURN - RESTORE REGISTERS AND RETURN TO CALLER
*************************************************************************
DONE:
         MMFM     SP,A0,A3
         MOVE     A8,A8              ; SET STATUS FLAGS ACCORDING TO WHAT IS
         RETS                        ; IN A8

*************************************************************************
* HANDLE SPECIAL CASE OF ZERO 
*************************************************************************
ZERO:
         MMFM     SP,A0,A3
         SUB      A8,A8              ; RESULT IS ZERO, MAKE SURE STATUS IS SET
         RETS

*************************************************************************
* HANDLE INFINITY - RETURN LARGEST POS OR NEGATIVE INTEGER, CALL ERROR
*************************************************************************
INFIN2:
         MOVK     1,A0               ; ERROR CODE IS 1
	 .if      .TMS340_MEMPARM
         MOVE     STK,-*SP,1
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error          ; CALL THE ERROR ROUTINE

         XORI     BIGPOS,A3
         MOVE     A3,A8              ; IS NEG INFINITY OR + INFINITY (CMPI 0,A3)
         MMFM     SP,A0,A3
         RETS

         .endif
         .end
