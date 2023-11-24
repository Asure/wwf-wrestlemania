*******************************************************************************
*  FD$UTOF    v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*                              
*  This module converts signed and unsigned integers to single precision
*  IEEE floating point numbers.  The input is passed in register A8, and the
*  result is pushed on the stack.
*
*******************************************************************************

         .globl   FD$UTOF           ; CONVERT UNSIGNED NUMBER

	 .even	  32
FSMSB:   .float   4294967296.0 

FD$UTOF:
         MOVE     A12,-*SP,1        ; STORE USED REGISTERS
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A12,1
         JRZ      EMULATE

*******************************************************************************
*  34082
*******************************************************************************
         MOVE     A8,RA0            ; MOVE UNSIGNED INT TO '82 REG
         CVIF     RA0,RA0           ; DO SIGNED CONVERT
	 CLRF     RB0
	 CMPF     RA0,RB0           ; SET STATUS
         GETCST
         JRNN     SKIP              ; UNSIGNED INT < 2**31

         MOVI     FSMSB,A12         ; PUT 2**32 IN '82 REG 
         MOVF     *A12+,RB0 
         ADDF     RA0,RB0,RA0       ; ADD 2**32 TO NEG NUMBER

SKIP:
         MOVF     RA0,*A14+         ; PUSH RESULT

         MOVE     *SP+,A12,1
         RETS
	 .endif
    
*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
* FOR UNSIGNED NUMBERS, ASSUME INTEGER IS ALWAYS POSITIVE
*******************************************************************************
EMULATE:
         MMTM     SP,A0,A1
         CLR      A0                 ; FOR UNSIGNED, SIGN BIT IS ALWAYS ZERO
         MOVE     A8,A8
         JRZ      DONE               ; IF INTEGER IS ZERO THEN WE ARE DONE

******************************************************************************
* NORMALIZE NUMBER, HANDLE ROUNDING.
******************************************************************************
POSINT:
         LMO      A8,A1              ; FIND LEFTMOST ONE
	 .if      .TMS340_IEEE
         ADDK     1,A1               ; SHIFT IMPLICIT ONE OUT OF IEEE MANTISSA
         CMPI     32,A1              ; MAY NEED TO SHIFT 32 TIMES IN IEEE
         JRNZ     REGSHFT

         CLR      A8                 ; IF 32 BIT SHIFT, CLEAR REGISTER
         JRUC     CONTIN

REGSHFT:
         SLL      A1,A8              ; NORMALIZE IEEE MANTISSA
	 .else
	 RL       A1,A8              ; NORMALIZE GSP MANTISSA
	 .endif
CONTIN:
         NEG      A1
         SRL      9,A8               ; ROUND MANTISSA TO 23 BITS
         JRNC     NORND              ; IF NO ROUNDING NEEDED, CONTINUE

         ADDK     1,A8               ; ROUND UP THE MANTISSA
         BTST     23,A8              ; WAS THERE AN OVERFLOW
         JRZ      NORND              ; IF OVERFLOW DURING ROUND, RENORMALIZE

         ADDK     1,A1               ; PUT EXPONENT ADJUSTMENT IN A1
         SRL      1,A8               ; ADJUST THE MANTISSA TO 23 BITS

******************************************************************************
* ADD BIAS TO EXPONENT, AND BUILD RESULT IN A0
******************************************************************************
NORND:
         ADDI     159,A1             ; 127 + 32 - A0 IS THE EXPONENT
         SLL      23,A1              ; SHIFT EXPONENT INTO PLACE
         OR       A1,A0              ; OR IN EXPONENT
         OR       A8,A0              ; OR IN MANTISSA

DONE:
         MOVE     A0,*A14+,1
         MMFM     SP,A0,A1
         MOVE     *SP+,A12,1
         RETS

         .end
