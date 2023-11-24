*******************************************************************************
*  FD$NE     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function compares two double precision floating point numbers for
*  inequality.  A result(true or false) is returned in register A8 and
*  two numbers are consumed from the stack.
*
*******************************************************************************

        .globl  FD$NE 

*********************************************************************
* REGISTER USAGE
*    A0, A2 - Contains RHS operand of the compare
*    A4, A3 - Contains LHS operand
*********************************************************************
FD$NE:
         MMTM     SP,A0,A2,A3,A4
	 .if      .TMS340_IEEE
         MOVE     -*A14,A2,1              ; POP RHS OFF STACK
         MOVE     -*A14,A0,1
         MOVE     -*A14,A3,1              ; POP LHS OFF STACK
         MOVE     -*A14,A4,1          
	 .else
         MOVE     -*A14,A0,1              ; POP RHS OFF STACK
         MOVE     -*A14,A2,1
         MOVE     -*A14,A4,1              ; POP LHS OFF STACK
         MOVE     -*A14,A3,1          
	 .endif

***************************************************************************
* CHECK FOR INEQUALITY
***************************************************************************
         CLR      A8
         CMP      A0,A4                   ; COMPARE MSW'S
         JRNZ     NEQ_DONEFAST            ; IF UNEQUAL, WE ARE DONE
         CMP      A2,A3                   ; COMPARE LSW'S
         JRZ      NEQ_DONE
         ADDK     1,A8
NEQ_DONE:
         MMFM     SP,A0,A2,A3,A4          ; NOTE : STATUS IS ALREADY SET
         RETS

NEQ_DONEFAST:
         ADDK     1,A8                    ; SET RETURN VALUE (AND STATUS)
         MMFM     SP,A0,A2,A3,A4
         RETS

         .end
