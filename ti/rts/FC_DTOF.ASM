*******************************************************************************
*  FD$DTOF     v6.10     
*  Copyright (c) 1991  Texas Instruments Incorporated
*                                                                           
*  This function converts a double precision floating point number to     
*  a single precision number.  The double is popped off the stack and     
*  the result is pushed.                                                 
*                                                                       
*******************************************************************************     
         .globl   FD$DTOF
         .globl   _fp_error

FD$DTOF:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMULATE

         MOVE     A14,A8        ; POP OPERAND OFF STACK
         SUBI     64,A8
         MOVD     *A8+,RA0
         SUBI     64,A14

         CVDF     RA0,RA0       ; CONVERT
         MOVF     RA0,*A14+     ; PUSH RESULT
         RETS
	 .endif

*******************************************************************************
* IEEE/GSP EMULATION                                                 
*******************************************************************************     
EMULATE:

***********************************************************************
*     DEFINE CONSTANTS
***********************************************************************
INFI     .set     07F800000h

***********************************************************************
* REGISTER USAGE
*
*    A0 is used to calculate the new exponent
*    A3 is used to calculate the new mantissa
*    A8 is used to hold the sign bit
***********************************************************************

         MMTM     SP,A0,A3           ; SAVE REGISTERS LISTED

	 .if      .TMS340_IEEE == 0
         MOVE     *-A14,A0,1         ; PUT MSB DOUBLE PRECISION NUMBER IN A0
	 .endif

         MOVE     *-A14,A3,1         ; PUT 32 BITS OF MANTISSA IN A3
         SRL      20,A3

	 .if      .TMS340_IEEE
         MOVE     *-A14,A0,1         ; PUT MSB DOUBLE PRECISION NUMBER IN A0
	 .endif

         MOVE     A0,A8              ; SAVE OFF 20 BITS OF MANTISSA
         SLL      12,A8
         OR       A8,A3 

***********************************************************************
* ISOLATE EXPONENT AND SIGN BIT INTO SEPARATE REGISTERS.
***********************************************************************
         SLL      1,A0               ; **  MOVE SIGN BIT INTO CARRY
         SUBB     A8,A8
         SLL      31,A8              ; **  MSB OF A8 = SIGN BIT
         SRL      21,A0              ; **  RIGHT JUSTIFY EXPONENT

***********************************************************************
* CHECK EXPONENT FOR INFINITY OR ZERO
***********************************************************************
         JRZ      STKEND             ; JUMP IF EXPONENT IS ZERO
         CMPI     2047,A0            ; IS NUMBER INFINITY
         JRZ      INFIN

***********************************************************************
* CONVERT PRECISION OF MANTISSA AND HANDLE ROUNDING
***********************************************************************
         SRL      9,A3               ; CUT MANTISSA TO 23 BITS
         JRNC     EXPCHK             ; IF ROUNDING NOT NEEDED, JUMP
         ADDK     1,A3               ; ROUND UP
         BTST     23,A3              ; DID ROUND CAUSE OVERFLOW
         JRZ      EXPCHK             ;
       
	 .if      .TMS340_IEEE
         ANDI     07FFFFFh,A3        ; MASK OVERFLOW, IMPLICIT ONE
	 .endif                      ; MAKES BIT 23 = 0

         SRL      1,A3               ; OVERFLOW, ADJUST MANTISSA AND EXP.
         ADDK     1,A0               ;

***********************************************************************
* CONVERT EXPONENT TO SINGLE BIAS
***********************************************************************
EXPCHK:
         SUBI     896,A0             ; ADJUST EXPONENT TO SINGLE FORMAT
         JRGT     CHKMOR             ;
         CLR      A0                 ; ANSWER IS ZERO
         JRUC     STKEND

CHKMOR:
         CMPI     255,A0             ; WAS THERE AN OVERFLOW
         JRGE     OVERFLOW           ; NO OVERFLOW THEN PUT RESULT ON STACK

***********************************************************************
* BUILD UP RESULT FROM COMPONENTS AND RETURN
***********************************************************************
STK:
         SLL      23,A0              ; GENERATE RESULT
         OR       A3,A0              ; GET MANTISSA W/ EXP.
         OR       A8,A0              ; ADD SIGN

STKEND:
         MOVE     A0,*A14+,1         ; PUT RESULT ON STACK
         MMFM     SP,A0,A3           ; RESTORE REGISTERS
         RETS

***********************************************************************
* HANDLE CONVERSION ERRORS
***********************************************************************
OVERFLOW:
         MOVE     A8,A3              ; SAVE SIGN BIT
         MOVK     2,A0
	 .if      .TMS340_MEMPARM
         MOVE     A14,-*SP,1         ; ** CALL C FP ERROR HANDLING ROUTINE **
         MOVE     A0,*A14+,1         ; PUT ERROR CODE ON STACK
	 .endif
         CALLA    _fp_error

INFIN:
         ORI      INFI,A3            ; ANSWER IS INFINTY
         MOVE     A3,*A14+,1         ; PUT RESULT ON STACK
         MMFM     SP,A0,A3           ; RESTORE REGISTERS
         RETS

         .end
