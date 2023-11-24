****************************************************************************
*  check82() v6.10 
*  Copyright (c) 1991  Texas Instruments Inc.
*  
*  This function will execute a series of 34082 coprocessor instructions
*  to determine whether or not a 34082 exists in the current configuration.
****************************************************************************
        .global _check82

        .even  32
ONE:	.float 1.
SEVEN:	.float 7.
SVNTH:	.float 0.142857142857

_check82:
        .if     .TMS340_IEEE & .TMS34020
	MOVE	CCONFIG,A8	; SAVE OFF USED REGISTERS
	MOVE	A8,-*SP,1
	MOVI	28h,A8
	MOVE	A8,CCONFIG
	SUBI	192,SP	
	MOVE	SP,A8
	MOVD	RA0,*A8+
	MOVD	RB0,*A8+,2

	MOVI	ONE,A8		; LOAD VALUES INTO '82 REGISTERS
	MOVF    *A8+,RA0	
	MOVF	*A8+,RB0
	MOVF	*A8+,RB1
	DIVF	RA0,RB0,RA0	; DIVIDE ONE BY SEVEN
	CMPF	RA0,RB1		; CHECK FOR EXPECTED RESULT
	GETCST
	JRZ	SETFLAG
	CLRS	A8
	JRUC	DONE

SETFLAG:
	MOVK	1,A8

DONE:
	MOVD	*SP+,RA0	; RESTORE USED REGISTERS
	MOVD	*SP+,RB0,2
	MOVE	*SP+,CCONFIG	; RESTORE '82 CONFIG REG
	.else
	CLRS    A8
	.endif
	MOVE	A8,A8		; SET A8 FOR DESIRED STATUS
	RETS
	.end

