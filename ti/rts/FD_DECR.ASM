*******************************************************************************
*  FD$DECR     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function is passed an address of a value in memory to be incremented.
*  FD$DEC decrements the value and returns.  FD$DECR pushes the predecremented
*  value onto the stack, then does the decrement. 
*
*******************************************************************************

         .globl   FD$DECR, FD$DEC
         .globl   FD$ADD

	 .if      .TMS340_IEEE
MONE     .set     0BFF00000h
	 .else
MONE     .set     0C0080000h
	 .endif

FD$DEC:  MOVE     A9,*-SP,1
	 MOVE     A8,A9
	 JR       push

FD$DECR:
         MMTM     SP,A9
	 MOVE     A8,A9
	 MOVE     *A8+,*A14+,1
	 MOVE     *A8+,*A14+,1       ; PUSH RETURN VALUE ON STACK
push:
	 MOVE     *A9+,*A14+,1
	 MOVE     *A9+,*A14+,1       ; PUSH COPY TO BE DECREMENTED

	 .if      .TMS340_IEEE
         MOVI     MONE,A8            ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
         CLR      A8    
         MOVE     A8,*A14+,1
	 .else
         CLR      A8    
         MOVE     A8,*A14+,1
         MOVI     MONE,A8            ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
	 .endif
         CALLA    FD$ADD             ; ADD ONE TO ARGUMENT

	 MOVE     *-A14,*-A9,1
	 MOVE     *-A14,*-A9,1       ; PERFORM ASSIGNMENT

	 MOVE     *SP+,A9,1
	 RETS   
         .end
