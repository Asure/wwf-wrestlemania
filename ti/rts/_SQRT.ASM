***************************************************************************
*  _sqrt   v6.10                                                          *
*  Copyright (c) 1991 Texas Instruments Incorporated                      *
***************************************************************************

***************************************************************************
* _SQRT() - Square Root - Minimal error checking                          *
*                                                                         *
*   double _sqrt(double x);                                               *
*     Same as sqrt, but not guaranteed to do error checking.  This is     *
*     provided as a fast alternative to the standard function, and a      *
*     closer mapping to the capability of the TMS34082 coprocessor SQRTD  *
*     instruction.                                                        *
*                                                                         *
***************************************************************************
EDOM	.set	1
	.globl	__sqrt
	.globl	_errno

***************************************************************************
* Constant definitions                                                    *
***************************************************************************
INFIN	.set	07ff00000h
SGN	.set	080000000h
STK	.set	A14

***************************************************************************
*                                                                         *
* TMS34082 COPROCESSOR VERSION                                            *
*                                                                         *
***************************************************************************
__sqrt:
	.if	.TMS34082 & .TMS340_MEMPARM
	MOVE	STK,A8
	SUBI	64,A8
	SQRTD  *A8+,RA0,RA0
	SUBI	64,STK
	RETS	2
	.endif

	.if	.TMS34082 & .TMS340_REGPARM
	MOVD	RB2,RA0
	SQRTD	RA0,RA0		
	RETS
	.endif

***************************************************************************
*                                                                         *
* Floating point emulation models (TMS340 and IEEE) -                     *
*    Doubles are not passed in registers, therefore, argument has been    *
*    pushed on stack.  Argument in [A3:A4]                                *
*                                                                         *
***************************************************************************
	.if	.TMS340_MEMPARM
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A9
	.else
	MMTM	SP,A3,A4,A5,A6,A9
	.endif

	.if	.TMS340_IEEE
	MOVE	*-STK,A4,1
	MOVE	*-STK,A3,1
	.else
	MOVE	*-STK,A3,1
	MOVE	*-STK,A4,1
	.endif

***************************************************************************
* Isolate exponent                                                        *
***************************************************************************
	MOVE	A3,A6
	SRL	20,A6

***************************************************************************
* Left justify mantissa in A3:A4 - IEEE requires an implicit one          *
***************************************************************************
	MOVE	A4,A5		; A5 is temp for splitting A4
	.if	.TMS340_IEEE
	SRL	21,A5		; isolate upper 11 out of 32 LS bits
	SLL	11,A4		; left justify 21 LS bits in A4
	SLL	11,A3		; left justify 20 out of 32 MS bits
	ORI	SGN,A3		; tack on implicit one
	ADDK	1,A6		; add 1 to exponent for implicit one
	.else
	SRL	20,A5		; isolate upper 12 out of 32 LS bits
	SLL	12,A4		; left justify 20 LS bits in A4
	SLL	12,A3		; left justify 20 MS bits
	.endif

	OR	A5,A3		; splice in bits transferred from A4->A3

***************************************************************************
* Adjust argument so that exponent is even - if exponent is odd, shift    *
* mantissa right and add one to exponent.                                 *
***************************************************************************
	ADDI	-1023,A6	; subtract off bias
	SRA	1,A6		; result exp is (original exp/2)
	JRNC	start           ; if (exp - 1023) is even, then exp is odd
	SRL	1,A4
	SRL	1,A3
	JRNC	noc
	ORI	SGN,A4		; shift mantissa

noc:
	ADDK	1,A6		; increment result exponent (make even)

***************************************************************************
* Newton iterations                                                       *
*   The function used to derive the iterations, Xn+1 = (Xn + A/Xn)/2,     *
*   converges on the square root of A given that 0.5 <= A < 1.0           *
***************************************************************************
start:
	ADDI	1023,A6		; add bias back in
        ;******************************************************************
        ;   First iteration is done before the loop, if possible, since   *
	;   X0 is 0xFFFFFFFF.  Then A/X0 is equivalent to a 32-bit right  *
	;   shift.                                                        *
        ;******************************************************************
	MOVI	-1,A0		; largest 32-bit factor of 64-bit number

loop:
	MOVE	A0,A2
	MOVE	A3,A0
	MOVE	A4,A1		; move original mantissa into A0:A1
	DIVU	A2,A0		; 64x32 bit divide -- A0 = mant/Xn
	JRV	doneh		; reached point of convergence

skipit1:
	ADD	A2,A0		; A0 = Xn + mant/Xn
	JRNC	noc1
	SRL	1,A0
	ORI	SGN,A0		; shift carry back into quotient
	JRUC	test

noc1:
	SRL	1,A0		; A0 = Xn+1 = (Xn + mant/Xn)/2
 
test:
	CMP	A0,A2		; have XHIGH if Xn+1 >= Xn
	JRHI	loop

***************************************************************************
* Newton iteration has converged on sqrt(mant) within 32-bits of precision*
* Now approximate lower bits of sqrt(mant).  Will use:                    *
*   XLOW = ((LS 33-bits of (mant - XHIGH^2))/2)/XHIGH                     *
***************************************************************************
doneh:
	MOVE	A0,A8
	MPYU	A8,A8		; XHIGH * XHIGH
	SUB	A9,A4
	SUBB	A8,A3		; temp1 = mant - (XHIGH * XHIGH)
	;******************************************************************
        ; Approximate XLOW as ((LS 33-bits of temp)/2)/XHIGH              *
        ;******************************************************************
	XOR	A5,A5
	SRL	1,A4		; temp2 = (LS 33-bits of temp) / 2
	JRNC	noc2
	ORI	SGN,A5

noc2:
	RL	31,A3
	OR	A3,A4
	DIVU	A0,A4		; XLOW = temp2 / XHIGH

***************************************************************************
* Put together result and round off                                       *
***************************************************************************
	MOVE	A0,A3		; put XHIGH in A3
	LMO	A3,A2
	JRZ	tstlsb		; if (XHIGH == 0) build result from XLOW
        ;******************************************************************
	; Normalize result mantissa and adjust exponent accordingly       *
        ;******************************************************************
	MOVE	A2,A2		; already normalized?
	JRZ	rndtst		; round off
	ADD	A2,A6		; adjust exponent based on number of shifts 
				; required to normalize
	RL	A2,A3		; normalize mantissa
	MOVE	A4,A0		; A0 carries bits shifted out of A4
	SLL	A2,A4
	SUBK	32,A2
	SRL	A2,A0
	OR	A0,A3		; and places them at bottom of A3
	JRUC	rndtst

tstlsb:
        ;******************************************************************
	; XHIGH == 0, so build result from XLOW                           *
        ;******************************************************************
	SUBK	32,A6		; at least 32-bits of normalization needed
	LMO	A4,A2
	JRZ	stks
	RL	A2,A4		; normalize mantissa
	MOVE	A4,A3
	XOR	A4,A4
	ADD	A2,A6		; adjust exponent based on number of shifts
				; required to normalize

        ;******************************************************************
	; Round off result                                                *
        ;******************************************************************
rndtst:
	.if	.TMS340_IEEE
	BTST	10,A4
	JRZ	stks		; no round off needed
	XOR	A0,A0
	ADDI	0800h,A4

	.else
	BTST	11,A4
	JRZ	stks		; no round off needed
	XOR	A0,A0
	ADDI	01000h,A4
	.endif

	ADDC	A0,A3
	JRNC	stks		; rounding caused overflow
	ADDK	1,A6
	SRL	1,A4
	SRL	1,A3
	JRNC	orin1
	ORI	SGN,A4
orin1:
	ORI	SGN,A3

stks:				; set up result in [A3:A4]
	.if	.TMS340_IEEE
	SRL	11,A4
	MOVE	A3,A5
	SRL	11,A3
	SLL	21,A5
	SUBK	1,A6
	.else
	SRL	12,A4
	MOVE	A3,A5
	SRL	12,A3
	SLL	20,A5
	.endif

        ;******************************************************************
	; Check integrity of exponent                                     *
        ;******************************************************************
	MOVE	A6,A6
	JRZ	zero
	JRN	zero		; underflow

	OR	A5,A4
	SLL	20,A6
	OR	A6,A3
        ;******************************************************************
	; Depending on runtime model, store result                        *
        ;******************************************************************
	.if	.TMS340_MEMPARM
	.if	.TMS340_IEEE
	MOVE	A4,*STK(-32),1
	MOVE	A3,*STK(-64),1
	.else
	MOVE	A3,*STK(-32),1
	MOVE	A4,*STK(-64),1
	.endif
	.else
	.if	.TMS340_IEEE
	MOVE	A3,A7
	MOVE	A4,A8
	.else
	MOVE	A4,A7
	MOVE	A3,A8
	.endif
	.endif

	.if	.TMS340_MEMPARM
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A9
	RETS	2
	.else
	ADDI    64,STK              ; LET CALLER POP ARG OFF STACK
	MMFM	SP,A3,A4,A5,A6,A9
	RETS
	.endif

***************************************************************************
* Quick zero return                                                       *
***************************************************************************
zero:
	.if	.TMS340_MEMPARM
	XOR	A4,A4
	.if	.TMS340_IEEE
	MOVE	A6,*STK(-64),1
	MOVE	A4,*STK(-32),1
	.else
	MOVE	A4,*STK(-64),1
	MOVE	A6,*STK(-32),1
	.endif
	.else
	.if	.TMS340_IEEE
	XOR	A8,A8
	MOVE	A6,A7
	.else
	XOR	A7,A7
	MOVE	A6,A8
	.endif
	.endif

	.if	.TMS340_MEMPARM
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A9
	RETS	2
	.else
	ADDI    64,STK              ; LET CALLER POP ARG OFF STACK
	MMFM	SP,A3,A4,A5,A6,A9
	RETS
	.endif
	.end

