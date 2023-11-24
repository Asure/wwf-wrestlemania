/*-----------------------------------------------------------------------*/
/*                                 TIGA                                  */
/*       Copyright (c) 1988-1990 Texas Instruments Incorporated.         */
/*                         All Rights Reserved                           */
/*-----------------------------------------------------------------------*/
/*  TMS340 Graphics Library						 */
/*-----------------------------------------------------------------------*/
/*                                                                       */
/*  file            gspglobs.h                                           */
/*                                                                       */
/*  description     This file contains references to global variables    */
/*                  used in the Graphics Manager portion of TIGA.        */
/*                  It is needed for the gsp side of an application,     */
/*                  written in GSP-C, which accesses TIGA global         */
/*                  variables.                                           */
/*                  typedefs.h header file MUST be included before this  */
/*                  header file.                                         */
/*-----------------------------------------------------------------------*/
/*  03/15/90...Changed sysfont to (FONT *).................J.R. Van Aken */
/*  04/23/90...Eliminated globals not in graphics library..J.R. Van Aken */
/*-----------------------------------------------------------------------*/
extern long             bottom_of_stack;    /* Declared in link file     */   
extern CONFIG           config;             /* Current configuration     */
extern PALET            DEFAULT_PALET[16];  /* Default palette           */
extern long             end_of_dram;        /* Declared in link file     */
extern ENVIRONMENT      env;                /* Environment variables     */
extern ENVTEXT          envtext;            /* Text environment          */
extern MODEINFO         *modeinfo;          /* Operating mode info       */
extern uchar            *monitorinfo;       /* Monitor timing info       */
extern OFFSCREEN_AREA   *offscreen;         /* Pointer to current data   */
extern PAGE		*page;		    /* Pointer to current data	 */
extern PALET            palet[];            /* Current palette in use    */
extern PATTERN          pattern;            /* Current pattern information */
extern uchar            *setup;             /* Current setup pointer     */
extern ushort           sin_tbl[];          /* Sine lookup table         */
extern long             stack_size;         /* Declared in link file     */
extern long             start_of_dram;      /* Declared in link file     */
extern FONT		*sysfont;	    /* System font		 */

