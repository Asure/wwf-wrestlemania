***********************************************************************
*   FS$GT    v6.10
*   Copyright (c) 1991  Texas Instruments Incorporated
*                                                    
*   This function compares  two single precision numbers. 
*   (TRUE or FALSE) is returned in A8, and the two numbers are
*   popped off the stack.                                    
*                                                           
***********************************************************************

        .globl   FS$GT

*********************************************************************
* REGISTER USAGE
*    A0, A8 - Contains operands to be compared.
*********************************************************************
FS$GT:
	 MOVE     A0,*-SP,1
         MOVE     -*A14,A0,1              ; POP RHS OFF STACK
         MOVE     -*A14,A8,1              ; POP LHS OFF STACK

         BTST     31,A0                   ; RHS NEGATIVE?
         JRZ      COMPARE                 ; RHS POSITIVE
         BTST     31,A8                   ; LHS NEGATIVE?
         JRZ      COMPARE                 ; LHS POSITIVE

***************************************************************************
* BOTH ARGUMENTS ARE NEGATIVE, PUT DIFFERENCE IN A0
***************************************************************************

         SUB	  A8,A0                   ; BASE COMPARE
	 CLR	  A8                      ; ON (0 - (RHS - LHS))
	 NEG      A0                      ; NOT 2's COMP. OPERANDS
         
***************************************************************************
* CHECK FOR GREATER THAN
***************************************************************************
COMPARE:
         CMP      A0,A8                   ; SET STATUS
         MOVK     1,A8
         JRGT     GT_DONE                 ; LHS > RHS
         CLR      A8                      ; LHS <= RHS

GT_DONE:
	 MOVE     *SP+,A0,1
         MOVE     A8,A8                   ; NOTE : MUST SET STATUS
         RETS

	 .end

