/****************************************************************************/
/*  memory.c v6.10							    */
/*  Copyright (c) 1991  Texas Instruments Incorporated                      */
/****************************************************************************/

/*****************************************************************************/
/*									     */
/*  This module contains the functions which implement the dynamic memory    */
/*  management routines for GSP C.  The following assumptions/rules apply:   */
/*									     */
/*   1) Packets are allocated a minimum of 64 bits                           */
/*   2) The size of the heap is set at link time, using the -heap flag       */
/*      The allocation and sizing of the heap is a cooperative effort        */
/*      involving the linker, this file, and "sysmem.asm".                   */
/*   3) The heap can be reset at any time by calling the function "minit"    */
/*									     */
/*  The following items are defined in this module :			     */
/*    minit()	 : Function to initialize dynamic memory management	     */
/*    malloc()	 : Function to allocate memory from mem mgmt system.	     */
/*    calloc()	 : Allocate an clear memory from mem mgmt system.	     */
/*    realloc()  : Reallocate a packet					     */
/*    free()	 : Function to free allocated memory.			     */
/*---------------------------------------------------------------------------*/
/*    minsert()  : Insert a packet into free list, sorted by size	     */
/*    mremove()  : Remove a packet from the free list.			     */
/*    sys_free	 : Pointer to free list 				     */
/*									     */
/*****************************************************************************/
#include <stdlib.h>
#include <string.h>

/*---------------------------------------------------------------------------*/
/* "PACKET" is the template for a data packet.  Packet size contains         */
/* the number of bytes allocated for the user, excluding the size	     */
/* required for management of the packet (32 bits).  Packets are always      */
/* allocated memory in long words.  Therefore, the lowest order bit of the   */
/* size field is used to indicate whether the packet is free(0) or used(1).  */
/* The size_ptr fields is used to manage the free list, and is a pointer     */
/* to the next element in the free list.  The free list is sorted by size.   */
/*---------------------------------------------------------------------------*/
typedef struct pack {
		      unsigned int packet_size;	 /* number of bytes        */
		      struct pack  *size_ptr;    /* next elem in free list */
		    } PACKET;

/*---------------------------------------------------------------------------*/
/*  _SYSMEM_SIZE is declared as an absolute external label.  By taking its   */
/*  "address" here in the C file, we get the actual value assigned to the    */
/*   symbol, which is the size of the system memory area.                    */
/*                                                                           */
/*  NOTE: _SYSMEM_SIZE is assigned a value by the linker via the -heap flag. */
/*---------------------------------------------------------------------------*/
extern int _SYSMEM_SIZE;
#define MEMORY_SIZE ((int)&_SYSMEM_SIZE) 

/*---------------------------------------------------------------------------*/
/* SYS_FREE - This variable is a pointer to the free list.                   */
/*---------------------------------------------------------------------------*/
extern char _sys_memory[];
static PACKET *sys_free = (PACKET *)_sys_memory;

/*---------------------------------------------------------------------------*/
/* Function declarations                                                     */
/*---------------------------------------------------------------------------*/
static void minsert(PACKET *);         /* insert a packet into the free list */
static void mremove(PACKET *);         /* delete packet from the free list   */

void minit(void);         
void free(void *);
void *malloc(size_t); 
void *calloc(size_t, size_t);
void *realloc(void *, size_t);


/*****************************************************************************/
/*									     */
/*  MINSERT - Insert a packet into the free list.  This list is sorted by    */
/*	      size in increasing order. 				     */
/*									     */
/*****************************************************************************/
static void minsert(PACKET *ptr)
{
    register PACKET *current = (PACKET *) sys_free;
    register PACKET *last    = NULL;

    /********************************************************************/
    /* CHECK SPECIAL CASE, EMPTY FREE LIST.				*/
    /********************************************************************/
    if (current == NULL)
    {
        sys_free = ptr;
        ptr->size_ptr = NULL;
        return;
    }

    /********************************************************************/
    /* SCAN THROUGH LIST, LOOKING FOR A LARGER PACKET.			*/
    /********************************************************************/
    while ((current != NULL) && (current->packet_size < ptr->packet_size))
    {
	last	= current;
	current = current->size_ptr;
    }

    /********************************************************************/
    /* LINK THE NEW PACKET INTO THE LIST. THERE ARE THREE CASES :	*/
    /*	 THE NEW POINTER WILL EITHER BE THE FIRST, THE LAST, OR IN THE	*/
    /*	 MIDDLE SOMEWHERE.						*/
    /********************************************************************/
    if (current == NULL) 	 /* PTR WILL BE LAST IN LIST */
    {
        last->size_ptr = ptr;
        ptr->size_ptr  = NULL;
    }

    else if (last == NULL)	 /* PTR WILL BE FIRST IN THE LIST */
    {
        ptr->size_ptr  = sys_free;
        sys_free       = ptr;
    }

    else			 /* PTR IS IN THE MIDDLE OF THE LIST */
    {
        ptr->size_ptr  = current;
        last->size_ptr = ptr;
    }
 }


/*****************************************************************************/
/*									     */
/* MREMOVE - REMOVE AN ITEM FROM THE FREE LIST. 			     */
/*									     */
/*****************************************************************************/
static void mremove(PACKET *ptr)
{
    register PACKET *current = sys_free;
    register PACKET *last    = NULL;

    /********************************************************************/
    /* SCAN THROUGH LIST, LOOKING FOR PACKET TO REMOVE			*/
    /********************************************************************/
    while ((current != NULL) && (current != ptr))
    {
	last	= current;
	current = current->size_ptr;
    }

    /********************************************************************/
    /* REMOVE THE PACKET FROM THE LIST.   THERE ARE TWO CASES : 	*/
    /*	 THE OLD POINTER WILL EITHER BE THE FIRST, OR NOT THE FIRST.	*/
    /********************************************************************/
    if (current == NULL) 	 /* POINTER NOT FOUND IN LIST		*/
       sys_free = NULL;		 /* FATAL ERROR 			*/

    else if (last == NULL)	 /* PTR WAS BE FIRST IN THE LIST	*/
       sys_free = ptr->size_ptr;

    else			 /* PTR IS IN THE MIDDLE OF THE LIST	*/
       last->size_ptr = ptr->size_ptr;
}


/*****************************************************************************/
/*									     */
/*  MINIT - This function can be called by the user to completely reset the  */
/*	    memory management system.					     */
/*									     */
/*****************************************************************************/
void minit(void)
{
    /************************************************************************/
    /* TO INITIALIZE THE MEMORY SYSTEM, SET UP THE FREE LIST TO POINT TO    */
    /* THE ENTIRE HEAP, AND INITIALIZE HEAP TO A SINGLE EMPTY PACKET.       */
    /************************************************************************/
    sys_free = (PACKET *)_sys_memory;

    sys_free->packet_size = MEMORY_SIZE - 4;
    sys_free->size_ptr	  = NULL;
}


/*****************************************************************************/
/*									     */
/*  MALLOC - Allocate a packet of a given size, and return pointer to it.    */
/*	     This function only allocates in multiple of long words.	     */
/*									     */
/*****************************************************************************/
void *malloc(size_t size)
{
    register PACKET *current = sys_free;
    register unsigned int    newsize;
    register unsigned int    oldsize;

    if (size <= 0) return 0;
    newsize = (size + 3);	  /* ROUND SIZE UP TO NEXT LONG SIZE  */
    newsize >>= 2;
    if ((newsize <<= 2) <= 0) newsize = 4;

    /***********************************************************************/
    /* SCAN THROUGH FREE LIST FOR PACKET LARGE ENOUGH TO CONTAIN PACKET    */
    /***********************************************************************/
    while ((current != NULL) && (current->packet_size < newsize))
       current = current->size_ptr;

    if (current == NULL) return 0;

    else
    {
       oldsize = current->packet_size;	 /* REMEMBER OLD SIZE		 */
       mremove(current);		 /* REMOVE PACKET FROM FREE LIST */

       /******************************************************************/
       /* IF PACKET IS LARGER THAN NEEDED, FREE EXTRA SPACE AT END	 */
       /* BY INSERTING REMAINING SPACE INTO FREE LIST.			 */
       /******************************************************************/
       if (oldsize - newsize > 8)
       {
	  register PACKET *next;
	  next = (PACKET *) ((char *) current + 4 + newsize);
	  next->packet_size = oldsize - newsize - 4;
	  minsert(next);
	  current->packet_size = newsize + 1;
       }
       else current->packet_size = oldsize + 1;

       return &(current->size_ptr);
    }
 }


/*****************************************************************************/
/*									     */
/*  CALLOC - Allocate a packet of a given size, set the data in the packet   */
/*	     to nulls, and return a pointer to it.			     */
/*									     */
/*****************************************************************************/
void *calloc(size_t num, size_t size)
{
    register int  i	   = size * num;
    register int  *current = malloc(i);
    register char *save    = (char *)current;

    if (current == 0) return 0;

    i = (i + 3) >> 2;  /* ROUND UP BYTE COUNT TO NEXT LONG BOUNDARY */

    while (i--) *current++ = 0;
    return save;
}




/*****************************************************************************/
/*									     */
/*  REALLOC - Reallocate a packet to a new size.			     */
/*									     */
/*****************************************************************************/
void *realloc(void *packet, size_t size)
{
    register char *pptr =(char *) packet - 4; /* POINT TO BEGINNING OF PACKET */
    register int   newsize = (int)size + 3;   /* NEW SIZE OF PACKET	   */
    register int   oldsize;

    if (size < 0)      return 0;
    if (packet == 0)   return(malloc(size));
    if (size == 0)   { free(packet);  return(0); }

    newsize >>= 2;
    newsize <<= 2;			   /* ROUND SIZE UP TO NEXT LONG   */
    if (newsize <= 0) newsize = 4;

    oldsize = ((PACKET *)pptr)->packet_size;
    if ((oldsize & 1) == 0)   return(0);
    if (newsize == --oldsize) return(packet);

    /****************************************************************/
    /* IF NEW SIZE IS LESS THAN CURRENT PACKET SIZE,		    */
    /* TRUNCATE THE PACKET AND RETURN END TO FREE LIST		    */
    /****************************************************************/
    if (newsize < oldsize)
    {
       if (oldsize - newsize < 8) return(packet);
       ((PACKET *)pptr)->packet_size = newsize + 1; /* SET NEW PACKET SIZE   */
       oldsize -= newsize + 4;			    /* CALC TRAILING SIZE    */
       pptr    += newsize + 4;			    /* SET PTR TO NEW PACKET */
       ((PACKET *)pptr)->packet_size = oldsize + 1; /* SET TRAILING PACKET   */
       free(pptr + 4); 			            /* FREE TRAILING PACKET  */
       return(packet);
    }

    /****************************************************************/
    /* IF NEW SIZE IS BIGGER THAN CURRENT PACKET,		    */
    /*	1) CHECK NEXT PACKET IN LIST, SEE IF PACKET CAN BE EXPANDED */
    /*	2) IF NOT, MOVE PACKET TO NEW LOCATION. 		    */
    /****************************************************************/
    else
    {
	PACKET *next = (PACKET *)(pptr + oldsize + 4);
	int     temp;

	if (((char *)next < &_sys_memory[MEMORY_SIZE - 4]) &&
	   ((next->packet_size & 1) == 0) 		          &&
	   ((temp = oldsize + next->packet_size + 4 - newsize) >= 0))
	{
	    mremove(next);
	    if (temp < 8)
	    {
	       ((PACKET *)pptr)->packet_size = newsize + temp + 1;
	       return(packet);
	    }

	    ((PACKET *)pptr)->packet_size = newsize + 1;
	    pptr += newsize + 4;
	    ((PACKET *)pptr)->packet_size = temp - 4;
	    minsert((PACKET *)pptr);
	    return(packet);
	}
	else
	{
	    /************************************************************/
	    /* ALLOCATE NEW PACKET AND MOVE DATA INTO IT. 	      */
	    /************************************************************/
	    register char *new = malloc(size);
	    if (new == 0) return (0);
	    memcpy(new, pptr + 4, oldsize);
	    free(packet);
	    return(new);
	}
    }
}


/*****************************************************************************/
/*									     */
/*  FREE - Return a packet allocated by malloc to free memory pool.	     */
/*	   Return 0 if successful, -1 if not successful.		     */
/*									     */
/*****************************************************************************/
void free(void *packet)
{
    register char *ptr = (char *)packet;
    register int mask = ~1;	 /* USED TO MASK OUT USED BIT */
    register PACKET *last;	 /* POINT TO PREVIOUS PACKET  */
    register PACKET *current;	 /* POINTER TO THIS PACKET    */
    register PACKET *next;	 /* POINTER TO NEXT PACKET    */

    if (ptr == NULL) return;
    last = next = NULL;		 /* INITIALIZE POINTERS 		*/
    ptr -= 4;			 /* ADJUST POINT TO BEGINNING OF PACKET */

    current = (PACKET *)_sys_memory;

    /*********************************************************************/
    /* SEARCH FOR THE POINTER IN THE PACKET POINTED TO			 */
    /*********************************************************************/
    while (current < (PACKET *) ptr)
    {
        last = current;
        current = (PACKET *)((char *)current + (current->packet_size & mask)+ 4);
    }

    /*********************************************************************/
    /* CHECK FOR POINTER OR PACKET ERRORS.				 */
    /*********************************************************************/
    if ((current != (PACKET *) ptr) || (!(current->packet_size & 1)))
         return;

    current->packet_size &= mask;   /* MARK PACKET AS FREE */

    /*********************************************************************/
    /* GET POINTER TO NEXT PACKET IN MEMORY, IF ANY.			 */
    /*********************************************************************/
    next = (PACKET *) ((char *)current + 4 + current->packet_size);
    if (next > (PACKET *) &_sys_memory[MEMORY_SIZE - 4]) next = NULL;

    /*********************************************************************/
    /* ATTEMPT TO COLLESCE THE THREE PACKETS (PREVIOUS, CURRENT, NEXT)	 */
    /*********************************************************************/
    if ((last != NULL) && !(last->packet_size & 1))
    {
       if ((next != NULL) && !(next->packet_size & 1))
       {
	  mremove(last);
	  mremove(next);
	  last->packet_size += current->packet_size + next->packet_size + 8;
	  minsert(last);
	  return;
       }
       else
       {
	  mremove(last);
	  last->packet_size += current->packet_size + 4;
	  minsert(last);
	  return;
       }
    }

    /*********************************************************************/
    /* ATTEMPT TO COLLESCE THE CURRENT WITH NEXT PACKET. (CURRENT, NEXT) */
    /*********************************************************************/
    else if ((next != NULL) && !(next->packet_size & 1))
    {
       mremove(next);
       current->packet_size += next->packet_size + 4;
       minsert(current);
       return;
    }

    /*********************************************************************/
    /* NO COLLESCENCE POSSIBLE, JUST INSERT THIS PACKET INTO LIST	 */
    /*********************************************************************/
    else minsert(current);
}


