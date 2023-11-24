*******************************************************************************
*  FD$DTOI     v6.10    
*  Copyright (c) 1991  Texas Instruments Incorporated
*                                                                         
*  This module contains source to the conversion routine for double     
*  precision IEEE floating point to signed integer.  The input number 
*  is popped off the stack and the integer is returned in A8.
*                                                                    
*******************************************************************************

         .globl   FD$DTOI          ; CONVERT TO SIGNED INTEGER

FD$DTOI:
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

         MOVE     A14,A8           ; POP OPERAND FROM STACK
         SUBI     64,A8
         MOVD     *A8+,RA0
         SUBI     64,A14

         CVDI     RA0,RA0          ; CONVERT
         MOVE     RA0,A8           ; PUT RESULT IN A8

         MOVE     *SP+,CCONFIG
         RETS
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

BIGPOS   .set     07FFFFFFFh
STK      .set     A14

*************************************************************************
*
* ENTRY POINT FOR CONVERSION TO SIGNED INTEGER
*                               ------
*************************************************************************
EMULATE:
         MMTM     SP,A0,A3

	 .if      .TMS340_IEEE == 0
         MOVE     *-STK,A0,1         ; PUT MSB GSP DOUBLE PRECISION NUMBER IN A0
	 .endif

         MOVE     *-STK,A8,1         ; PUT 32 BITS OF MANTISSA IN A8
         SRL      20,A8

	 .if      .TMS340_IEEE
         MOVE     *-STK,A0,1         ; PUT MSB IEEE DOUBLE PRECISION NUMBER IN A0
	 .endif

         MOVE     A0,A3
         SLL      12,A3
         OR       A3,A8

*************************************************************************
* ISOLATE EXPONENT IN A0 AND SIGN BIT IN A3, NORMALIZE MANTISSA
*************************************************************************
         SLL      1,A0
         SUBB     A3,A3
NEG_NUMBER:                          ; ENTRY POINT FROM UNSIGNED CONVERT
         SRL      21,A0              ; ISOLATE THE EXPONENT IN A0
	 .if      .TMS340_IEEE
         SRL      2,A8               ; NORMALIZE IEEE MANTISSA IN FIELD OF 31 BITS
         ORI      040000000H,A8      ; TACK IMPLICIT ONE ON MANTISSA
         ADDK     1,A0               ; AND ADJUST EXPONENT
	 .else
         SRL      1,A8               ; NORMALIZE GSP MANTISSA IN FIELD OF 31 BITS
	 .endif

*************************************************************************
* NORMALIZE EXPONENT AND CHECK FOR BOUNDS ERRORS AND SPECIAL CASES
*************************************************************************
         SUBI     1023,A0            ; ADJUST EXPONENT TO ACTUAL VALUE
         JRLE     ZERO
         SUBK     31,A0              ; SUBTRACT SHIFT VALUE (ASSUMED 31)
         JRGT     INFIN              ; IF > 31 THEN ANSWER IS INFINITY
         SRL      A0,A8              ; SHIFT OFF THE OVER SHIFT

*************************************************************************
* MAKE RESULT THE CORRECT SIGN
*************************************************************************
SGNFIX:
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
INFIN:
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

         .end
