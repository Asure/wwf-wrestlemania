****************************************************************************/
*  boot   v6.10                                                            */
*  Copyright (c) 1991  Texas Instruments Inc.                              */
****************************************************************************/

****************************************************************************/
*  BOOT.ASM                                                                */
*                                                                          */
*  This file contains the source to the run-time system initialization     */
*  for GSP C.  This is the first code executed at system reset.  The code  */
*  has several responsibilities :                                          */
*                                                                          */
*       1) Set up the system stack.                                        */
*       2) Process the runtime initialization table, if required           */
*       3) Optionally determine if a TMS34082 is present in system         */
*       4) Call the user's "main" function.                                */
*       5) At program termination, call exit.                              */
*                                                                          */
****************************************************************************/
STK	.set	A14

****************************************************************************/
* DEFINITION OF SYSTEM STACK.                                              */
* THE SIZE OF THE STACK IS DEFINED BY THE LINKER (DEFAULT SIZE 1000 BYTES).*/
* THE SIZE CAN BE SET (WITH THE LINKER) VIA THE -stack FLAG.   THE SIZE    */
* (IN BYTES) IS ASSIGNED TO THE SYMBOL __STACK_SIZE                        */
****************************************************************************/
__sys_stack .usect   ".stack",0           ; size of stack set by linker 
            .global   __STACK_SIZE        ; size of stack in bytes

****************************************************************************/
* DEFINITION OF COPROCESSOR PRESENT FLAG                                   */
****************************************************************************/
            .globl	__present82
	    .bss 	__present82,32,32

****************************************************************************/
*                                                                          */
*  C_INT00 - Initialize system upon system reset, then call user.          */
*            NOTE : This function may not have ANY local variables, since  */
*            the stack doesn't exist yet when it is called.                */
*                                                                          */
****************************************************************************/

	.globl	_c_int00
_c_int00:
************************************************************************/
* SET UP FIELD SIZE/EXTEND TO DEFAULT - 32 BITS, ZERO EXTEND (FASTER)  */
************************************************************************/
	SETF    32,0,1                 

************************************************************************/
* INITIALIZE THE STACK POINTERS TO BEGINNING AND END OF STACK.         */
* "__STACK_SIZE" SYMBOL REPRESENTS SIZE OF STACK IN BYTES.             */
* SINCE WE'RE FIDDLING WITH THE STACK POINTERS, DISABLE INTERRUPTS     */
************************************************************************/
        DINT                                
	MOVI	__sys_stack,STK     ; Set up program stack
	MOVI    __STACK_SIZE-4,SP   ; Load size of stack (in bytes)
	SLL     3,SP                ; Convert size from bytes to bits
	ADD     STK,SP              ; Calculate top of system stack
	EINT

*************************************************************************/
* MOVE ADDRESS OF BEGINNING AND END OF INIT TABLE TO POINTERS.          */
* IF POINTER TO INITIALIZATION TABLE IS NOT -1, PROCESS TABLES BY       */
* PLACING POINTER TO TABLE IN A0 , AND CALL var_init.                   */
*************************************************************************/
	MOVI    cinit,A0 
	CMPI	-1,A0 
	JRZ	L1
	CALLR	var_init            ; PROCESS INITIALIZATION TABLES 
L1:

*************************************************************************/
* SET UP RUNTIME SWITCH FOR CONDITIONAL 82 USE.                         */
*  IF PRESENT, INITIALIZE '82 CONFIG REG                                */
*************************************************************************/
        .if     .TMS340_IEEE & .TMS34020
	.globl  _check82
	CALLA   _check82
        MOVE    A8,@__present82,1

        MOVE    A8,A8
	JRZ     NO_82
        MOVI	28h,A8        ; DEFAULT: ROUND TO NEAREST, NO EXCEPTIONS
    	MOVE	A8,CCONFIG
NO_82:
	.else   
	CLRS    A8            ; CAN'T USE '82 WITH 34010
        MOVE    A8,@__present82,1
        .endif

*************************************************************************/
* CALL USER FUNCTION _main                                              */
*************************************************************************/
	CALLA	_main                   ; And Awaaaaaaaay we go!!!

*************************************************************************/
* IF THE USER'S PROGRAM RETURNED, ASSUME A SUCCESSFULL EXECUTION, AND   */
* INVOKE exit(1).                                                       */
*************************************************************************/
	MOVK	1,A0                    
	    .if     .TMS340_MEMPARM
	    MOVE    STK,-*SP,1          ; CALL EXIT
	    MOVE    A0,*STK+,1
	    .endif
	CALLA	_exit

exit:   JR      exit       ; WE SHOULD NEVER GET HERE, BUT HANG IF WE DO */


****************************************************************************/
*                                                                          */
*  VAR_INIT - Handle processing of the program initialization tables.      */
*                                                                          */
****************************************************************************/

*****************************************************************************/
* RECORDS ARE IN THE FOLLOWING FORMAT                                       */
*                                                                           */
*   typedef struct {                                                        */
*                    unsigned short length;      /* LENGTH OF DATA IN WORDS */
*                    unsigned short *destin;     /* DESTINATION ADDRESS     */
*                    short data[<length>];       /* DATA TO BE COPIED       */
*                  } *LIST_REC;                                             */
*                                                                           */
*   register unsigned short *ptr;                /* POINTER INTO INIT TABLE */
*   register unsigned short *dest_ptr;                                      */
*   register int             count;                                         */
*                                                                           */
*   ptr = (unsigned short *)init_table;         /* SET TO START OF INIT TAB */
*   for (;;)                                                                */
*   {                                                                       */
*      dest_ptr = ((LIST_REC)ptr)->destin;                                  */
*      if ((count = ((LIST_REC)ptr)->length) == 0) return;                  */
*                                                                           */
*      for (ptr += 3; count; count--) *dest_ptr++ = *ptr++;                 */
*   }                                                                       */
*                                                                           */
*****************************************************************************/

*****************************************************************************/
* POINTER TO INIT TABLE IS PASSED IN A0.                                    */
*****************************************************************************/
var_init:
	SETF	16,0

*****************************************************************************/
* READ DESTINATION ADDRESS AND COUNT FROM TABLE IF COUNT IS ZERO, QUIT
* SOURCE IMMEDIATELY FOLLOWS COUNT IN MEMORY 
*****************************************************************************/
L2:
	MOVE	*A0+,A1            ; GET NUMBER OF WORDS TO MOVE 
	JRZ	EPI0_2             ; IF 0, WE ARE DONE.
	MOVE	*A0+,A2,1          ; GET POINTER TO DESTINATION ADDR
				   ; A0 NOW POINTS TO SOURCE DATA

*****************************************************************************/
* MOVE DATA FROM SOURCE TO DESTINATION ADDRESS
*****************************************************************************/
L4:     MOVE	*A0+,*A2+
        DSJ	A1,L4
        JR	L2                 ; PROCESS NEXT INIT RECORD

EPI0_2: RETS

*****************************************************************************/
* UNDEFINED REFERENCES                                                      */
*****************************************************************************/
	.ref	_exit
	.ref	_main
	.ref    cinit
	.end

