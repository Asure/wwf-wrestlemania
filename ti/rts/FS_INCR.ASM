*******************************************************************************
*  FS$INCR     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function is passed an address of a value in memory to be incremented.
*  FS$INC increments the value and returns.  FS$INCR pushes the preincremented
*  value onto the stack, then does the increment. 
*
*******************************************************************************

         .globl   FS$INCR, FS$INC
	 .globl   FS$INCRX, FS$INCX
         .globl   FS$ADD

	 .if      .TMS340_IEEE
ONE      .set     03F800000h
	 .else
ONE      .set     040400000h
	 .endif

FS$INC:  MOVE     A9,*-SP,1
	 MOVE     A8,A9
	 JR       push

FS$INCR:
         MOVE     A9,*-SP,1
	 MOVE     A8,A9
	 MOVE     *A8+,*A14+,1       ; PUSH RETURN VALUE ON STACK
push:
	 MOVE     *A9+,*A14+,1       ; PUSH COPY TO BE INCREMENTED

         MOVI     ONE,A8             ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
         CALLA    FS$ADD             ; ADD ONE TO ARGUMENT

	 MOVE     *-A14,*-A9,1       ; PERFORM ASSIGNMENT

	 MOVE     *SP+,A9,1
	 RETS   

*****************************************************************************
* These entry points take values from A8, and return the result in A8
*****************************************************************************
FS$INCRX:MOVE     A8,*A14+,1
FS$INCX: MOVE     A8,*A14+,1

         MOVI     ONE,A8             ; PUT FLOATING POINT ONE ON STACK
         MOVE     A8,*A14+,1
         CALLA    FS$ADD             ; ADD ONE TO ARGUMENT
	 MOVE     *-A14,A8,1         ; RETURN RESULT        
	 RETS

