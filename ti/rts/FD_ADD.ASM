*******************************************************************************
*  FD$ADD     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function performs a double precision floating point addition or
*  subtraction on the two numbers passed on the call stack.  The numbers
*  are popped, the operation is performed, and the result is pushed back
*  on the stack.
*
*******************************************************************************

         .globl   FD$ADD
         .globl   FD$SUB  
         .globl   FD$SUB_R      ; ARGUMENTS ARE PUSHED IN REVERSE ORDER

******************************************************************************
* ENTRY POINT FOR FD$SUB_R   
******************************************************************************
FD$SUB_R:   
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_SUBR

         MOVE     A14,A8
         SUBI     128,A8
         MOVD     *A8+,RA0      ; POP SECOND OPERAND
         NEGD     RA0,RA0       ; NEGATE SECOND OPERAND 
         MOVD     *A8+,RB0      ; POP FIRST OPERAND
         SUBI     128,A14 
         
         ADDD     RA0,RB0,RA0   ; PERFORM OPERATION
         MOVD     RA0,*A14+     ; PUSH RESULT ON STACK

	 RETS
	 .else 
	 JRUC     EMU_SUBR
	 .endif

******************************************************************************
* ENTRY POINT FOR FD$SUB  
******************************************************************************
FD$SUB:   
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_SUB

         MOVE     A14,A8
         SUBI     128,A8
         MOVD     *A8+,RB0      ; POP FIRST OPERAND
         MOVD     *A8+,RA0      ; POP SECOND OPERAND
         NEGD     RA0,RA0       ; NEGATE SECOND OPERAND 
         SUBI     128,A14 
        
         ADDD     RA0,RB0,RA0   ; PERFORM OPERATION
         MOVD     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else
	 JRUC     EMU_SUB
	 .endif

******************************************************************************
* ENTRY POINT FOR FD$ADD  
******************************************************************************
FD$ADD:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMU_ADD

         MOVE     A14,A8
         SUBI     128,A8
         MOVD     *A8+,RB0      ; POP FIRST OPERAND
         MOVD     *A8+,RA0      ; POP SECOND OPERAND
         SUBI     128,A14 

         ADDD     RA0,RB0,RA0   ; PERFORM OPERATION
         MOVD     RA0,*A14+     ; PUSH RESULT ON STACK

         RETS
	 .else
	 JRUC     EMU_ADD
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
         .globl   _fp_error

ONEIN    .set     080000000h
IRNDMSK  .set     000000100h
GRNDMSK  .set     000000400h

******************************************************************************
* REGISTER USAGE
*     A0, A8 Contain sign bits of 1st and 2nd number, respectively
*     A1, A2 Contain exponents of 1st and 2nd number
*     A3, A4 Contains mantissa of 1st number
*     A5, A6 Contains mantissa of 2nd number
******************************************************************************

******************************************************************************
* ENTRY POINT FOR FD$SUB_R   
******************************************************************************
EMU_SUBR:
         MMTM     SP,A0,A1,A2,A3,A4,A5,A6,A7
	 .if      .TMS340_IEEE
         MOVE     -*A14,A4,1         ; POP FIRST NUMBER OFF STACK
         MOVE     -*A14,A3,1
         MOVE     -*A14,A6,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A5,1
	 .else
         MOVE     -*A14,A3,1         ; POP FIRST NUMBER OFF STACK
         MOVE     -*A14,A4,1
         MOVE     -*A14,A5,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A6,1
	 .endif
	 XORI     ONEIN,A5           ; NEGATE THE NUMBER
	 JRUC     starti

******************************************************************************
* ENTRY POINT FOR FD$SUB  
******************************************************************************
EMU_SUB:
         MMTM     SP,A0,A1,A2,A3,A4,A5,A6,A7
	 .if      .TMS340_IEEE
         MOVE     -*A14,A6,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A5,1
	 .else
         MOVE     -*A14,A5,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A6,1
	 .endif
	 XORI     ONEIN,A5           ; NEGATE THE NUMBER
	 JRUC     contin

******************************************************************************
* ENTRY POINT FOR FD$ADD  
******************************************************************************
EMU_ADD:
         MMTM     SP,A0,A1,A2,A3,A4,A5,A6,A7
         .if      .TMS340_IEEE
         MOVE     -*A14,A6,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A5,1
	 .else
         MOVE     -*A14,A5,1         ; POP SECOND NUMBER OFF STACK
         MOVE     -*A14,A6,1
	 .endif

contin: 
	 .if      .TMS340_IEEE
	 MOVE     -*A14,A4,1         ; POP FIRST NUMBER OFF STACK
         MOVE     -*A14,A3,1
	 .else
	 MOVE     -*A14,A3,1         ; POP FIRST NUMBER OFF STACK
         MOVE     -*A14,A4,1
	 .endif

starti:  MOVE     A3,A1              ; CHECK 1ST OPERAND = 0
         SLL      1,A1               ; LOSE SIGN BIT
         JRZ      RETSEC             ; RETURN SECOND OPERAND

CHKSEC: 
         MOVE     A5,A2              ; CHECK 2ND OPERAND = 0 
         SLL      1,A2               ; LOSE SIGN BIT
         JRZ      QUIT               ; RETURN FIRST OPERAND

NOZERO:
         MOVE     A3,A1              ; STORE MSB's FOR EXPONENT AND 
         MOVE     A5,A2              ; SIGN MANIPULATION

******************************************************************************
* PUT 1st NUMBER IN REGISTERS A3,A4 RIGHT JUSTIFIED, THEN SHIFTED LEFT 2 BITS
******************************************************************************
         SLL      12,A3
	 .if      .TMS340_IEEE
         SRL      3,A3               ; MSBITS IN BITS 29 - 9 (IEEE)
         ORI      020000000H,A3      ; PUT IMPLICIT ONE IN MANTISSA
	 .else
         SRL      2,A3               ; MSBITS IN BITS 29 - 10 (GSP)
	 .endif

         MOVE     A4,A8
         JRZ      SKIP1
	 .if      .TMS340_IEEE
         SRL      23,A8
	 .else
         SRL      22,A8
	 .endif
         OR       A8,A3              ; ADD IN 9 MSB's from SECOND HALF
	 .if      .TMS340_IEEE
         SLL      9,A4               ; LEFT JUSTIFY 23 LSBITS
	 .else
         SLL      10,A4              ; LEFT JUSTIFY 22 LSBITS
	 .endif

******************************************************************************
* PUT 2ND NUMBER IN REGISTERS A5,A6 RIGHT JUSTIFIED, THEN SHIFTED LEFT 2 BITS
******************************************************************************
SKIP1:
         SLL      12,A5
	 .if      .TMS340_IEEE
         SRL      3,A5               ; MSB's IN BITS 29 - 9 (IEEE)
         ORI      020000000H,A5      ; PUT IMPLICIT ONE IN MANTISSA
	 .else
         SRL      2,A5               ; MSB's IN BITS 29 - 10 (GSP) 
	 .endif

         MOVE     A6,A8
         JRZ      SKIP2
	 .if      .TMS340_IEEE
         SRL      23,A8
	 .else
         SRL      22,A8
	 .endif
         OR       A8,A5              ; ADD IN 9 MSB's from SECOND HALF
	 .if      .TMS340_IEEE
         SLL      9,A6               ; LEFT JUSTIFY 23 LSBITS
	 .else
         SLL      10,A6              ; LEFT JUSTIFY 22 LSBITS
	 .endif

******************************************************************************
* ISOLATE THE SIGN BITS IN A0 AND A8
* ISOLATE EXPONENTS IN A1 AND A2
******************************************************************************
SKIP2:
         SLL      1,A1
         SUBB     A0,A0              ; A0 FILLED WITH SIGN OF 1st #
         SLL      1,A2
         SUBB     A8,A8              ; A8 FILLED WITH SIGN OF 2nd #
         SRL      21,A1              ; RIGHT JUSTIFY 1st EXPONENT
         SRL      21,A2              ; RIGHT JUSTIFY 2nd EXPONENT

*****************************************************************************
* CHECK FOR ERRORS BEFORE ATTEMPTING ANY OPERATIONS
*****************************************************************************
         MOVI     2047,A7
         CMP      A7,A1              ; IS FIRST NUMBER INFINITY
         JRZ      ITEST

         CMP      A7,A2              ; IF SECOND COMPONENT IS INFINITY
         JRZ      INFIN2             ;   RESULT IS INFINITY

******************************************************************************
* HANDLE SETUP OF ADDITION.
******************************************************************************
SETUP:
         SUB      A2,A1              ; SUBTRACT EXPONENTS
         JRZ      EQEXP              ; IF ZERO THEN NO NEED TO SHIFT MANTISSAS
         JRLE     A2BIG              ; IF > 0 THEN A1 EXP IS BIGGER, SO SHIFT
                                     ; 2ND  #'S MANTISSA TO RIGHT -A1 TIMES

A1BIG:
         ADD      A1,A2              ; SINCE A2 WAS SMALLER,ORIGINALLY, ADD BACK
         JRUC     CHECK              ; THE SHIFT COUNT TO A2 = A1 +A2 SO THAT
                                     ; A2 HOLDS THE RESULTANT (LARGER) EXPONENT
EQEXP:
         CMP      A3,A5              ; WHICH MANTISSA IS BIGGEST, WE WANT THE
         JRLT     CHECK              ; BIGGEST ONE IN A3 AND A4
         JRGT     SWITCH

         CMP      A4,A6              ; CHECK SECOND WORD OF MANTISSA
         JRLS     CHECK
         JRUC     SWITCH1            ; SWAP ONLY LSW'S (MSW ARE EQUAL)

A2BIG:                               ; ELSE A2 EXP IS BIGGER, SO SHIFT 1ST #
         NEG      A1                 ; SWAP ORDER OF NUMBERS

******************************************************************************
*  SWAP NUMBERS AROUND SO BIGGER NUMBER IS ALWAYS IN A3 AND A4
******************************************************************************
SWITCH:
         MOVE     A3,A7              ; SWAP MSW OF MANTISSAS
         MOVE     A5,A3
         MOVE     A7,A5

SWITCH1:
         MOVE     A4,A7              ; SWAP LSW OF MANTISSAS
         MOVE     A6,A4
         MOVE     A7,A6

         MOVE     A0,A7              ; SWAP SIGN BITS
         MOVE     A8,A0
         MOVE     A7,A8

*****************************************************************************
* SHIFT MANTISSAS SO THAT THEY ARE NORMALIZED TO SAME AMOUNT
*****************************************************************************
CHECK:
         MOVE     A1,A1              ; DO SHIFT IF A1 != 0    (CMPI  0,A1)
         JRZ      SGNTST

SHIFT:
         CMPI     30,A1              ; IS SHIFT COUNT MORE THAN 30
         JRLT     LT30               ; NOT ALL TOP 30 BITS WILL GO TO A6

         CMPI     61,A1              ; IF SHIFT COUNT IS > 61 THEN ALL THE
         JRGT     GT61               ;     MATISSA IS CLEARED

GE30:
         SUBK     30,A1              ; HOW MUCH SHIFT BEYOND 30
         SLL      2,A5               ; TOP 30 BITS ARE ZERO NOW
         SRL      30,A6              ; SHIFT BOTTOM BITS AT LEAST 30 TIMES
         OR       A5,A6              ; PUT 30 MSBS IN A6
         CLR      A5                 ; TOP 30 BITS OF END RESULT ARE 0
         NEG      A1
         SRL      A1,A6              ; SHIFT OFF THE REMAINING A1 BITS
         JRUC     SGNTST

GT61:
         CLR      A5                 ; MANTISSA IS ZEROED OUT
         CLR      A6
         JRUC     SGNTST

LT30:
         MOVE     A5,A7              ; MAKE COPY OF TOP 30 BITS (BEFORE SHIFT)
         NEG      A1
         SRL      A1,A5              ; SHIFT THE TOP 30 BITS RIGHT A1 BITS
         SRL      A1,A6              ; SHIFT THE BOT 22 BITS RIGHT A1 BITS
         ADDK     32,A1              ;
         SLL      A1,A7              ; CLR OUT ALL BUT LOW A1 BITS OF THE TOP 30
         OR       A7,A6              ; PUT THOSE A1 BITS IN WITH THE 22 LSB'S
                                     ; OF THE RESULT

*******************************************************************************
* DETERMINE WHETHER AN ADD OR SUBTRACT MUST BE USED
*******************************************************************************
SGNTST:
         CMP      A0,A8              ; DO WE NEED TO SUBTRACT OR ADD
         JRZ      ADD                ; IF SIGNS ARE ALIKE WE ADD

*******************************************************************************
* IF SIGN BITS ARE DIFFERENT, PERFORM A SUBTRACT
*******************************************************************************
SUB:
         SUB      A6,A4              ; SUBTRACT SMALLER NUMBER FROM THE LARGER
         SUBB     A5,A3              ; NUMBER , RESULT IS IN A3 AND A4

NORM:
         LMO      A3,A7              ; GET 1'S COMPLEMENT OF LEFT MOST 1 BIT #
         JRZ      TSTLSB             ; NO ONES IN TOP SO TEST BOTTOM
         SUBK     2,A7               ; A7 NOW HOLDS THE NUMBER OF BITS TO SHIFT
;                                      LEFT FOR NORMALIZING TO BIT 29 (NOT 31)
         JRZ      RNDTST
         SUB      A7,A2              ; ADJUST THE EXPONENT ACCORDINGLY

         SLL      A7,A3              ; NORMALIZE A3
         MOVE     A4,A1              ; MAKE COPY OF A4 IN A1 (NO LONGER NEED A1
;                                      AS SHIFT COUNT)
         SLL      A7,A4              ; A4 IS NOW AS IT SHOULD BE ,
         SUBK     32,A7              ; A7 NOW HOLDS - #BITS OF A1 THAT ARE NOT
;                                      TO BE MOVED TO A3
         SRL      A7,A1              ; PUT THE BITS TO BE MOVED TO A3 IN BOT A1
         OR       A1,A3              ; PUT THEM IN A3
         JRUC     RNDTST

TSTLSB:
         LMO      A4,A7              ; GET 1'S COMPLEMENT OF LEFT MOST 1 BIT #
         JRZ      ZERO               ; NO ONES IN THE MANTISSA AT ALL
         SUBK     30,A2              ; ADJUST EXPONENT SINCE SHIFT IS AT LEAST
;                                      30
         RL       A7,A4              ; NORMALIZE A4
         MOVE     A4,A3              ; MAKE COPY OF A4
         SRL      2,A3               ; ONLY WANT 30 MSBS' IN A3
         SLL      30,A4              ; LEFT JUSTIFY THE REMAINING 2  BITS IN A4
         SUB      A7,A2              ; DECREMENT EXPONENT BY NUMBER OF SHIFTS

*******************************************************************************
* PERFORM ROUNDING, IF NEEDED.
*******************************************************************************
RNDTST:
         CLR      A7
	 .if      .TMS340_IEEE
         BTST     8,A4               ; SHOULD WE ROUND, NOTE THAT THERE IS
         JRZ      NOVRFL             ; NEVER AN OVERFLOW BEFORE ROUNDING IN SUB.
         ADDI     IRNDMSK,A4          ; WE ARE ROUNDING UP SO ADD 1 (TO BIT #9)
         ADDC     A7,A3

OVRTST:
         BTST     30,A3              ; WAS THERE AN OVERFLOW
         JRZ      NOVRFL             ; IF NOT CHECK EXPONENT FOR POSS. ERRORS
         ADDK     1,A2               ; ELSE ADJUST THE EXPONENT ACCORDINGLY
         JRUC     MASK               ;

NOVRFL:
         SLL      1,A3               ; NORMALIZE MANTISSA TO IEEE
         SLL      1,A4
         ADDC     A7,A3              ; PUT MSB OF A4 IN BOT A3

MASK:
         ANDI     03FFFFFFFH,A3      ; MASK IMPLICIT ONE
         JRUC     EXPCHK             ; CHECK FOR ERRORS SINCE NO FURTHER
;                                      ROUNDING SHALL BE REQUIRED AS
;                                      1 + # = OVERFLOW MEANS BIT #0 = 0
	 .else
	 BTST     9,A4               ; GSP, SHOULD WE ROUND?
	 JRZ      EXPCHK         
	 ADDI     GRNDMSK,A4         ; ROUNDING UP,ADD ONE TO BIT #10
	 ADDC     A7,A3         
OVRTST:
	 BTST     30,A3              ; OVERFLOW?
	 JRZ      EXPCHK             ; NO OVERFLOW CHECK EXPONENT FOR ERRORS
	 ADDK     1,A2               ; OVERFLOW, ADJUST EXPONENT
	 SRL      1,A4               ; ADJUST MANTISSA
	 SRL      1,A3               ; MANTISSA IS ONLY 52 BITS
	 JRNC     EXPCHK             ; GO CHECK FOR ERRORS
	 ORI      ONEIN,A4
	 JRUC     EXPCHK             ; NO FURTHER ROUNDING REQUIRED
	 .endif

*******************************************************************************
* IF SIGN BITS ARE THE SAME,  PERFORM AN ADDITION
*******************************************************************************
ADD:
         ADD      A6,A4
         ADDC     A5,A3

         BTST     30,A3              ; WAS THERE AN OVERFLOW
         JRZ      RNDTST
         ADDK     1,A2               ; ADJUST THE EXPONENT ACCORDINGLY
         SRL      1,A4               ; IF YES THEN ADJUST MANTISSA
         SRL      1,A3               ; MANTISSA IS ONLY 52 BITS
         JRNC     RNDTST
         ORI      ONEIN,A4
         JRUC     RNDTST             ; DO WE NEED TO ROUND AFTER ADJUSTING FOR

***************************************************************************
* CHECK THE RESULT EXPONENT
***************************************************************************
EXPCHK:
         MOVE     A2,A2              ; CMPI  0,A2
         JRLT     ERR12              ; IF A2 < 0 THEN THERE IS AN UNDERFLOW
         JRNZ     OK

         MOVE     A3,A3              ; IF A2 = 0, IS MANTISSA ZERO?
         JRNZ     ERR12
         MOVE     A4,A4              ; CHECK LSB'S IF MSB'S OF MANTISSA ARE ZERO
         JRNZ     ERR12
         JRUC     ZERO
OK:
         CMPI     2047,A2
         JRGE     ERR5               ; IF A2 >=2047 THEN THERE WAS AN OVERFLOW

***************************************************************************
* BUILD RESULT AND PUSH ONTO STACK
***************************************************************************
FINI:
         MOVE     A3,A8              ; RIGHT JUSTIFY MANTISSA IN REG PAIR
         SRL      10,A3
         SRL      10,A4
         SLL      22,A8
         OR       A8,A4
         SLL      31,A0              ; ADD IN SIGN BIT ...
         SLL      20,A2              ;         ... AND EXPONENT
         OR       A2,A3
         OR       A0,A3
QUIT:
	 .if      .TMS340_IEEE
         MOVE     A3,*A14+,1
         MOVE     A4,*A14+,1         ; AND PUSH RESULT ONTO STACK
	 .else
         MOVE     A4,*A14+,1         ; AND PUSH RESULT ONTO STACK
         MOVE     A3,*A14+,1
	 .endif

DONE:
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7
         RETS


***************************************************************************
* HANDLE SPECIAL CASES
***************************************************************************
ZERO:
         CLR      A3                 ; CLEAR THE EXPONENT THE ANSWER IS ZERO
         CLR      A4                 ; CLEAR SIGN BIT TOO
         JRUC     QUIT               ; WE ARE FINISHED

RETSEC:
         MOVE     A5,A3              ; RETURN SECOND OPERAND, FIRST = 0
         MOVE     A6,A4
         JRUC     QUIT

ITEST:
         CMP      A7,A2              ; IS SECOND NUMBER INFINITY
         JRNZ     INFIN              ; IF NOT THEN CARRY ON
         CMP      A0,A8              ; DO WE HAVE INFIN - INFIN ? ...
         JRNZ     ERR4               ;    IF SO, INDICATE THAT ERROR
         JRUC     INFIN              ;    ELSE INFINITY ERROR

INFIN2:
         MOVE     A8,A0              ; SAVE SIGN BIT OF SECOND NUMBER

INFIN:
         CLR      A1
         SLL      31,A0              ; PUT IN RESULT SIGN BIT
         ORI      FINITY,A0

	 .if      .TMS340_IEEE
         MOVE     A0,*A14+,1         ; PUSH INFINITY ONTO STACK
         MOVE     A1,*A14+,1
	 .else
         MOVE     A1,*A14+,1
         MOVE     A0,*A14+,1         ; PUSH INFINITY ONTO STACK
	 .endif
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7
         RETS

***************************************************************************
* HANDLE ERRORS   (PUT ERROR CODE IN A0, RESULT IN A3, CALL ERROR FUNCTION)
***************************************************************************
FINITY   .set     07FF00000h

ERR4:                                ; "INFINITY - INFINITY"
         CLR      A3                 ; DEFAULT RESULT IS ZERO
         MOVK     4,A0
         JR       CALLERROR

ERR5:                                ; "OVERFLOW"
	 MOVE     A0,A3
         SLL      31,A3              ; DEFAULT RESULT IS +/- INFINITY
         ORI      FINITY,A3
         MOVK     5,A0               ; PUT ERROR CODE IN A7
         JR       CALLERROR          ;

ERR12:                               ; "UNDERFLOW"
         MOVK     12,A0
         CLR      A3                 ; DEFAULT RESULT IS ZERO

CALLERROR:
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

         CLR      A1
	 .if      .TMS340_IEEE
         MOVE     A3,*A14+,1 
         MOVE     A1,*A14+,1         ; AND PUSH RESULT ONTO STACK
	 .else
         MOVE     A1,*A14+,1         ; AND PUSH RESULT ONTO STACK
         MOVE     A3,*A14+,1
	 .endif
         MMFM     SP,A0,A1,A2,A3,A4,A5,A6,A7
         RETS
         .end
