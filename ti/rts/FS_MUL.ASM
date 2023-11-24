*******************************************************************************
*  FS$MUL     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function performs single precision floating point multiplication.
*  Two inputs are conssumed from the stack and the result is pushed on the
*  stack.
*
*******************************************************************************

         .globl   FS$MUL

FS$MUL:
         .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_MUL

*******************************************************************************
*  34082
*******************************************************************************
         MOVF     -*A14,RA0      ; POP SECOND OPERAND
         MOVF     -*A14,RB0      ; POP FIRST OPERAND
         MPYF     RA0,RB0,RA0    ; PERFORM MULTIPLY
         MOVF     RA0,*A14+      ; PUSH RESULT ON STACK

         RETS
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

IRNDMSK  .set     00000080h
GRNDMSK  .set     00000080h
MSBBIT   .set     80000000h
INFI     .set     7FF00000h

******************************************************************************
* REGISTER USAGE
*   A0 - Scratch register
*   A2 - Result exponent
*   A6 - Result sign bit
*   A8 - Result mantissa
*   A9 - Scratch register
******************************************************************************

EMU_MUL:
         MMTM     SP,A0,A2,A4,A9

         MOVE     -*A14,A8,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A9,1         ; POP FIRST  NUMBER OFF STACK

******************************************************************************
* IF EITHER OPERAND IS ZERO, RESULT IS ZERO
******************************************************************************
         MOVE     A8,A8
         JRZ      ZERO
         MOVE     A9,A9
         JRZ      ZERO

******************************************************************************
* CALCULATE RESULT SIGN BIT AND FINAL EXPONENT.
* PUT RESULT SIGN IN A4, RESULT EXPONENT IN A2
******************************************************************************
         SLL      1,A8
         SUBB     A4,A4              ; A4 FILLED WITH SIGN BIT OF 2nd NUMBER
         SLL      1,A9
         SUBB     A0,A0              ; A0 FILLED WITH SIGN BIT OF 1st NUMBER
         XOR      A0,A4
         SLL      31,A4              ; BIT 31 OF A4 CONTAINS RESULT SIGN BIT

         MOVE     A8,A0              ; SAVE A8 FOR LATER
         MOVE     A9,A2              ; SAVE A9 FOR LATER
         SRL      24,A0              ; ISOLATE EXPONENTS
         SRL      24,A2

         CMPI     255,A2             ; WAS ONE OF EXPONENTS INFINITY
         JRZ      INFIN9
         CMPI     255,A0
         JRZ      INFIN8

         ADD      A0,A2              ; GET RESULTANT EXPONENT
         SUBI     127,A2             ; GET RID OF EXTRA BIAS

******************************************************************************
* LEFT JUSTIFY MANTISSAS
******************************************************************************
         SLL      8,A8
	 .if      .TMS340_IEEE
         SRL      1,A8               ; PUT IMPLICIT ONE IN MANTISSA
         ORI      MSBBIT,A8
	 .endif

         SLL      8,A9
	 .if      .TMS340_IEEE
         SRL      1,A9               ; PUT IMPLICIT ONE IN MANTISSA
         ORI      MSBBIT,A9
	 .endif

******************************************************************************
* PERFORM THE MULTIPLY
******************************************************************************
MULT:
         MPYU    A9,A8               ; RESULT IN A8
         JRZ     ZERO                ; IF NUMBER IS ZERO, RESULT IS ZERO

******************************************************************************
* NORMALIZE THE NUMBER, IF NECESSARY
******************************************************************************
NORM:
	 .if      .TMS340_IEEE
         ADDK     1,A2               ; CORRECT EXP FOR 2ND IMPLICIT ONE
	 .endif
         BTST     31,A8              ; DO WE NEED TO NORMALIZE
         JRNZ     RNDTST             ; IF NOT GO AHEAD WITH ROUNDING
         SUBK     1,A2               ; ADJUST RESULT EXPONENT
         SLL      1,A8               ; NORMALIZE WITH JUST ONE SHIFT LEFT

******************************************************************************
* IF ROUNDING IS NEEDED, DO IT
******************************************************************************
RNDTST:
	 .if      .TMS340_IEEE
         ADDI     IRNDMSK,A8         ; ADD ROUND VALUE TO MANTISSA
         JRNC     NOVRFL

         ADDK     1,A2               ; ADJUST EXPONENT
         JRUC     EXPCHK 

NOVRFL:
         SLL      1,A8               ; NORMALIZE MANTISSA TO IEEE
	 .else
         ADDI     GRNDMSK,A8         ; ADD ROUND VALUE TO MANTISSA
         JRNC     EXPCHK
	 SRL      1,A8               ; HANDLE OVERFLOW FROM ROUNDING
	 ORI      MSBBIT,A8          ; ADD TOP BIT ONTO MANTISSA
	 ADDK     1,A2               ; INCREMENT EXPONENT
	 .endif
        
******************************************************************************
* HANDLE FINAL MANIPULATION OF EXPONENT
******************************************************************************
EXPCHK:
         MOVE     A2,A2
         JRLT     ERR13              ; JUMP IF UNDERFLOW
         JRZ      ZEROCHK            ; CHECK FOR ZERO
         CMPI     255,A2             ; WAS THERE AN OVERFLOW
         JRGE     ERR6

******************************************************************************
* BUILD THE RESULT AND PUSH ONTO THE STACK
******************************************************************************
FINI:
         SRL      9,A8               ; RIGHT JUSTIFY MANTISSA
         SLL      23,A2              ; JUSTIFY EXPONENT
         OR       A2,A8              ;       AND PUT INTO RESULT
PUSH:
         OR       A4,A8              ; OR IN SIGN BIT
         MOVE     A8,*A14+,1

DONE:
         MMFM     SP,A0,A2,A4,A9
         RETS

***************************************************************************
* HANDLE SPECIAL CASES
***************************************************************************
ZEROCHK:
         MOVE     A8,A8              ; IS EXP AND MANT. = 0
         JRNZ     ERR13
         JRUC     FINI

ZERO:
         CLR      A8
         MOVE     A8,*A14+,1
         MMFM     SP,A0,A2,A4,A9
         RETS

INFIN8:
         MOVE     A2,A0
INFIN9:
         MOVE     A0,A0            ; (INFIN * 0) ?
         JRZ      ERR11            ; YES, INDICATE ERROR
         MOVI     INFI,A8
         JRUC     PUSH

***************************************************************************
* HANDLE ERRORS  - PUT ERROR CODE IN A0, RESULT IN A9, CALL FP_ERROR
***************************************************************************
ERR6:                                ; "OVERFLOW"
         MOVI     INFI,A9            ; INFINITY IS ANSWER
         OR       A4,A9              ; ADD ON THE PROPER SIGN BIT
         MOVK     6,A0
         JRUC     CALLERROR

ERR11:                               ; " INFINITY * 0
         CLR      A9
         MOVK     11,A0
         JRUC     CALLERROR

ERR13:                               ; "UNDERFLOW"
         CLR      A9
         MOVK     13,A0

CALLERROR:
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

         MOVE     A9,*A14+,1         ; PUT RESULT ON STACK
         MMFM     SP,A0,A2,A4,A9
         RETS

         .end
