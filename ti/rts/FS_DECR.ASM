*******************************************************************************
*  FS$DECR     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function is passed an address of a value in memory to be decremented.
*  FS$DEC decrements the value and returns.  FS$DECR pushes the predecremented
*  value onto the stack, then does the decrement. 
*
*******************************************************************************

         .globl   FS$DECR, FS$DEC
	 .globl   FS$DECRX, FS$DECX
         .globl   FS$ADD

	 .if      .TMS340_IEEE
MONE     .set     0BF800000h
	 .else
MONE     .set     0C0400000h
	 .endif

FS$DEC:  MOVE     A9,*-SP,1
	 MOVE     A8,A9
	 JR       push

FS$DECR:
         MOVE     A9,*-SP,1          ; SAVE A9 ON STACK
	 MOVE     A8,A9
	 MOVE     *A8+,*A14+,1       ; PUSH RETURN VALUE ON STACK
push:
	 MOVE     *A9+,*A14+,1       ; PUSH COPY TO BE DECREMENTED

         MOVI     MONE,A8            ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
         CALLA    FS$ADD             ; ADD ONE TO ARGUMENT

	 MOVE     *-A14,*-A9,1       ; PERFORM ASSIGNMENT

	 MOVE     *SP+,A9,1
	 RETS   

*****************************************************************************
* These entry points take values from A8, and return the result in A8
*****************************************************************************
FS$DECRX:MOVE     A8,*A14+,1
FS$DECX: MOVE     A8,*A14+,1

         MOVI     MONE,A8            ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
         CALLA    FS$ADD             ; ADD ONE TO ARGUMENT
	 MOVE     *-A14,A8,1         ; RETURN RESULT        
	 RETS

