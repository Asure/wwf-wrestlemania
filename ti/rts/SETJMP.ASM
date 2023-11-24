****************************************************************************
*  setjmp v6.10                                                            *
*  Copyright (c) 1991  Texas Instruments Incorporated                      *
****************************************************************************

****************************************************************************
*
*   jmp_buf : The size and format of the jmp_buf environment save area
*             will depend on whether direct 34082 support is being used.
*             If direct 34082 support is being used, then there are 9 extra
*             64-bit registers to be saved in addition to all of the GSP
*             registers.  This brings the size of the jmp_buf area up to
*             34*32 bits of memory which are used to store 9 64-bit 34082
*             registers and 16 32-bit GSP registers.  These registers are 
*             arranged in the following order:
*      
*   ptr---->  .double      RA5,RA6,RA7,RA8,RA9
*             .double      RB6,RB7,RB8,RB9
*             .long        SP
*             .long        A14,A13,...,A2,A0
*             .long        PC            ; RETURN ADDRESS
*   
*             The registers are stored in this order so that we only need
*             one register to access memory (A8).  The 34082 registers
*             are saved using *Rs+, and then the rest of the buffer is
*             filled using a single MMTM (which uses -*Rs, therefore 
*             the space in the buffer is filled in reverse order).
*
*             If direct 34082 support is NOT selected, then the buffer is
*             is only 16 32-bit registers long.  A8 and the status are 
*             NOT SAVED.
*
*   ptr---->  .long        SP
*             .long        A14,A13,...,A2,A0
*             .long        PC            ; RETURN ADDRESS
*
* NOTE: The number of GSP registers saved depends on the runtime model!!!
*
****************************************************************************
FP      .set     A13                        ; FRAME POINTER
STK     .set     A14                        ; PROGRAM STACK POINTER

        .global  _setjmp, __setjmp, _longjmp

****************************************************************************
*   setjmp
*
*     C syntax  :   int setjmp(env)
*                      jmp_buf *env;
*
*     Function  : Save caller's current environment for a subsequent
*                 call to longjmp.  Return 0.
*
****************************************************************************
*
*  NOTE : ANSI specifies that "setjmp.h" declare "setjmp" as a macro. 
*         In our implementation, the setjmp macro calls a function "_setjmp".
*         However, since the user may not include "setjmp.h", we provide
*         two entry-points to this function.
*
****************************************************************************

__setjmp:
_setjmp:
****************************************************************************
* MEMORY MODEL VERSION OF SETJMP
****************************************************************************
        .if      .TMS340_MEMPARM
numregs: .set     15                        ; NUMBER OF REGISTERS SAVED

        MOVE     -*STK,A8,1                 ; POP POINTER TO SAVE AREA

        .if      .TMS34082
        MOVD     RA5,*A8+,5                 ; SAVE OFF CALLEE SAVED A-FILE REGS
        MOVD     RB6,*A8+,4                 ; SAVE OFF CALLEE SAVED B-FILE REGS
        .endif

        ADDI     numregs*32,A8              ; GET POINTER TO END OF SAVE AREA
        MOVE     *SP(32),STK,1              ; RESTORE STACK POINTER

        MMTM     A8,A0,A1,A2,A3,A4,A5,A6,A7,A9,A10,A11,A12,A13,A14,SP
 
        MOVE     *SP(0),*A8(numregs*32),1   ; SAVE PC AT END OF BUFFER
        CLR      A8                         ; RETURN 0
        RETS     2                          ; return to caller

****************************************************************************
* REGISTER MODEL VERSION OF SETJMP
****************************************************************************
	.else        

numregs: .set     11                        ; NUMBER OF REGISTERS SAVED
	.if      .TMS34082
        MOVD     RA5,*A0+,5                 ; SAVE OFF CALLEE SAVED A-FILE REGS
        MOVD     RB6,*A0+,4                 ; SAVE OFF CALLEE SAVED B-FILE REGS
	.endif
	
        ADDI     numregs*32,A0              ; GET POINTER TO END OF SAVE AREA

        MMTM     A0,A3,A4,A5,A6,A9,A10,A11,A12,A13,A14,SP
        MOVE     *SP(0),*A0(numregs*32),1   ; SAVE PC AT END OF BUFFER
        CLR      A8                         ; RETURN 0
        RETS                                ; return to caller
	.endif

****************************************************************************
*   longjmp
*
*     C syntax  :   int longjmp(env, returnvalue)
*                      jmp_buf *env;
*                      int     returnvalue;
*
*     Function  : Restore the context contained in the jump buffer.
*                 This causes an apparent "2nd return" from the
*                 setjmp invocation which built the "env" buffer.
*                 This return appears to return "returnvalue".
*                 NOTE: This function may not return 0.
*
****************************************************************************
_longjmp:

****************************************************************************
* MEMORY MODEL VERSION OF LONGJMP
****************************************************************************
        .if      .TMS340_MEMPARM

        MOVE     -*STK,A8,1          ; POP POINTER TO SAVE AREA
        MOVE     -*STK,A1,1          ; POP RETURN VALUE

       ;*************************************************************
       ;*  RESTORE REGISTERS -
       ;*       - If direct 34082 support is used, we must restore
       ;*         the callee saved 34082 registers first. 
       ;*       - A0 and A1 are used for temporary registers, and
       ;*         therefore are not restored when all other registers
       ;*         are restored.  ONLY A8 CAN BE CORRUPTED, and this
       ;*         function cannot use static memory to save them.
       ;*************************************************************
        .if      .TMS34082
        MOVD     *A8+,RA5,5          ; RESTORE CALLEE SAVED A-FILE REGS
        MOVD     *A8+,RB6,4          ; RESTORE CALLEE SAVED B-FILE REGS
        .endif

        MMFM     A8,A2,A3,A4,A5,A6,A7,A9,A10,A11,A12,A13,A14,SP
        MOVE     *A8(64),A0,1        ; MOVE RETURN PC INTO A0
        ADDI     64,SP               ; "POP" OLD RETURN ADDRESS
        MOVE     A0,-*SP,1           ; PUSH RETURN ADDRESS
        MOVE     A1,-*SP,1           ; PUSH RETURN VALUE (FOR NOW)
        MMFM     A8,A0,A1            ; RESTORE REMAINING REGS

       ;*************************************************************
       ;* FETCH RETURN PARAMETER, LOAD INTO RETURN REGISTER
       ;* NOTE : IF RETURN VALUE IS ZERO, RETURN 1 (ANSI)
       ;*************************************************************
        MOVE     *SP+,A8,1           ; MOVE RETURN VALUE INTO A8
        JRNZ     longend             ; IF NON-ZERO, DONE
	MOVK     1,A8                ; RETURN 1 IF RESULT PARAM WAS ZERO
longend:
	RETS                         ; return to user.

****************************************************************************
* REGISTER MODEL VERSION OF LONGJMP
****************************************************************************
        .else

       ;*************************************************************
       ;*  NOTE - If direct 34082 support is used, we must restore
       ;*         the callee saved 34082 registers first. 
       ;*************************************************************
        .if      .TMS34082
        MOVD     *A0+,RA5,5          ; RESTORE CALLEE SAVED A-FILE REGS
        MOVD     *A0+,RB6,4          ; RESTORE CALLEE SAVED B-FILE REGS
        .endif

        MMFM     A0,A3,A4,A5,A6,A9,A10,A11,A12,A13,A14,SP
	ADDK     32,SP

       ;*************************************************************
       ;* FETCH RETURN PARAMETER, LOAD INTO RETURN REGISTER
       ;* NOTE : IF RETURN VALUE IS ZERO, RETURN 1 (ANSI)
       ;*************************************************************
        MOVE     A1,A8               ; MOVE RETURN VALUE INTO A8
        JRNZ     longend             ; IF NON-ZERO, DONE
	MOVK     1,A8                ; RETURN 1 IF RESULT PARAM WAS ZERO
longend:
	MOVE     *A0,A2,1            ; GET OLD RETURN ADDRESS
	JUMP     A2                  ; RETURN TO USER

        .endif
	.end
