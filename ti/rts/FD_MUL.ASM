*******************************************************************************
*  FD$MUL     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function performs double precision floating point multiplication.
*  Two inputs are consumed from the stack and the result is pushed on the
*  stack.
*
*******************************************************************************

         .globl   FD$MUL

FD$MUL:
         .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_MUL

*******************************************************************************
*  34082
*******************************************************************************
         MOVE     A12,-*SP,1     ; STORE USED REGISTERS 

         MOVE     A14,A12
         SUBI     128,A12
         MOVD     *A12+,RB0      ; POP FIRST OPERAND OFF STACK
         MOVD     *A12+,RA0      ; POP SECOND OPERAND OFF STACK
         SUBI     128,A14

         MPYD     RA0,RB0,RA0    ; PERFORM MULTIPLY
         MOVD     RA0,*A14+      ; PUSH RESULT ON STACK

         MOVE     *SP+,A12,1
         RETS
         .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

IRNDMSK  .set     00000400h
GRNDMSK  .set     00000800h
MSBBIT   .set     80000000h
INFI     .set     7FF00000h

EMU_MUL:
         MMTM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9,A10,A11

	 .if      .TMS340_IEEE
         MOVE     -*A14,A1,1
         MOVE     -*A14,A0,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A3,1
         MOVE     -*A14,A2,1         ; POP SECOND NUMBER OFF STACK
	 .else
         MOVE     -*A14,A0,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A1,1
         MOVE     -*A14,A2,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A3,1
	 .endif

******************************************************************************
* IF EITHER OPERAND IS ZERO, RESULT IS ZERO
******************************************************************************

         CLR      A5
         MOVE     A0,A0
         JRZ      ZERO
         MOVE     A2,A2
         JRZ      ZERO

******************************************************************************
* CALCULATE RESULT SIGN BIT AND FINAL EXPONENT.
* PUT RESULT SIGN IN A10, RESULT EXPONENT IN A11
******************************************************************************
         MOVE     A0,A8              ; SAVE FOR LATER
         MOVE     A2,A11             ; SAVE FOR LATER
         SLL      1,A11
         SUBB     A10,A10            ; A10 FILLED WITH SIGN BIT OF 2nd NUMBER
         SLL      1,A8
         SUBB     A5,A5              ; A5 FILLED WITH SIGN BIT OF 1st NUMBER
         XOR      A5,A10
         SLL      31,A10             ; BIT 31 OF A10 CONTAINS RESULT SIGN BIT
         SRL      21,A8              ; ISOLATE EXPONENTS
         SRL      21,A11

         CMPI     2047,A11           ; WAS ONE OF EXPONENTS INFINITY
         JRZ      INFIN9
         CMPI     2047,A8
         JRZ      INFIN8

         ADD      A8,A11             ; GET RESULTANT EXPONENT
         SUBI     1023,A11           ; GET RID OF EXTRA BIAS

******************************************************************************
* LEFT JUSTIFY 1st MANTISSA IN REGISTERS A2 and A3
******************************************************************************
         MOVE     A3,A8
	 .if      .TMS340_IEEE
         SLL      11,A3
         SLL      11,A2
         ORI      MSBBIT,A2
         SRL      21,A8
	 .else
         SLL      12,A3
         SLL      12,A2
         SRL      20,A8
	 .endif
         OR       A8,A2

******************************************************************************
* LEFT JUSTIFY 2nd MANTISSA IN REGISTERS A0 and A1
******************************************************************************
         MOVE     A1,A8
	 .if      .TMS340_IEEE
         SLL      11,A0
         SLL      11,A1
         ORI      MSBBIT,A0
         SRL      21,A8
	 .else
         SLL      12,A0
         SLL      12,A1
         SRL      20,A8
	 .endif
         OR       A8,A0

******************************************************************************
* PERFORM THE MULTIPLY
******************************************************************************
MULT:
         MOVE    A0,A8               ; MULTIPLY TWO 52 BIT MANTISSAS
         MOVE    A1,A6               ;   THE ANSWER IS A 96 BIT PRECISION RESULT
         MOVE    A1,A4               ;   CONTAINED IN A0 - A3  WITH THE MSBS
         MPYU    A2,A0               ;   IN A0
         MPYU    A3,A8
         MPYU    A2,A6
         MPYU    A3,A4

         CLR     A5
         MOVE    A9,A2
         ADD     A8,A1
         ADDC    A5,A0
         ADD     A7,A2
         ADDC    A6,A1
         ADDC    A5,A0
         ADD     A4,A2
         ADDC    A5,A1
         ADDC    A5,A0
         JRZ     ZERO                ; IF NUMBER IS ZERO, RESULT IS ZERO

******************************************************************************
* NORMALIZE THE NUMBER, IF NECESSARY
******************************************************************************
NORM:
	 .if      .TMS340_IEEE
         ADDK     1,A11              ; ADJUST EXP FOR SECOND IMPLICIT ONE THAT
                                     ; WAS TACKED ON BEFORE
	 .endif
         BTST     31,A0              ; DO WE NEED TO NORMALIZE
         JRNZ     RNDTST             ; IF NOT GO AHEAD WITH ROUNDING
         SUBK     1,A11              ; A5 HOLDS FLAG INDICATING TOTAL EXP CHANGE
         SLL      1,A0               ; NORMALIZE WITH JUST ONE SHIFT LEFT
         SLL      1,A1               ;    DO 64 MSB'S OF RESULT MANTISSA
	 ADDC     A5,A0
                                     
******************************************************************************
* IF ROUNDING IS NEEDED, DO IT
******************************************************************************
RNDTST:
	 .if      .TMS340_IEEE
	 BTST     10,A1              ; CHECK VALUE OF BIT 53 OF MANTISSA
	 JRZ      NOVRFL             ; IF ZERO, NO ROUNDING
	 ADDI     IRNDMSK,A1         ; ADD ROUND VALUE TO MANTISSA
	 ADDC     A5,A0
	 JRNC     NOVRFL             ; IF NO OVERFLOW FROM ROUNDING, JUMP 

	 ADDK     1,A11              ; ADJUST EXPONENT
         JRUC     EXPCHK             

NOVRFL:
         SLL      1,A0               ; NORMALIZE MANTISSA TO IEEE
         SLL      1,A1               ;
         ADDC     A5,A0              ; PUT MS BIT OF A1 AT LS BIT OF A0
	 .else
	 BTST     11,A1              ; CHECK VALUE OF BIT 53 OF MANTISSA
	 JRZ      EXPCHK             ; IF ZERO, NO ROUNDING
	 ADDI     GRNDMSK,A1         ; ADD ROUND VALUE TO MANTISSA
	 ADDC     A5,A0
	 JRNC     EXPCHK             ; IF NO OVERFLOW FROM ROUNDING, JUMP 

	 SRL      1,A1               ; HANDLE OVERFLOW FROM ROUNDING
	 SRL      1,A0
	 JRNC     SKIP
	 ORI      MSBBIT,A1         
SKIP:
	 ORI      MSBBIT,A0          ; ADD TOP BIT ONTO MANTISSA
	 ADDK     1,A11              ; INCREMENT EXPONENT
	 .endif

******************************************************************************
* HANDLE FINAL MANIPULATION OF EXPONENT
******************************************************************************
EXPCHK:
         MOVE     A11,A11           
         JRLT     ERR13              ; JUMP IF UNDERFLOW
         JRZ      ZEROCHK            ; CHECK FOR ZERO
         CMPI     2047,A11           ; WAS THERE AN OVERFLOW
         JRGE     ERR6               ;

******************************************************************************
* BUILD THE RESULT AND PUSH ONTO THE STACK
******************************************************************************
FINI:
         MOVE     A0,A5              ; RIGHT JUSTIFY MANTISSA IN REG PAIR
         SLL      20,A5
         SRL      12,A1
         SRL      12,A0
         OR       A5,A1

         SLL      20,A11             ; JUSTIFY EXPONENT
         OR       A11,A0             ;       AND PUT INTO RESULT
PUSH:
         OR       A10,A0             ; OR IN SIGN BIT
	 .if      .TMS340_IEEE
         MOVE     A0,*A14+,1
         MOVE     A1,*A14+,1         ; PUSH RESULT ONTO STACK
	 .else
         MOVE     A1,*A14+,1         ; PUSH RESULT ONTO STACK
         MOVE     A0,*A14+,1
	 .endif

DONE:
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9,A10,A11
         RETS

***************************************************************************
* HANDLE SPECIAL CASES
***************************************************************************
ZEROCHK:
         MOVE     A0,A0              ; IS EXP AND MANT. = 0
         JRNZ     ERR13
         JRUC     FINI

ZERO:
         MOVE     A5,*A14+,1
         MOVE     A5,*A14+,1
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9,A10,A11
         RETS

INFIN8:
         MOVE     A11,A8
INFIN9:
         MOVE     A8,A8            ; (INFIN * 0) ?
         JRZ      ERR11            ; YES, INDICATE ERROR
         MOVI     INFI,A0
         CLR      A1
         JRUC     PUSH

***************************************************************************
* HANDLE ERRORS  - PUT ERROR CODE IN A0, MSB OF RESULT IN A3, CALL _fp_error
***************************************************************************
ERR6:                                ; "OVERFLOW"
         MOVI     INFI,A3            ; INFINITY IS ANSWER
         OR       A10,A3             ; ADD ON THE PROPER SIGN BIT
         MOVK     6,A0
         JRUC     CALLERROR

ERR11:                               ; " INFINITY * 0
         CLR      A3
         MOVK     11,A0
         JRUC     CALLERROR

ERR13:                               ; "UNDERFLOW"
         CLR      A3
         MOVK     13,A0

CALLERROR:
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

         CLR      A0
	 .if      .TMS340_IEEE
         MOVE     A3,*A14+,1         ; PUT RESULT ON STACK
         MOVE     A0,*A14+,1
	 .else
         MOVE     A0,*A14+,1
         MOVE     A3,*A14+,1         ; PUT RESULT ON STACK
	 .endif

         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9,A10,A11
         RETS

         .end
