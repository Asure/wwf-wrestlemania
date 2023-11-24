*******************************************************************************
*  FS$NE     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function compares the top two numbers on the stack for inequality and 
*  returns a result in register A8.  Two numbers are comsumed from the stack.
*
*******************************************************************************

        .globl   FS$NE

*********************************************************************
* REGISTER USAGE
*    A0, A8 - Contains operands to be compared.
*********************************************************************
FS$NE:
         MOVE     A0,*-SP,1
         MOVE     -*A14,A0,1              ; POP RHS OFF STACK
         MOVE     -*A14,A8,1              ; POP LHS OFF STACK

***************************************************************************
* CHECK FOR INEQUALITY
***************************************************************************
         CMP      A0,A8                   ; COMPARE MSW'S
         MOVK     1,A8
         JRNZ     NE_DONE
         CLR      A8
NE_DONE:
         MOVE     *SP+,A0,1
         MOVE     A8,A8                   ; SET STATUS
         RETS

         .end
