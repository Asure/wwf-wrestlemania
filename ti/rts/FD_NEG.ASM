*******************************************************************************
*  FD$NEG     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function negates a double precision floating point number.
*  The sign bit of the number is popped, complemented, and pushed.
*
*******************************************************************************
         
         .globl   FD$NEG

FD$NEG:
	 .if      .TMS340_IEEE
         MOVE     *A14(-64),A8,1         ; MOVE TOP 32 BITS OF NUMBER TO A8
	 .else
	 MOVE     -*A14,A8,1            
	 .endif
         JRZ      DONE                   ; DO NOT NEGATE ZERO

	 XORI     080000000H,A8          ; NEGATE NON-ZERO VALUE

DONE:
	 .if      .TMS340_IEEE
         MOVE     A8,*A14(-64),1         ; PUT RESULTANT SIGN BIT ON STACK
	 .else
	 MOVE     A8,*A14+,1             ; PUSH RESULT
	 .endif
         RETS

         .end

