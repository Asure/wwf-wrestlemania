*******************************************************************************
*  FD$DIV     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function performs a double precision division on the top two numbers
*  on the call stack, and pushes the result on the stack.
*
*******************************************************************************
         
         .globl   FD$DIV
         .globl   FD$DIV_R      ; ARGUMENTS ARE PUSHED IN REVERSE ORDER

*******************************************************************************
*  ENTRY POINT FOR FD$DIV_R
*******************************************************************************
FD$DIV_R:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_DIVR

         MOVE     A12,*-SP,1    ; STORE USED REGISTERS
    
         MOVE     A14,A12
         SUBI     128,A12
         MOVD     *A12+,RB0     ; POP DIVISOR OFF STACK
         MOVD     *A12+,RA0     ; POP DIVIDEND OFF STACK
         SUBI     128,A14
         
         DIVD     RA0,RB0,RA0   ; PERFORM DIVISION
         MOVD     RA0,*A14+     ; PUSH RESULT ON STACK

         MOVE     *SP+,A12,1
         RETS
	 .else
	 JRUC     EMU_DIVR
	 .endif

*******************************************************************************
*  ENTRY POINT FOR FD$DIV
*******************************************************************************
FD$DIV:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_DIV

         MOVE     A12,*-SP,1    ; STORE USED REGISTERS
        
         MOVE     A14,A12
         SUBI     128,A12
         MOVD     *A12+,RA0     ; POP DIVIDEND OFF STACK
         MOVD     *A12+,RB0     ; POP DIVISOR OFF STACK
         SUBI     128,A14

         DIVD     RA0,RB0,RA0   ; PERFORM DIVISION
         MOVD     RA0,*A14+     ; PUSH RESULT ON STACK

         MOVE     *SP+,A12,1
         RETS
	 .else
	 JRUC     EMU_DIV
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

INFIN    .set     07FF00000h
SGN      .set     080000000h
	 .if      .TMS340_IEEE
ONE      .set     03FF00000h
	 .else
ONE      .set     040080000h
	 .endif

*******************************************************************************
*  ENTRY POINT FOR FD$DIV_R
*******************************************************************************
EMU_DIVR:
         MMTM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9
	 .if      .TMS340_IEEE
         MOVE     -*A14,A1,1         ; POP DIVIDEND OFF STACK
         MOVE     -*A14,A4,1       
         MOVE     -*A14,A3,1         ; POP DIVISOR OFF STACK
         MOVE     -*A14,A5,1
	 .else
         MOVE     -*A14,A4,1       
         MOVE     -*A14,A1,1         ; POP DIVIDEND OFF STACK
         MOVE     -*A14,A5,1
         MOVE     -*A14,A3,1         ; POP DIVISOR OFF STACK
	 .endif
	 JRUC     starti

*******************************************************************************
*  ENTRY POINT FOR FD$DIV
*******************************************************************************
EMU_DIV:
         MMTM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9
	 .if      .TMS340_IEEE
         MOVE     -*A14,A3,1         ; POP DIVISOR OFF STACK
         MOVE     -*A14,A5,1
         MOVE     -*A14,A1,1         ; POP DIVIDEND OFF STACK
         MOVE     -*A14,A4,1       
	 .else
         MOVE     -*A14,A5,1
         MOVE     -*A14,A3,1         ; POP DIVISOR OFF STACK
         MOVE     -*A14,A4,1       
         MOVE     -*A14,A1,1         ; POP DIVIDEND OFF STACK
	 .endif

*******************************************************************************
* PLACE DIVIDEND MANTISSA IN REGISTER PAIR A0:A1 SHIFTED RIGHT FOUR BITS.
*******************************************************************************
starti:  MOVE     A1,A8
	 .if      .TMS340_IEEE
         SLL      7,A1               ; LEFT JUSTIFY 25 LSBS OF DIVIDEND MANT
         SRL      25,A8
	 .else
         SLL      8,A1               ; LEFT JUSTIFY 24 LSBS OF DIVIDEND MANT
	 SRL      24,A8
	 .endif
         MOVE     A4,A0
         SLL      12,A0              ; GET RID OF EXPONENT & SIGN
	 .if      .TMS340_IEEE
         SRL      5,A0
         ORI      008000000H,A0      ; PUT IMPLICIT ONE IN MANTISSA
	 .else
         SRL      4,A0
	 .endif
         OR       A8,A0              ; OR IN 8 BITS FROM MSB's OF SECOND HALF

*******************************************************************************
*  PLACE DIVISOR IN REGISTER PAIR A2:A3 LEFT JUSTIFIED.
*******************************************************************************
         MOVE     A3,A8
	 .if      .TMS340_IEEE
         SLL      11,A3              ; LEFT JUSTIFY LSB'S OF IEEE MANTISSA
         SRL      21,A8
	 .else
         SLL      12,A3              ; LEFT JUSTIFY LSB'S OF GSP MANTISSA
         SRL      20,A8
	 .endif
         MOVE     A5,A2
         SLL      12,A2              ; LEFT JUSTIFY MSB'S OF MANTISSA
	 .if      .TMS340_IEEE
         SRL      1,A2
         ORI      080000000H,A2      ; PUT IMPLICIT ONE IN MANTISSA
	 .endif
         OR       A8,A2

*******************************************************************************
* ISOLATE RESULT SIGN AND BOTH EXPONENTS
*******************************************************************************
         SLL      1,A4
         SUBB     A9,A9              ; FILL A9 WITH FIRST SIGN BIT
         SLL      1,A5
         SUBB     A8,A8              ; FILL A8 WITH SECOND SIGN BIT
         XOR      A8,A9
         SLL      31,A9              ; RESULT SIGN BIT IN BIT 31 OF A9

         SRL      21,A4
         SRL      21,A5              ; NOTE : THIS SETS STATUS

*******************************************************************************
* CHECK FOR ILLEGAL DIVIDE ERRORS
*******************************************************************************
         JRZ      ERR15              ; IF DIVISOR IS ZERO, JUMP
         CMPI     2047,A5
         JRNZ     CHK_DIVIDEND       ; IF DIVISOR NOT INFINITY, JUMP
         CMP      A5,A4
         JRZ      ERR16              ; INF./INF. - JUMP
         JRUC     ZERO               ; #/INF.

CHK_DIVIDEND:
         CMPI     2047,A4
         JRZ      FINI               ; JUMP IF INF./#
         MOVE     A4,A4
         JRZ      ZERO               ; JUMP IF 0/#

*******************************************************************************
*  PERFORM THE DIVIDE
*******************************************************************************
DIV:
         CLR      A8                 ; CLEAR EXP. CHANGE FLAG
         DIVU     A2,A0              ; A0 =  A0 | A1  /  A2
                                     ; QM = UM+E*UL / VM
         MOVE     A1,A6              ;
         CLR      A7
         DIVU     A2,A6              ; A6 = A6 | A7 / A2
                                     ; QL = R*(2**32) /VM
         MOVE     A6,A1              ; PUT QM + E*QL  IN A0 | A1
         MOVE     A0,A6              ; PUT QM IN A6
         MPYU     A3,A6              ; QM * VL = A6 | A7
         DIVU     A2,A6              ; (QM * VL) / VM = A6

         SUB      A6,A1              ; A0 | A1 = QM +E*QL   -  (QM * VL)/VM
         SUBB     A8,A0

         BTST     28,A0              ; WAS THERE AN OVERFLOW
         JRZ      RNDTST
         SUBK     1,A5               ; ADJUST EXPONENT FLAG
         SRL      1,A1               ; NORMALIZE THE RESULT
         SRL      1,A0
         JRNC     RNDTST             ; SHIFT TWO WORDS
         ORI      SGN,A1

*******************************************************************************
*  PERFORM ROUNDING IF NEEDED
*******************************************************************************
RNDTST:
	 .if      .TMS340_IEEE
         BTST     6,A1               ; DO WE NEED TO ROUND
         JRZ      NOVRFL
         ADDI     64,A1              ; GO AHEAD AND ROUND UP
         ADDC     A8,A0              ; ADD 1 TO 64 BIT RESULT
         BTST     28,A0              ; WAS THERE AN OVERFLOW
         JRZ      NOVRFL
         SUBK     1,A5               ; ADJUST EXPONENT FLAG
         JRUC     MASK

NOVRFL:
         ADDK     1,A5               ; ADD IN SECOND IMPLICIT ONE TO EXP
         SLL      1,A0               ; NORMALIZE MANTISSA TO IEEE
         SLL      1,A1               ;
         ADDC     A8,A0              ; MOVE MS BIT OF A1 TO LS BIT OF A0

MASK:
         ANDI     00FFFFFFFH,A0      ; MASK IMPLICIT ONE
	 .else
         BTST     7,A1               ; DO WE NEED TO ROUND
	 JRZ      EXPCHK
	 ADDI     128,A1             ; GO AHEAD AND ROUND UP
         ADDC     A8,A0              ; ADD 1 TO 64 BIT RESULT
         BTST     28,A0              ; WAS THERE AN OVERFLOW
	 JRZ      EXPCHK
         SUBK     1,A5               ; ADJUST EXPONENT FLAG
	 SRL      1,A1               ; NORMALIZE THE RESULT
	 SRL      1,A0
	 JRNC     RNDTST             ; SHIFT TWO WORDS
	 ANDI     SGN,A1 
	 .endif
*******************************************************************************
* MAKE RESULT EXPONENT AND CHECK FOR ERRORS
*******************************************************************************
EXPCHK:
         MOVE     A4,A6              ; SAVE DIVIDEND EXP.
         SUB      A5,A4              ; GET RESULTANT EXPONENT
         ADDI     1023,A4

         JRLE     ERR14              ; JMP IF OVERFLOW
         CMPI     2047,A4            ; IS THERE AN OVERFLOW
         JRLT     FINI
         MOVI     2047,A4            ; SATURATE THE EXPONENT
         CMP      A6,A4              ; THERE IS AN OVERFLOW IF RESULTANT EXP
         JRNZ     ERR7               ; IS INFINITY BUT THE DIVIDEND WAS NOT INF.

*******************************************************************************
* BUILD THE RESULT  AND PUSH IT ONTO THE STACK
*******************************************************************************
FINI:
         MOVE     A0,A8              ; RIGHT JUSTIFY MANTISSA IN REGISTER PAIR
         SRL      8,A0
         SRL      8,A1
         SLL      24,A8              ; PUT 8 LSB's OF A0 IN 8 MSB's OF A1
         OR       A8,A1

         SLL      20,A4              ; PUT EXPONENT IN PLACE
         OR       A9,A4              ; PUT SIGN BIT IN RESULT
         OR       A4,A0

	 .if      .TMS340_IEEE
         MOVE     A0,*A14+,1         ; PUSH MSB's RESULT ON STACK
         MOVE     A1,*A14+,1         ; PUSH LSB's RESULT ON STACK
	 .else
         MOVE     A1,*A14+,1         ; PUSH LSB's RESULT ON STACK
         MOVE     A0,*A14+,1         ; PUSH MSB's RESULT ON STACK
	 .endif

*******************************************************************************
*  RETURN TO CALLER
*******************************************************************************
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9
         RETS

*******************************************************************************
* HANDLE SPECIAL CASES AND ERRORS
*******************************************************************************
ZERO:
         CLR      A6
         MOVE     A6,*A14+,1
         MOVE     A6,*A14+,1
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9
         RETS


*******************************************************************************
* ERROR HANDLERS - PUT MSB RESULT IN A9,    ERROR CODE IN A0, JUMP TO CALL
*******************************************************************************
ERR7:                                ; " OVERFLOW " ERROR
         ORI      INFIN,A9           ; ADD INFINITY IN WITH SIGN BIT
         MOVK     7,A0
         JRUC     ERROR_CALL

ERR14:                               ; "UNDERFLOW" ERROR
         CLR      A9
         MOVK     14,A0
         JRUC     ERROR_CALL

ERR15:                               ; "DIVIDE BY ZERO"
         ORI      INFIN,A9
         MOVK     15,A0
         JRUC     ERROR_CALL

ERR16:                               ; INFINITY / INFINITY
         ORI      ONE,A9
         MOVK     16,A0

*******************************************************************************
* PUSH ERROR CODE ON STACK, CALL ERROR ROUTINE, PUSH RESULT AND RETURN.
*******************************************************************************
ERROR_CALL:
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUSH ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

         CLR      A5
	 .if      .TMS340_IEEE
         MOVE     A9,*A14+,1
         MOVE     A5,*A14+,1         ; PUSH RESULT ON STACK
	 .else
         MOVE     A5,*A14+,1         ; PUSH RESULT ON STACK
         MOVE     A9,*A14+,1
	 .endif

         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7,A9
         RETS

         .end
