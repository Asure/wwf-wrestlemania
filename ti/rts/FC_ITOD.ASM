*******************************************************************************
*  FD$ITOD     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*                              
*  This module converts signed and unsigned integers to double precision
*  IEEE floating point numbers.  The input is passed in register A8, and the
*  result is pushed on the stack.
*
*******************************************************************************

         .globl   FD$ITOD           ; CONVERT SIGNED NUMBER

FD$ITOD:
         MOVE     A12,-*SP,1        ; STORE USED REGISTERS
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A12,1
         JRZ      EMULATE

*******************************************************************************
*  34082
*******************************************************************************
         MOVE     A8,RA0            ; GET INTEGER AND DO CONVERSION
         CVID     RA0,RA0    
         MOVD     RA0,*A14+         ; PUSH RESULT ON STACK

         MOVE     *SP+,A12,1
         RETS
	 .endif

*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
* IF NUMBER IS A SIGNED INTEGER, IF NEGATIVE, REVERSE SIGN, SAVE OFF SIGN BIT
*******************************************************************************
EMULATE:
         MMTM     SP,A0,A1
         CLR      A0                 ; ASSUME A SIGN BIT OF ZERO 
         ABS      A8                 ; (NOTE STATUS IS SET STRANGELY!!!!) 
         JRZ      ZERO               ; IF INTEGER IS ZERO THEN WE ARE DONE
         JRLT     POSINT             ; IF INTEGER WAS POSITIVE, JUMP

         MOVK     1,A0
         SLL      31,A0              ; BIT 31 OF A0 CONTAINS SIGN BIT

*******************************************************************************
* NORMALIZE INTEGER, AND BUILD EXPONENT.
*******************************************************************************
POSINT:
         LMO      A8,A1
	 .if      .TMS340_IEEE
         ADDK     1,A1               ; ACCOUNT FOR IMPLICIT ONE IN IEEE
         CMPI     32,A1              ; IN IEEE, MAY NEED TO SHIFT 32 TIMES
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
         ADDI     1055,A1            ; 1023 + 32 - A0 IS THE EXPONENT
         SLL      20,A1
         OR       A1,A0              ; PUT EXPONENT IN PLACE IN A0

*******************************************************************************
* SPLIT MANTISSA UP INTO THE TWO RESULT REGISTERS
*******************************************************************************
         MOVE     A8,A1
         SLL      20,A1              ; CREATE LSR OF DOUBLE NUMBER
         SRL      12,A8
         OR       A8,A0              ; OR IN MSB OF MANTISSA

*******************************************************************************
* PUSH RESULT ON STACK AND RETURN
*******************************************************************************
	 .if      .TMS340_IEEE
         MOVE     A0,*A14+,1         ; IEEE RESULT
         MOVE     A1,*A14+,1
	 .else
         MOVE     A1,*A14+,1         ; GSP RESULT
         MOVE     A0,*A14+,1
	 .endif
         MMFM     SP,A0,A1           ; RESTORE REGISTERS
         MOVE     *SP+,A12,1
         RETS

*******************************************************************************
* HANDLE SPECIAL CASE OF ZERO
*******************************************************************************
ZERO:
         CLR      A0
         MOVE     A0,*A14+,1
         MOVE     A0,*A14+,1
         MMFM     SP,A0,A1           ; RESTORE REGISTERS
         MOVE     *SP+,A12,1
         RETS

         .end
