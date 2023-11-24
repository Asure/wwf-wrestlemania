*******************************************************************************
*  FS$ADD     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function performs a single precision floating point addition or
*  subtraction on the two numbers passed on the call stack.  The numbers
*  are popped, the operation is performed, and the result is pushed back
*  on the stack.
*
*******************************************************************************

         .globl   FS$ADD
         .globl   FS$SUB  
         .globl   FS$SUB_R      ; ARGUMENTS ARE PUSHED IN REVERSE ORDER

******************************************************************************
* ENTRY POINT FOR FS$SUB_R   
******************************************************************************
FS$SUB_R:   
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_SUB_R

         MOVF     -*A14,RB0     ; POP FIRST OPERAND OFF STACK
         MOVF     -*A14,RA0     ; POP SECOND OPERAND OFF STACK
         NEGF     RA0,RA0       ; NEGATE SECOND OPERAND
         
         ADDF     RA0,RB0,RA0   ; PERFORM OPERATION
         MOVF     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else    
	 JRUC     EMU_SUB_R
	 .endif

******************************************************************************
* ENTRY POINT FOR FS$SUB  
******************************************************************************
FS$SUB:   
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_SUB

         MOVF     -*A14,RA0     ; POP SECOND OPERAND OFF STACK
         NEGF     RA0,RA0       ; NEGATE SECOND OPERAND
         MOVF     -*A14,RB0     ; POP FIRST OPERAND OFF STACK
         
         ADDF     RA0,RB0,RA0   ; PERFORM OPERATION
         MOVF     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else    
	 JRUC     EMU_SUB
	 .endif

******************************************************************************
* ENTRY POINT FOR FS$ADD  
******************************************************************************
FS$ADD:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_ADD

         MOVF     -*A14,RA0     ; POP SECOND OPERAND OFF STACK
         MOVF     -*A14,RB0     ; POP FIRST OPERAND OFF STACK

         ADDF     RA0,RB0,RA0   ; PERFORM OPERATION
         MOVF     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else    
	 JRUC     EMU_ADD
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

ONEIN    .set     080000000h
IRNDMSK  .set     020h
GRNDMSK  .set     040h
INFINITY .set     07F800000h

******************************************************************************
* REGISTER USAGE
*     A0, A1 Contain sign bits of 1st and 2nd number, respectively
*     A2, A3 Contain exponents of 1st and 2nd number
*     A6     Contains mantissa of 1st number
*     A8     Contains mantissa of 2nd number
******************************************************************************

******************************************************************************
* ENTRY POINT FOR FS$SUB_R  
******************************************************************************
EMU_SUB_R:
         MMTM     SP,A0,A1,A2,A3,A4,A6
         MOVE     -*A14,A6,1         ; POP FIRST NUMBER OFF STACK
         MOVE     -*A14,A8,1         ; POP SECOND NUMBER OFF STACK
         XORI     ONEIN,A8           ; NEGATE THE NUMBER
         JRUC     starti

******************************************************************************
* ENTRY POINT FOR FS$SUB  
******************************************************************************
EMU_SUB:
         MMTM     SP,A0,A1,A2,A3,A4,A6
         MOVE     -*A14,A8,1         ; POP SECOND NUMBER OFF STACK
         XORI     ONEIN,A8           ; NEGATE THE NUMBER
         JRUC     contin

******************************************************************************
* ENTRY POINT FOR FS$ADD
******************************************************************************
EMU_ADD:
         MMTM     SP,A0,A1,A2,A3,A4,A6
         MOVE     -*A14,A8,1         ; POP SECOND NUMBER OFF STACK
contin:  MOVE     -*A14,A6,1         ; POP FIRST NUMBER OFF STACK

******************************************************************************
* CHECK FOR ZERO OPERANDS
******************************************************************************
starti:
         MOVE     A6,A3
         SLL      1,A3               ; LOSE SIGN BIT
         JRZ      QUIT               ; RETURN SECOND OPERAND
         MOVE     A8,A2               
         SLL      1,A2               ; LOSE SIGN BIT
         JRZ      RETFST             ; RETURN FIRST OPERAND  

******************************************************************************
* ISOLATE SIGN BITS IN A0 AND A1
******************************************************************************
         SLL      1,A8
         SUBB     A0,A0              ;A0 = ALL SIGN BITS OF A8
         SLL      31,A0
         SLL      1,A6
         SUBB     A1,A1              ;A1 = ALL SIGN BITS OF A6
         SLL      31,A1

******************************************************************************
* ISOLATE EXPONENTS
******************************************************************************
         SRL      24,A2
         SRL      24,A3

******************************************************************************
* LEFT JUSTIFY MANTISSAS AND HANDLE ALIGNMENT
******************************************************************************
         SLL      8,A8
	 .if      .TMS340_IEEE
         SRL      3,A8
         ORI      020000000H,A8
	 .else
	 SRL      2,A8
	 .endif
         SLL      8,A6
	 .if      .TMS340_IEEE
         SRL      3,A6
         ORI      020000000H,A6
	 .else
	 SRL      2,A6
	 .endif

*****************************************************************************
* CHECK FOR ERRORS BEFORE ATTEMPTING ANY OPERATIONS
*****************************************************************************
         CMPI     255,A2              ; IS FIRST NUMBER INFINITY
         JRZ      ITEST

         CMPI     255,A3              ; IF SECOND COMPONENT IS INFINITY
         JRZ      INFIN2              ;   RESULT IS INFINITY

******************************************************************************
* HANDLE SETUP OF ADDITION.
******************************************************************************
SETUP:
         SUB      A3,A2              ; SUBTRACT EXPONENTS
         JRZ      EQEXP              ; IF ZERO THEN NO NEED TO SHIFT MANTISSAS
         JRLE     A3BIG              ; IF > 0 THEN A2 EXP IS BIGGER, SO SHIFT
                                     ; 2ND  #'S MANTISSA TO RIGHT -A2 TIMES
A2BIG:
         ADD      A2,A3              ; SINCE A3 WAS SMALLER,ORIGINALLY, ADD BACK
         JRUC     SHIFT              ; THE SHIFT COUNT TO A3 = A2 +A3 SO THAT
                                     ; A3 HOLDS THE RESULTANT (LARGER) EXPONENT
EQEXP:
         CMP      A8,A6              ; WHICH MANTISSA IS BIGGEST, WE WANT THE
         JRLS     CHECK              ; BIGGEST ONE IN A8
         JRUC     SWITCH

A3BIG:                               ; ELSE A3 EXP IS BIGGER, SO SHIFT 1ST #
         NEG      A2                 ; SWAP ORDER OF NUMBERS

******************************************************************************
*  SWAP NUMBERS AROUND SO BIGGER NUMBER IS ALWAYS IN A8
******************************************************************************
SWITCH:
         XOR      A6,A8              ; SWAP MANTISSAS
         XOR      A8,A6
         XOR      A6,A8

         XOR      A0,A1              ; SWAP SIGN BITS
         XOR      A1,A0
         XOR      A0,A1

*****************************************************************************
* SHIFT MANTISSAS SO THAT THEY ARE NORMALIZED TO SAME AMOUNT
*****************************************************************************
CHECK:
         MOVE     A2,A2              ; DO SHIFT IF A2 != 0    (CMPI  0,A2)
         JRZ      SGNTST

SHIFT:
         CMPI     30,A2              ; IF SHIFT COUNT IS > 30 THEN ALL THE
         JRLT     LT30
         CLR      A6                 ; MANTISSA IS ZEROED OUT
         JRUC     SGNTST

LT30:
         NEG      A2
         SRL      A2,A6              ; SHIFT MANTISSA RIGHT BY A2 BITS 

*******************************************************************************
* DETERMINE WHETHER AN ADD OR SUBTRACT MUST BE USED
*******************************************************************************
SGNTST:
         CMP      A0,A1              ; DO WE NEED TO SUBTRACT OR ADD
         JRZ      ADD                ; IF SIGNS ARE ALIKE WE ADD

*******************************************************************************
* IF SIGN BITS ARE DIFFERENT, PERFORM A SUBTRACT
*******************************************************************************
         SUB      A6,A8              ; SUBTRACT SMALLER NUMBER FROM THE LARGER
         LMO      A8,A6              ; GET 1'S COMPLEMENT OF LEFT MOST 1 BIT #
         JRZ      ZERO               ; IF NO BITS IN MANTISSA, ZERO
         SUBK     2,A6               ; CALC SHIFT COUNT FOR NORMALIZING
         JRZ      RNDTST
         SUB      A6,A3              ; ADJUST THE EXPONENT ACCORDINGLY
         SLL      A6,A8              ; NORMALIZE MANTISSA
         JRUC     RNDTST

*******************************************************************************
* IF SIGN BITS ARE THE SAME,  PERFORM AN ADDITION
*******************************************************************************
ADD:
         ADD      A6,A8
         BTST     30,A8              ; WAS THERE AN OVERFLOW
         JRZ      RNDTST
         ADDK     1,A3               ; ADJUST THE EXPONENT ACCORDINGLY
         SRL      1,A8

*******************************************************************************
* PERFORM ROUNDING, IF NEEDED.  A BIT MESSY BECAUSE OF RUNTIME 
* SELECT BETWEEN GSP AND IEEE
*******************************************************************************
RNDTST:
***************************************************************************
* IEEE ROUNDING
***************************************************************************
	 .if      .TMS340_IEEE
         ADDI     IRNDMSK,A8          ; WE ARE ROUNDING UP SO ADD 1 (TO BIT #09)
         BTST     30,A8              ; WAS THERE AN OVERFLOW
         JRZ      NOVRFL

         ADDK     1,A3               ; ADJUST EXPONENT
         JRUC     MASK

NOVRFL:
         SLL      1,A8               ; NORMALIZE MANTISSA TO IEEE
        
MASK:    
         ANDI     03FFFFFFFH,A8      ; MASK IMPLICIT ONE
***************************************************************************
* GSP ROUNDING
***************************************************************************
	 .else
	 ADDI     GRNDMSK,A8         ; ROUND UP GSP, ADD 1 TO BIT #10
	 BTST     30,A8              ; OVERFLOW?
	 JRZ      EXPCHK             ; NO OVERFLOW, GO CHECK EXPONENT
	 ADDK     1,A3               ; OVERFLOW, ADD 1 TO EXPONENT
	 SRL      1,A8               ; ADJUST GSP MANTISSA
	 .endif

***************************************************************************
* CHECK THE RESULT EXPONENT
***************************************************************************
EXPCHK:
         MOVE     A3,A3              ; CMPI  0,A3
         JRLT     ERR12              ; IF A3 < 0 THEN THERE IS AN UNDERFLOW
         JRNZ     OK

         SRL      7,A8               ; IF A3 = 0, IS RESULT MANTISSA ZERO?
         JRNZ     ERR12
         JRUC     ZERO
OK:
         CMPI     255,A3
         JRGE     ERR5               ; IF A3 >=255  THEN THERE WAS AN OVERFLOW

***************************************************************************
* BUILD RESULT AND PUSH ONTO STACK
***************************************************************************
FINI:
         SRL      7,A8               ; POSITION MANTISSA 
         SLL      23,A3              ; POSITION EXPONENT
         OR       A3,A8              ; ADD IN EXPONENT
         OR       A0,A8              ; ADD IN SIGN BIT
QUIT:
         MOVE     A8,*A14+,1         ; PUSH RESULT ONTO STACK

DONE:
         MMFM     SP,A0,A1,A2,A3,A4,A6
         RETS

RETFST:
         MOVE     A6,A8              ; RETURN SECOND OPERAND, FST = 0
         JRUC     QUIT
***************************************************************************
* HANDLE SPECIAL CASES
***************************************************************************
ZERO:
         MOVE     A8,*A14+,1         ; PUSH RESULT ONTO STACK
         MMFM     SP,A0,A1,A2,A3,A4,A6
         RETS

ITEST:
         CMPI     255,A3             ; IS SECOND NUMBER INFINITY
         JRNZ     INFIN              ; IF NOT THEN CARRY ON
         CMP      A0,A1              ; DO WE HAVE INFIN - INFIN ? ...
         JRNZ     ERR4               ;    IF SO, INDICATE THAT ERROR
         JRUC     INFIN              ;    ELSE INFINITY ERROR

INFIN2:
         MOVE     A1,A0              ; SAVE SIGN BIT OF SECOND NUMBER

INFIN:
         MOVI     INFINITY,A8
         OR       A0,A8
         MOVE     A8,*A14+,1         ; PUSH INFINITY ONTO STACK
         MMFM     SP,A0,A1,A2,A3,A4,A6
         RETS

***************************************************************************
* HANDLE ERRORS   (PUT ERROR CODE IN A0 AND CALL ERROR ROUTINE)
***************************************************************************
ERR4:                                ; "INFINITY - INFINITY"
         MOVK     4,A0
         CLR      A3                 ; DEFAULT RESULT IS ZERO
         JRUC     CALLERROR

ERR5:                                ; "OVERFLOW"
         MOVE     A0,A3
         ORI      INFINITY,A3
         MOVK     5,A0               ; 
         JRUC     CALLERROR          ;

ERR12:                               ; "UNDERFLOW"
         MOVK     12,A0
         CLR      A3                 ; DEFAULT RESULT IS ZERO

CALLERROR:
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

         MOVE     A3,*A14+,1
         MMFM     SP,A0,A1,A2,A3,A4,A6
         RETS
         .end
