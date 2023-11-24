****************************************************************************/
*  modf   v6.10                                                            */
*  Copyright (c) 1991  Texas Instruments Incorporated                      */
****************************************************************************/

STK	 .set	A14
IEEE     .set    .TMS340_IEEE               ; DID USER SPECIFY IEEE FORMAT
COPROC   .set    .TMS34082                  ; IS COPROCESSOR IN SYSTEM
REGPARM  .set    .TMS340_REGPARM            ; ARGUMENTS PASSED IN REGISTERS
MEMPARM  .set    .TMS340_MEMPARM            ; ARGUMENTS PASSED ON STACK
REGFLOAT .set    REGPARM & COPROC           ; FLOAT ARGUMENT PASSED IN REG

**********************************************************************
* 
* FUNCTION DEF : double _modf(double value, double *iptr);
* 
*  MODF is defined to return the whole and fractional parts
*  of any floating point value.  The fractional part is
*  returned, and the whole part is assigned through the
*  pointer argument *iptr.
* 
**********************************************************************
	.globl	_modf
_modf:
        .if     MEMPARM	
	MMTM	SP,A1,A7,A9,A10,A11,A12
	.else
	MMTM	SP,A9,A10,A11,A12
        .endif

**********************************************************************
* FETCH value ARGUMENT INTO A10 and A11, WITH EXPONENT IN A10
**********************************************************************
        .if     COPROC & REGPARM
        MOVD    RB2,A10,A11        ; GET FLOAT ARG FROM COPROCESSOR

        .else
	MOVE	STK,A8             ; GENERATE ADDRESS OF value ARG
	SUBI	64,A8            

        .if     IEEE               ; IEEE FLOATING POINT EMULATION
	MOVE	*A8+,A10,1
	MOVE	*A8,A11,1

        .else                      ; GSP FLOATING POINT EMULATION
	MOVE	*A8+,A11,1
	MOVE	*A8,A10,1
        .endif
	.endif

**********************************************************************
* FETCH EXPONENT, SUBTRACT BIAS, AND SAVE IN A REGISTER
**********************************************************************
	MOVE	A10,A12
	SLL     1,A12 
	SRL     21,A12              
	SUBI	1023,A12           ; exp = ((m0 >> 20) & 0x7FF) - 0x3FF;

**********************************************************************
* SAVE SIGN BIT IN REGISTER
**********************************************************************
	MOVE	A10,A1
	SRL     31,A1
	SLL     31,A1              ; sign = m0 & 0x80000000;

**********************************************************************
* HANDLE UNDERFLOW - SET *iptr = 0, return "value"                   *
* note: IEEE range of exponents includes 0 (implied 1)               *
**********************************************************************
	MOVE	A12,A8             ; if (exp > 0) continue
	.if	IEEE
	JRZ	L4		   ; 0 exponent requires no alignment
	.endif
	JRLE	FRACTION     

**********************************************************************
* HANDLE OVERFLOW - SET *iptr = value, return 0                      *
**********************************************************************
	CMPI	52,A12             ; if (exp < 52) continue
	JRGE    WHOLE

*********************************************************************/
* SHIFT OFF WHOLE PART OF NUMBER, LEAVING ONLY FRACTIONAL PART.     */
* NOTE: IT IS NOT NECESSARY TO WORRY ABOUT THE IMPLIED 1 USED IN    */
*       IEEE NUMBERS, SINCE THESE ARE A COMPONENT OF THE WHOLE PART */
*       OF THE NUMBER (exp > 0) AND WE ARE TRYING TO ISOLATE THE    */
*       FRACTIONAL PART OF THE NUMBER (DISPOSING THE WHOLE PART)    */
* -- If shift > 32, do this slightly differently                    */
*********************************************************************/
;>>>> 	     if (exp >= 32) { m0  = (m1 << (exp - 32)); m1 = 0;   }
	CMPI	32,A12
	JRLT	L3

	MOVE	A12,A8 
	SUBK	32,A8
	MOVE	A11,A10
	SLL	A8,A10
	CLRS	A11
	JR	L4

L3:
;>>>> 	     else  { m0 <<= exp; m0 |= (m1 >> (32 - exp)); m1 <<= exp; }
	SLL	A12,A10               ; m0 <<= exp; 
	MOVE	A12,A8
	SUBK	32,A8
	MOVE	A11,A7
	SRL	A8,A7
	OR	A7,A10                ; m0 += (m1 >> (32 - exp));
	SLL	A12,A11               ; m1 <<= exp;

*********************************************************************/
* MASK OFF FRACTIONAL PART OF MANTISSA (DISPOSE WHOLE PART)         */
*********************************************************************/
L4:
        SLL     12,A10
        SRL     12,A10                ; m0 &= 0x000FFFFF 

*********************************************************************/
* IF FRACTIONAL PART OF NUMBER IS ZERO, ABORT.                      */
*********************************************************************/
;>>>> 	     if (!m1 && !m0) return((*iptr = value), 0.0);
	MOVE	A11,A8
	OR      A10,A8
	JRZ     WHOLE

**********************************************************************
* MAKE SURE TOP BITS OF FRACTIONAL MANTISSA ARE NON-ZERO 
**********************************************************************
;>>>> 	     for (exp = 0; (m0 == 0); exp -= 20) 
;>>>> 		  { m0 = (m1 >> 12); m1 <<= 20; }
	CLRS	A12
	MOVE	A10,A8
	JRNZ	L7
L6:
	MOVE	A11,A10
	SRL	12,A10         ; m0   = m1 >> 12
	SLL	20,A11         ; m1 <<= 20
	SUBK	20,A12         ; exp -= 10
	MOVE	A10,A8         ; while (m0 == 0) continue	
	JRZ	L6

**********************************************************************
* THE TOP 20 BITS OF THE FRACTIONAL MANTISSA ARE NOW NON-ZERO.  
* NOW DO THE NORMALIZATION. IF IEEE, NORMALIZE BY 1 BIT MORE
* TO ACCOUNT FOR IMPLIED ONE.
**********************************************************************
L7:
	LMO     A10,A9
	SUBK	(12-IEEE),A9    ; norm -= 12 - IEEE
	JRZ	L8                       

**********************************************************************
* PERFORM A 64 BIT SHIFT BY THE VALUE IN norm, ADJUST RESULT EXPONENT
**********************************************************************
	SUB	A9,A12          ; exp -= norm;
	SLL	A9,A10          ; m0 <<= norm; 
	MOVE	A9,A7
	SUBK	32,A7
	MOVE	A11,A8
	SRL	A7,A8
	OR	A8,A10          ; m0  |= (m1 >> (32 - norm));
	SLL	A9,A11          ; m1 <<= norm; 

**********************************************************************
* BUILD RESULTING FRACTIONAL PART OF INPUT NUMBER 
* NOTE : IF IEEE, REMOVE IMPLIED 1
* RESULTING VALUE (call it "result") is in A10/A11
**********************************************************************
L8:
	.if     IEEE
	SLL     12,A10
	SRL     12,A10            ; MASK OFF IMPLIED BIT FOR IEEE
	.endif

	ADDI	1023,A12          ; exp += bias
	SLL	20,A12 
	OR	A12,A10 
	OR	A1,A10            ; m0 |= (exp << 20) | sign;

**********************************************************************
* SET *iptr = value - result, RETURN result
**********************************************************************
;>>>> 	     return ((*iptr = value - result), result);
        .if     COPROC == 0

	.if     MEMPARM                ; fetch pointer argument into A7
	MOVE	*STK(-96),A7,1
	.else
	MOVE    A0,A7
        .endif                         ; fetch...

	.if     IEEE 
	MOVE	A10,*STK+,1
	MOVE	A11,*STK+,1            ; PUSH RESULT
        .else     ; GSP FORMAT
	MOVE	A11,*STK+,1
	MOVE	A10,*STK+,1            ; PUSH RESULT
	.endif

	CALLA	FD$SUB
	MOVE	*-STK,A8,1
	MOVE	A8,*A7(32),1
	MOVE	*-STK,A8,1
	MOVE	A8,*A7,1               ; POP VALUE INTO *iptr
	.endif

**********************************************************************
* IN MEMORY MODEL, PUSH DOUBLE VALUE, RESTORE STACK, RETURN
**********************************************************************
        .if     (COPROC == 0) & MEMPARM
	MOVE	*SP(224),STK,1
	.if     IEEE
	MOVE	A10,*STK(-64),1
	MOVE	A11,*STK(-32),1        ; PUSH RESULT 
        .else     ; GSP FORMAT
	MOVE	A11,*STK(-64),1
	MOVE	A10,*STK(-32),1        ; PUSH RESULT
	.endif
	MMFM	SP,A1,A7,A9,A10,A11,A12
	RETS    2
	.endif

**********************************************************************
* IN REGISTER MODEL, RETURN DOUBLE RESULT IN (A7:A8)
*  NOTE!!: DOUBLE ARGUMENT WAS POPPED OFF STACK BY SUBTRACTION. 
**********************************************************************
        .if     (COPROC == 0) & REGPARM
	.if     IEEE        ; (IEEE & REGPARM)
	MOVE	A10,A7 
	MOVE	A11,A8
	.else               ; (GSP & REGPARM)
	MOVE	A11,A7
	MOVE	A10,A8
        .endif	
	ADDI    64,STK      ; IT IS CALLER'S JOB TO POP ARGS
	MMFM	SP,A9,A10,A11,A12
	RETS
        .endif

**********************************************************************
* IF WE HAVE A COPROCESSOR, USE IT.
**********************************************************************
        .if     COPROC & MEMPARM
	MOVE    STK,A8                 
	SUBI    64,A8
	MOVD    *A8+,RB2               ; RB2 = value
	MOVD    A10,A11,RA0            ; RA0 = result
	SUBD    RB2,RA0,RB2            ; RB2 = value - result;
	MOVE	*STK(-96),A8,1
        MOVD    RB2,*A8+               ; *iptr = value - result
	MOVE	*SP(224),STK,1
	MMFM	SP,A1,A7,A9,A10,A11,A12
	RETS	2
	.endif

        .if     COPROC & REGPARM
	MOVD    A10,A11,RA0            ; RA0 = result
	SUBD    RB2,RA0,RB2            ; RB2 = value - result;
	MOVD    RB2,*A0+               
	MMFM	SP,A9,A10,A11,A12
	RETS
        .endif


**********************************************************************
***
*** IF VALUE HAS NO WHOLE PART, SET *iptr = 0 AND RETURN value
***
**********************************************************************
FRACTION:

**********************************************************************
* SET *iptr = 0. 
**********************************************************************
        .if     MEMPARM
	MOVE	*STK(-96),A8,1     ; FETCH iptr
	CLR     A7
	MOVE	A7,*A8+,1
	MOVE	A7,*A8,1           ; *iptr = 0
	.else   
	CLR     A7
	MOVE	A7,*A0+,1
	MOVE	A7,*A0,1           ; *iptr = 0
        .endif

**********************************************************************
* RETURN value - Depends on use of coprocessor and on runtime model
**********************************************************************
        .if    (COPROC == 0) & MEMPARM
        MOVE    STK,A1             ; GET COPY OF ARGUMENT POINTER
	MOVE    *SP(224),STK,1     ; RESTORE STACK
	MOVE    STK,A8             ; GET COPY OF RETURN ADDRESS
	MOVE	*-A1,*-A8,1        ; COPY RETURN VALUE
	MOVE	*-A1,*-A8,1
	MMFM	SP,A1,A7,A9,A10,A11,A12
	RETS    2
	.endif

        .if     COPROC & MEMPARM
	MOVE    STK,A8
        SUBI    64,A8
	MOVD    *A8+,RA0           ; LOAD value INTO RA0, RETURN
	MOVE	*SP(224),STK,1     ; RESTORE STACK POINTER
	MMFM	SP,A1,A7,A9,A10,A11,A12
	RETS	2
	.endif
	
	.if    (COPROC == 0) & REGPARM
	MOVE    *-STK,A8,1         ; POP ARGUMENT OFF STACK
	MOVE    *-STK,A7,1
	ADDI    64,STK             ; LET CALLER DEALLOCATE ARGS
	MMFM	SP,A9,A10,A11,A12
	RETS
	.endif

	.if     COPROC & REGPARM
	MOVD    RB2,RA0            ; RETURN ARGUMENT
	MMFM	SP,A9,A10,A11,A12
	RETS
	.endif

**********************************************************************
***
*** IF VALUE HAS NO FRACTIONAL PART, SET *iptr = value, RETURN 0.0
***
**********************************************************************
WHOLE:

**********************************************************************
* RETURN ZERO - Depends on whether we are using coprocessor
**********************************************************************
        .if    (COPROC == 0) & MEMPARM
	MOVE	*STK(-96),A8,1
	MOVE	*STK(-64),*A8(0),1
	MOVE	*STK(-32),*A8(32),1  ; *iptr = value

	MOVE    *SP(224),A1,1    ; GET RETURN VALUE ADDRESS
	MOVE    A1,A12           ; SAVE COPY OF IT FOR NOW
	CLR     A8
	MOVE	A8,*-A1,1
	MOVE	A8,*-A1,1        ; STORE 0.0 INTO RETURN VALUE ADDRESS
	MOVE    A12,STK          ; RESTORE CALLER'S STACK POINTER
	MMFM	SP,A1,A7,A9,A10,A11,A12
	RETS    2
	.endif

        .if     COPROC & MEMPARM
	MOVE	*STK(-96),A8,1
	MOVE	*STK(-64),*A8(0),1
	MOVE	*STK(-32),*A8(32),1  ; *iptr = value
	CLRD    RA0
	MOVE	*SP(224),STK,1     ; RESTORE STACK POINTER
	MMFM	SP,A1,A7,A9,A10,A11,A12
	RETS	2
	.endif
	
	.if    (COPROC == 0) & REGPARM
	ADDI    64,A0
	MOVE    *-STK,*-A0,1       ; POP ARGUMENT OFF STACK
	MOVE    *-STK,*-A0,1
	ADDI    64,STK             ; LET CALLER DEALLOCATE ARGS
	CLR     A8                
	CLR     A7          
	MMFM	SP,A9,A10,A11,A12
	RETS
	.endif

	.if     COPROC & REGPARM
	MOVD    RB2,*A0+
	CLRD    RA0                ; RETURN ARGUMENT
	MMFM	SP,A9,A10,A11,A12
	RETS
	.endif

*****************************************************
* UNDEFINED REFERENCES                              *
*****************************************************
	.globl  FD$SUB
	.end
