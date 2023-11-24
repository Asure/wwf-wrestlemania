*******************************************************************************
*  FD$CMP     v6.10
*  Copyright (c) 1991  Texas Instruments Incorporated
* 
*  This function compares two double precision IEEE floating point numbers.
*  True or False is returned in register A8, and the two numbers are popped
*  off the stack.
*
*******************************************************************************

        .globl  FD$LE 
        .globl  FD$LT
        .globl  FD$GE 
        .globl  FD$GT 

*******************************************************************************
*  COMPARE OPCODE IS SET UP IN A8, DEPENDING ON WHAT COMPARISON IS DONE
*******************************************************************************
FD$LE:  MOVK    1,A8
        JRUC    start

FD$LT:  MOVK    2,A8
        JRUC    start

FD$GE:  MOVK    3,A8
        JRUC    start

FD$GT:  MOVK    4,A8

start:
        MOVE    A12,-*SP,1
	.if     .TMS340_IEEE & .TMS34020
        .ref    __present82
        MOVE    @__present82,A12,1
        JRZ     EMU_CMP

*******************************************************************************
*  34082
*******************************************************************************
        MMTM    SP,A1,A2         ; STORE USED REGISTERS

        MOVE    A14,A1
        SUBI    128,A1
        MOVD    *A1+,RA0
        MOVD    *A1+,RB0
        SUBI    128,A14

        CMPD    RA0,RB0        ; COMPARE OPERANDS
        GETCST                 ; MOVE FPU STATUS TO GSP STATUS

        MOVK    5,A2           ; SET UP MASK FOR GE / LE
        JRZ     shift
        MOVK    3,A2           ; SET UP MASK FOR LT / LE
        JRN     shift
        MOVK    12,A2          ; SET UP MASK FOR GT / GE

*******************************************************************************
*  A MASK IS SET UP IN A2 USING COMPARE INSTRUCTIONS TO DETERMINE WHICH
*  COMPARISONS WOULD BE TRUE.  THIS MASK IS THEN SHIFTED RIGHT ACCORDING
*  TO THE COMPARE OPCODE (IN A8) WHICH CAUSES A ONE OR ZERO TO BE PLACED
*  IN THE CARRY.
*
*               - - - -+----+----+----+----+
*                      | GT | GE | LT | LE |
*               - - - -+----+----+----+----+
*                      bit 3           bit 0
*
*******************************************************************************
shift:
        NEG     A8
        SRL     A8,A2
        SUBB    A8,A8
        SRL     31,A8

        MMFM    SP,A1,A2
        MOVE    *SP+,A12,1
	MOVE    A8,A8         ; SET STATUS
        RETS
	.endif
        
*******************************************************************************
*  IEEE/GSP EMULATION
*******************************************************************************
* REGISTER USAGE
*    A0, A2 - Contains RHS operand of the compare
*    A4, A3 - Contains LHS operand
*********************************************************************
EMU_CMP:
         MMTM     SP,A0,A2,A3,A4
	 .if      .TMS340_IEEE
         MOVE     -*A14,A2,1              ; POP RHS OFF STACK
         MOVE     -*A14,A0,1
         MOVE     -*A14,A3,1              ; POP LHS OFF STACK
         MOVE     -*A14,A4,1 
	 .else
         MOVE     -*A14,A0,1
         MOVE     -*A14,A2,1              ; POP RHS OFF STACK
         MOVE     -*A14,A4,1 
         MOVE     -*A14,A3,1              ; POP LHS OFF STACK
	 .endif

***************************************************************************
* CHECK CASES FOR <,<=,>,>=
*
*  THE COMPARE IS ACCOMPLISHED IN TWO STEPS. THE FIRST HALF IS COMPARED,
*  AND IF UNEQUAL, THE RESULT IS COMPUTED.  
*
*  A MASK IN A2 IS SET UP USING COMPARE INSTRUCTIONS TO DETERMINE WHICH
*  COMPARISONS WOULD BE TRUE.  THIS MASK IS THEN SHIFTED RIGHT BY THE VALUE
*  IN A8 (THE COMPARE OPCODE) AND CAUSES A ONE OR A ZERO TO BE PLACE IN CARRY.
*              
*                  - - - -+----+----+----+----+
*                         | GT | GE | LT | LE |
*                  - - - -+----+----+----+----+
*                         bit 3           bit 0
***************************************************************************
COMPARE:
         CMP      A0,A4              ; COMPARE MSW'S
         JRZ      COMP2              ; IF EQUAL, CHECK SECOND HALF

         MOVK     3,A2               ; SET UP SHIFT MASK FOR LT/LE
         JRLT     FAST_LT
         MOVK     12,A2              ; SET UP SHIFT MASK FOR GT/GE

***************************************************************************
*  CHECK FOR CASE OF BOTH NEGATIVE. IF SO, STRIP SIGN BITS AND RECOMPARE
***************************************************************************
FAST_LT:
         SLL      1,A0               ; IF BOTH NEGATIVE...
         JRNC     NOT_NEG            ;                  ...
         SLL      1,A4               ;                  ...
         JRNC     NOT_NEG            ;                  ...
         CMP      A0,A4              ;   ... RECOMPARE UNSIGNED (W/O SIGN BITS)

         MOVK     3,A2               ; SET UP SHIFT MASK FOR LT/LE
         JRHI     NOT_NEG
	 MOVK     12,A2              ; SET UP SHIFT MASK FOR GT/GE 

NOT_NEG:
         NEG      A8
         SRL      A8,A2              ; SHIFT RESULT BIT INTO CARRY
         SUBB     A8,A8
         SRL      31,A8              ; PUT RESULT IN A8 BIT 0
         MMFM     SP,A0,A2,A3,A4
         MOVE    *SP+,A12,1
	 MOVE    A8,A8               ; SET STATUS
         RETS

***************************************************************************
*
*  HANDLE COMPARE OF SECOND HALF OF NUMBER
*  NOTE THAT THIS CODE IS ONLY USED IF THE FIRST WORDS ARE EQUAL
*
***************************************************************************
COMP2:
         CMP      A2,A3
         MOVK     5,A2              ; SET UP EQUAL MASK
         JRZ      EQUAL             ; IF EQUAL, GET ANSWER AND RETURN

         MOVK     3,A2              ; SET UP SHIFT MASK FOR LT/LE
         JRLO     SLOW_LT
         MOVK     12,A2             ; SET UP SHIFT MASK FOR GT/GE

SLOW_LT:
         SLL      1,A0               ; PUT SIGN BIT IN CARRY
         JRNC     EQUAL              ; IF NEGATIVE ...
         NOT      A2                 ;            ... ONES COMPLEMENT MASK

EQUAL:
         NEG      A8
         SRL      A8,A2              ; SHIFT RESULT BIT INTO CARRY
         SUBB     A8,A8
         SRL      31,A8              ; PUT RESULT IN A8 BIT 0
         MMFM     SP,A0,A2,A3,A4
         MOVE    *SP+,A12,1
	 MOVE    A8,A8               ; SET STATUS
         RETS

         .end
