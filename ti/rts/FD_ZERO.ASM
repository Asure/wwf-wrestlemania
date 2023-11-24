*******************************************************************************
*  FD$ZERO     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*  This function compares a double precision floating point number to zero.
*  Returns 0 in A8 when value == 0
*
*******************************************************************************

         .globl   FD$ZERO

FD$ZERO:
	 .if      .TMS340_IEEE
         MOVE     *A14(-64),A8,1     ; POP MS 32-BITS (IEEE) 
	 .else
	 MOVE     -*A14,A8,1         ; POP MS 32-BITS (GSP)
	 .endif
         SRL      20,A8
	 JRZ     end
	 MOVK     1,A8               ; VALUE == 0
end:
	 .if      .TMS340_IEEE
         SUBI     64,A14             ; UPDATE STACK POINTER
	 .else
         SUBI     32,A14             ; UPDATE STACK POINTER
	 .endif
         MOVE     A8,A8              ; SET STATUS ON RESULT
         RETS

         .end

