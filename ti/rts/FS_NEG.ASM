*******************************************************************************
*  FS$NEG     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function negates a single precision floating point number.
*  The sign bit of the number is popped, complemented, and pushed.
*
*******************************************************************************
         
         .globl   FS$NEG

FS$NEG:
         MOVE     *-A14,A8,1             ; POP FLOAT 
         JRZ      DONE                   ; DO NOT NEGATE ZERO

	 XORI     080000000H,A8          ; NEGATE NON-ZERO VALUE

DONE:
         MOVE     A8,*A14+,1             ; PUSH RESULT 
         RETS

         .end

