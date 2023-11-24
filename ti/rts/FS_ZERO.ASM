*******************************************************************************
*  FS$ZERO     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function compares the number at the top of the stack with zero and 
*  returns a result in register A8.  One number is consumed from the stack.
*  Returns 0 in A8 when value == 0
*
*******************************************************************************

         .globl   FS$ZERO

FS$ZERO:
         MOVE     -*A14,A8,1       ; POP NUMBER OFF STACK
	 JRZ      end
	 MOVI     1,A8             ; MAKE SURE STATUS IS SET
end:     RETS

         .end
