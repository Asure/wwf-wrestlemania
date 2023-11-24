*******************************************************************************
*  FD$INCR     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function is passed an address of a value in memory to be incremented.
*  FD$INC increments the value and returns.  FD$INCR pushes the preincremented
*  value onto the stack, then does the increment. 
*
*******************************************************************************

         .globl   FD$INCR, FD$INC
         .globl   FD$ADD

	 .if      .TMS340_IEEE
ONE      .set     03FF00000h
	 .else
ONE      .set     040080000h
	 .endif

FD$INC:  MOVE     A9,*-SP,1
	 MOVE     A8,A9
	 JR       push

FD$INCR:
         MOVE     A9,*-SP,1
	 MOVE     A8,A9
	 MOVE     *A8+,*A14+,1
	 MOVE     *A8+,*A14+,1       ; PUSH RETURN VALUE ON STACK
push:
	 MOVE     *A9+,*A14+,1
	 MOVE     *A9+,*A14+,1       ; PUSH COPY TO BE INCREMENTED

	 .if      .TMS340_IEEE
         MOVI     ONE,A8             ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
         CLR      A8    
         MOVE     A8,*A14+,1
	 .else
         CLR      A8    
         MOVE     A8,*A14+,1
         MOVI     ONE,A8             ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
	 .endif
         CALLA    FD$ADD             ; ADD ONE TO ARGUMENT

	 MOVE     *-A14,*-A9,1
	 MOVE     *-A14,*-A9,1       ; PERFORM ASSIGNMENT

	 MOVE     *SP+,A9,1
	 RETS   
         .end
