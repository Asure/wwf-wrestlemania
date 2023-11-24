*******************************************************************************
*  FD$FTOD     v6.10 
*  Copyright (c) 1991  Texas Instruments Incorporated
*                                                                        
*  This function converts a single precision floating point number to a 
*  double precision number.  The single is popped and the double is pushed.
*                                                                         
*******************************************************************************

         .globl   FD$FTOD

FD$FTOD:
	 .if      .TMS340_IEEE & .TMS34020
         .ref     __present82
         MOVE     @__present82,A8,1
         JRZ      EMULATE

*******************************************************************************
*  34082
*******************************************************************************
         MOVF     *-A14,RA0     ; POP OPERAND FROM STACK 
         CVFD     RA0,RA0       ; CONVERT
         MOVD     RA0,*A14+     ; PUSH RESULT

         RETS
	 .endif

EMULATE:
*******************************************************************************
*  IEEE/GSP EMULATION 
*******************************************************************************
         MMTM     SP,A0,A1
         MOVE     -*A14,A8,1         ; PUT SINGLE PRECISION NUMBER IN A8

********************************************************************************
* ISOLATE SIGN BIT AND EXPONENT, CHECK FOR ZERO.
********************************************************************************
         MOVE     A8,A1
         SLL      1,A1               ; SHIFT SIGN BIT INTO CARRY
         SUBB     A0,A0              ; FILL A0 WITH SIGN BIT
         SRL      24,A1              ; SHIFT EXPONENT TO LSB's...
         JRZ      ZERO               ; ...IF RESULT IS ZERO, QUIT NOW
         SLL      31,A0              ; MSB OF A0 contains SIGN BIT

********************************************************************************
* CONVERT EXPONENT FROM SINGLE TO DOUBLE, CHECK FOR INFINITY
********************************************************************************
         CMPI     255,A1             ; CHECK FOR INFINITY
         JRNZ     NOT_INFIN
         MOVI     047FH,A1
NOT_INFIN:
         ADDI     896,A1             ; CONVERT TO DOUBLE BIAS (b - 127 + 1023)
         SLL      20,A1
         OR       A1,A0              ; PLACE EXPONENT INTO RESULT MSR

********************************************************************************
* PLACE EXPONENT INTO RESULT REGISTERS
********************************************************************************
         MOVE     A8,A1
         SLL      29,A1              ; ISOLATE 3 LSB's IN A1
         SLL      9,A8               ; STRIP OFF EXPONENT FROM A8
         SRL      12,A8              ; ISOLATE 20 MSB's IN A8
         OR       A8,A0              ; PLACE MSB's OF MANTISSA IN MSR

********************************************************************************
*  PUSH RESULTS ON THE RETURN STACK AND RETURN
********************************************************************************
DONE:
	 .if      .TMS340_IEEE
         MOVE     A0,*A14+,1         ; PUSH IEEE RESULT ONTO STACK
         MOVE     A1,*A14+,1
	 .else
         MOVE     A1,*A14+,1         ; PUSH GSP RESULT ONTO STACK
         MOVE     A0,*A14+,1
	 .endif

         MMFM     SP,A0,A1
         RETS

ZERO:
         MOVE     A1,*A14+,1         ; PUSH ZERO ONTO THE STACK.
         MOVE     A1,*A14+,1
         MMFM     SP,A0,A1
         RETS
         .end
