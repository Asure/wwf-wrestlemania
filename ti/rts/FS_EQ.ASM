*******************************************************************************
*  FS$EQ     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function compares two single precision numbers.  A result (true or
*  false) is returned in register A8, and the two numbers are consumed from 
*  the stack.
*
*******************************************************************************

        .globl   FS$EQ

*********************************************************************
* REGISTER USAGE
*    A0, A8 - Contains operands to be compared.
*********************************************************************
FS$EQ:
         MOVE     A0,*-SP,1
         MOVE     -*A14,A0,1              ; POP RHS OFF STACK
         MOVE     -*A14,A8,1              ; POP LHS OFF STACK

***************************************************************************
* CHECK FOR EQUALITY
***************************************************************************
         CMP      A0,A8                   ; COMPARE MSW'S
         MOVK     1,A8
         JRZ      EQ_DONE
         CLR      A8
EQ_DONE:
         MOVE     *SP+,A0,1
         MOVE     A8,A8                   ; NOTE : MUST SET STATUS
         RETS

         .end
