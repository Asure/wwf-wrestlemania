*******************************************************************************
*  FD$ABS     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function returns the absolute value of a double precision number.
*  The sign bit of the number is read, cleared, and stored.
*
*******************************************************************************
         
         .globl   FD$ABS

FD$ABS:
	 .if      .TMS340_IEEE
         MOVE     *A14(-64),A8,1         ; MOVE TOP 32 BITS OF NUMBER TO A8
	 .else
	 MOVE     -*A14,A8,1            
	 .endif

	 ANDI     07FFFFFFFH,A8          ; TAKE ABSOLUTE VALUE. 

	 .if      .TMS340_IEEE
         MOVE     A8,*A14(-64),1         ; PUT RESULTANT SIGN BIT ON STACK
	 .else
	 MOVE     A8,*A14+,1             ; PUSH RESULT
	 .endif
         RETS
         .end

