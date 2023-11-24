****************************************************************
* SYSMEM   v6.10   - System memory allocation                  *
* Copyright (c) 1991 Texas Instruments Incorporated            *
****************************************************************
*                                                              *
* This module declares the memory area used by the memory      *
* allocation functions malloc(), etc.  The size and placement  *
* of this memory area is done in the linker (using section     *
* directives and the -heap flag).  The minimum size is 64 bits,*
* used in the case of an empty heap.                           *
*                                                              *
* NOTE 1:This mechanism works in cooperation with "memory.c"   *
*        and the GSP linker.  If an alternate (custom) memory  *
*        allocation scheme is used this file may need to be    *
*        modified or discarded.                                *
*                                                              *
* NOTE 2:This file will only be linked in if any of the memory *
*        allocation functions are used in the program! (or if  *
*        you reference __sys_memory for some reason)           *
*                                                              *
****************************************************************
	       .global __SYSMEM_SIZE   ; DEFINED BY LINKER

****************************************************************
* Define the heap memory area.  Note that 64 is a minimum size *
* which can be overridden in the linker (with -heap flag)      *
****************************************************************
	       .global __sys_memory
__sys_memory   .usect  ".sysmem",64    ; Define "heap" memory

****************************************************************
* GENERATE AN AUTOINITIALIZATION RECORD TO INITIALIZE HEAP.    *
* This code assumes that "__sys_memory" contains a structure   *
* of type PACKET (as defined in "memory.c").                   *
* The purpose of this is to initialize the heap into one (big) *
* free packet of size "__SYSMEM_SIZE-4".  This is equivalent   *
* to calling minit() at boot time.                             *
****************************************************************
	       .sect   ".cinit"
	       .field  4,16             ; LENGTH OF INIT DATA   
               .long   __sys_memory     ; WHAT TO INITIALIZE

	       .long   __SYSMEM_SIZE-4  ; SIZE OF FREE PACKET
	       .long   0                ; NEXT PACKET IN FREE LIST

****************************************************************
*            END OF AUTOINITIALIZATION RECORD                  *
****************************************************************

