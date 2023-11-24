*******************************************************************************
*  FS$DIV     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function performs a single precision division on the top two numbers
*  on the call stack, and pushes the result on the stack.
*
*******************************************************************************
         
         .globl   FS$DIV
         .globl   FS$DIV_R      ; ARGUMENTS ARE PUSHED IN REVERSE ORDER

*******************************************************************************
*  ENTRY POINT FOR FS$DIV_R
*******************************************************************************
FS$DIV_R:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_DIVR

         MOVF     -*A14,RA0     ; POP DIVIDEND OFF STACK
         MOVF     -*A14,RB0     ; POP DIVISOR OFF STACK
         
         DIVF     RA0,RB0,RA0   ; PERFORM DIVISION
         MOVF     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else   
	 JRUC     EMU_DIVR
	 .endif

*******************************************************************************
*  ENTRY POINT FOR FS$DIV
*******************************************************************************
FS$DIV:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_DIV

         MOVF     -*A14,RB0     ; POP DIVISOR OFF STACK
         MOVF     -*A14,RA0     ; POP DIVIDEND OFF STACK

         DIVF     RA0,RB0,RA0   ; PERFORM DIVISION
         MOVF     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else
	 JRUC     EMU_DIV
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

INFIN    .set     07F800000h
SGN      .set     080000000h
I_ONE    .set     03F800000h
G_ONE    .set     040400000h

*******************************************************************************
* REGISTER USAGE
*   A2 - Contains exponent of dividend, and result exponent
*   A4 - Contains exponent of divisor
*   A6 - Contains sign bit of result
*   A8 - Contains mantissa of result
*   A9 - Scratch register
*******************************************************************************

*******************************************************************************
*  ENTRY POINT FOR FS$DIV_R
*******************************************************************************
EMU_DIVR:
         MMTM     SP,A0,A2,A4,A6,A9
         MOVE     -*A14,A2,1         ; POP DIVIDEND OFF STACK
         MOVE     -*A14,A4,1         ; POP DIVISOR OFF STACK
         JRUC     starti

*******************************************************************************
*  ENTRY POINT FOR FS$DIV
*******************************************************************************
EMU_DIV:
         MMTM     SP,A0,A2,A4,A6,A9
         MOVE     -*A14,A4,1         ; POP DIVISOR OFF STACK
         MOVE     -*A14,A2,1         ; POP DIVIDEND OFF STACK

*******************************************************************************
* PLACE DIVIDEND MANTISSA IN REGISTER PAIR SHIFTED RIGHT FOUR BITS.
*******************************************************************************
starti:  MOVE     A2,A8
         SLL      9,A8               ; LEFT JUSTIFY
	 .if      .TMS340_IEEE
         SRL      5,A8               ; MASK OFF TOP 4 BITS
         ORI      008000000H,A8      ; PUTTING IMPLICIT ONE IN BIT 27
	 .else
	 SRL      4,A8               ; MASK OFF 4 BITS FROM GSP MANT.
	 .endif

*******************************************************************************
*  PLACE DIVISOR IN REGISTER PAIR LEFT JUSTIFIED.
*******************************************************************************
         MOVE     A4,A0
         SLL      9,A0
	 .if      .TMS340_IEEE
         SRL      1,A0               ; TACK IMPLICIT ONE ON FRONT FOR IEEE
         ORI      080000000H,A0
	 .endif

*******************************************************************************
* ISOLATE RESULT SIGN AND BOTH EXPONENTS
*******************************************************************************
         SLL      1,A2
         SUBB     A9,A9              ; FILL A9 WITH FIRST SIGN BIT
         SLL      1,A4
         SUBB     A6,A6              ; FILL A6 WITH SECOND SIGN BIT
         XOR      A9,A6
         SLL      31,A6              ; RESULT SIGN BIT IN BIT 31 OF A6

         SRL      24,A2
         SRL      24,A4              ; NOTE : THIS SETS STATUS

*******************************************************************************
* CHECK FOR ILLEGAL DIVIDE ERRORS
*******************************************************************************
         JRZ      ERR15              ; IF DIVISOR IS ZERO, JUMP
         CMPI     255,A4
	 JRZ      CHK_INFIN          ; CHECK FOR COMBINATIONS OF INFINITY

         CMPI     255,A2
         JRZ      FINI               ; JUMP IF INF./#
         MOVE     A2,A2
         JRZ      ZERO               ; JUMP IF 0/#

*******************************************************************************
*  PERFORM THE DIVIDE
*******************************************************************************
DIV:
         SUB      A4,A2              ; GET RESULTANT EXPONENT
         CLR      A9                 ; TO PREPARE FOR 64 BY 32 BIT DIVISION
         DIVU     A0,A8              ; A8 =  A8 | A9  /  A0
                                     ; QM = UM+E*UL / VM
         BTST     28,A8              ; WAS THERE AN OVERFLOW
         JRZ      RNDTST
         ADDK     1,A2               ; ADJUST EXPONENT FLAG
         SRL      1,A8               ; NORMALIZE THE RESULT

*******************************************************************************
*  PERFORM ROUNDING IF NEEDED
*******************************************************************************
RNDTST:
	 .if      .TMS340_IEEE
         ADDK     8,A8               ; GO AHEAD AND ROUND UP
         BTST     28,A8              ; WAS THERE AN OVERFLOW
         JRZ      NOVRFL

         ADDK     1,A2               ; ADJUST EXPONENT
         JRUC     MASK

NOVRFL:
         SUBK     1,A2
         SLL      1,A8               ; NORMALIZE MANTISSA TO IEEE
         
MASK:
         ANDI     0FFFFFFFH,A8       ; MASK IMPLICIT ONE
	 .else
         ADDK     16,A8              ; GO AHEAD AND ROUND UP GSP
         BTST     28,A8              ; WAS THERE AN OVERFLOW
	 JRZ      EXPCHK             ; NO OVERFLOW 
	 ADDK     1,A2               ; OVERFLOW, ADD 1 TO EXPONENT
	 SRL      1,A8               ; ADJUST MANTISSA
	 .endif

*******************************************************************************
* MAKE RESULT EXPONENT AND CHECK FOR ERRORS
*******************************************************************************
EXPCHK:
         ADDI     127,A2             ; ADD IN BIAS
         JRLE     ERR14              ; JMP IF UNDERFLOW 
         CMPI     255,A2             
         JRGE     ERR7               ; JMP IF OVERFLOW

*******************************************************************************
* BUILD THE RESULT  AND PUSH IT ONTO THE STACK
*******************************************************************************
FINI:
         SRL      5,A8               ; RIGHT JUSTIFY MANTISSA IN REGISTER PAIR
         SLL      23,A2              ; PUT EXPONENT IN PLACE
         OR       A6,A2              ; PUT SIGN BIT IN RESULT
         OR       A2,A8              ; PUT EXPONENT IN RESULT
         MOVE     A8,*A14+,1         ; PUSH RESULT ON STACK

*******************************************************************************
*  RETURN TO CALLER
*******************************************************************************
         MMFM     SP,A0,A2,A4,A6,A9
         RETS

*******************************************************************************
* HANDLE SPECIAL CASES AND ERRORS
*******************************************************************************
CHK_INFIN:
         CMP      A4,A2
         JRZ      ERR16              ; INF./INF. - JUMP
                                     ; #/INF.    - HANDLE AS ZERO
ZERO:
         CLR      A8
         MOVE     A8,*A14+,1
         MMFM     SP,A0,A2,A4,A6,A9
         RETS

*******************************************************************************
* ERROR HANDLERS - PUT RESULT IN A6,    ERROR CODE IN A0, JUMP TO CALL
*******************************************************************************
ERR7:                                ; " OVERFLOW " ERROR
         ORI      INFIN,A6           ; ADD INFINITY IN WITH SIGN BIT
         MOVK     7,A0
         JRUC     ERROR_CALL

ERR14:                               ; "UNDERFLOW" ERROR
         CLR      A6
         MOVK     14,A0
         JRUC     ERROR_CALL

ERR15:                               ; "DIVIDE BY ZERO"
         ORI      INFIN,A6
         MOVK     15,A0
         JRUC     ERROR_CALL

ERR16:                               ; INFINITY / INFINITY
         .if      .TMS340_IEEE
         ORI      I_ONE,A6
         .else
         ORI      G_ONE,A6
         .endif
         MOVK     16,A0              ; PUT ERROR CODE ON STACK

*******************************************************************************
* PUSH ERROR CODE ON STACK, CALL ERROR ROUTINE, PUSH RESULT AND RETURN.
*******************************************************************************
ERROR_CALL:
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUSH ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

         MOVE     A6,*A14+,1
         MMFM     SP,A0,A2,A4,A6,A9
         RETS

         .end
