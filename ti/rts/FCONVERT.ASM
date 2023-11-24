*******************************************************************************
*  FCONVERT v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
*
*        This function converts a double precision GSP floating point number to
*        an IEEE double precision format.   
*
*        This function is not supported with the 34082 runtime model
*
*******************************************************************************

         .globl   _fconvert

*******************************************************************************
* DEFINE CONSTANTS
*******************************************************************************
CBIT     .set     000001000h
STK      .set     A14

_fconvert:
         .if      .TMS340_MEMPARM
         MMTM     SP,A0,A1,A2        ; SAVE REGISTERS (IF MODEL REQUIRES)
	 .endif

****************************************************************************
*  POP DOUBLE PRECISION NUMBER OFF STACK 
****************************************************************************
         MOVE     *-A14,A0,1
         MOVE     *-A14,A1,1

         MOVE     A0,A8
         SLL      12,A8              ; LEFT JUSTIFY MSW OF MANTISSA
         JRZ      DONE               ; IF MANTISSA IS ZERO THEN WE ARE DONE

****************************************************************************
* ISOLATE AND DECREMENT EXPONENT, ISOLATE SIGN BIT IN A0                   *
****************************************************************************
         MOVE     A0,A2
         SRL      31,A0
         SLL      31,A0              ; SIGN BIT IN BIT 31 OF A0
         SLL      1,A2
         SRL      21,A2
         SUBK     1,A2               ; SUBTRACT ONE FROM THE EXPONENT
         JRZ      ZEROEXP

****************************************************************************
* IF EXPONENT IS NOT ZERO, THROW AWAY LEADING ONE IN MANTISSA              *
****************************************************************************
         SLL      1,A8               ; ELSE THROW AWAY THE LEADING ONE
         SLL      1,A1               ; SHIFT LSB'S LEFT ONE TOO
         JRNC     ZEROEXP
         ORI      CBIT,A8            ; 64 BIT SHIFT

****************************************************************************
* BUILD RESULT AND PUT ON STACK
****************************************************************************
ZEROEXP:
         SRL      12,A8              ; RIGHT JUSTIFY THE MANTISSA  MSB'S
         SLL      20,A2              ; ALIGN THE EXPONENT
         OR       A8,A2              ; COMBINE EXP. AND MANTISSA
         OR       A2,A0              ; A0 NOW HOLDS THE IEEE NUMBER 32 MSB'S
DONE:
         .if      .TMS340_MEMPARM
         MOVE     A0,*STK(-32),1     ; PUT MSB'S IEEE NUMBER ON THE STACK
         MOVE     A1,*STK(-64),1     ; PUT LSB'S IEEE NUMBER ON THE STACK
         MMFM     SP,A0,A1,A2        ; RESTORE THE REGISTERS
         RETS     2
	 .else
	 MOVE     A0,A7
	 MOVE     A1,A8
	 ADDI     64,STK             ; CALLEE DOES NOT POP ARGUMENTS
	 RETS
	 .endif
         .end

