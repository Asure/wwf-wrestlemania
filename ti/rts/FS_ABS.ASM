*******************************************************************************
*  FS$ABS     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function returns the absolute value of a single precision number.
*  The sign bit of the number is read, cleared, and stored.
*
*******************************************************************************
         
         .globl   FS$ABS

FS$ABS:
         MOVE     *-A14,A8,1             ; POP FLOAT 
	 ANDI     07FFFFFFFH,A8          ; ABSOLUTE VALUE
         MOVE     A8,*A14+,1             ; PUSH RESULT 
         RETS

         .end

