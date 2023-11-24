*******************************************************************************
*  FD$EQ     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function compares two double precision numbers to see if they are equal
*  popping two inputs off the stack and returning the result (true or false) in
*  register A8.
*
*******************************************************************************

        .globl  FD$EQ 

*********************************************************************
* REGISTER USAGE
*    A0     - Contains RHS operand of the compare
*    A2     - Contains LHS operand
*********************************************************************
FD$EQ:
         MMTM     SP,A0,A1,A2
	 .if      .TMS340_IEEE
         MOVE     -*A14,A0,1              ; POP RHS OFF STACK
         MOVE     -*A14,A8,1
         MOVE     -*A14,A1,1              ; POP LHS OFF STACK
         MOVE     -*A14,A2,1  
	 .else
         MOVE     -*A14,A8,1              ; POP RHS OFF STACK
         MOVE     -*A14,A0,1
         MOVE     -*A14,A2,1              ; POP LHS OFF STACK
         MOVE     -*A14,A1,1  
	 .endif

***************************************************************************
* CHECK FOR EQUALITY
***************************************************************************
         CMP      A8,A2                   ; COMPARE MSW'S
         JRNZ     EQ_DONEFAST             ; IF UNEQUAL, WE ARE DONE
         CLR      A8
         CMP      A0,A1                   ; COMPARE LSW'S
         JRNZ     EQ_DONE
         ADDK     1,A8
EQ_DONE:
         MOVE     A8,A8                   ; NOTE : MUST SET STATUS
         MMFM     SP,A0,A1,A2
         RETS

EQ_DONEFAST:                              ; IF FIRST WORDS WERE UNEQUAL
         CLR      A8
         MMFM     SP,A0,A1,A2
         RETS

         .end
