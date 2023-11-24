/*-----------------------------------------------------------------------*/
/*                                 TIGA                                  */
/*       Copyright (c) 1988-1990 Texas Instruments Incorporated.         */
/*                         All Rights Reserved                           */
/*-----------------------------------------------------------------------*/
/*  TMS340 Graphics Library						 */
/*-----------------------------------------------------------------------*/
/*                                                                       */
/*  file            gsptypes.h (GSP-C version of typedefs.h)             */
/*                                                                       */
/*  description     This file contains type definitions used in          */ 
/*                  the Graphics Manager.                                */
/*                  This file should be included in any GSP-c program    */
/*                  accessing data of these types.                       */
/*                                                                       */
/*-----------------------------------------------------------------------*/
/*   04/23/90...Deleted typedefs not used in graphics lib..J.R. Van Aken */
/*-----------------------------------------------------------------------*/
#ifndef GSPTYPES_H
#define GSPTYPES_H
/*--------------------------------------------------------------------------*/
/*  Define integral data types                                              */
/*--------------------------------------------------------------------------*/
typedef unsigned char   uchar;
typedef unsigned short  ushort;
typedef unsigned long   ulong;
typedef uchar           *PTR;
typedef unsigned long   HPTR;

/*--------------------------------------------------------------------------*/
/*  BITMAP structure definition                                             */
/*                                                                          */
/*      This structure contains information describing a bitmap.            */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    PTR     addr;    /* Starting address */
    ushort  pitch;   /* Pitch in bits    */
    ushort  xext;    /* X extent         */
    ushort  yext;    /* Y extent         */
    ushort  psize;   /* Pixel Size       */
} BITMAP;            

/*--------------------------------------------------------------------------*/
/*  PATTERN structure definition                                            */
/*                                                                          */
/*      This structure contains pattern description information.            */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    ushort  width;          /* width of pattern    */
    ushort  height;         /* height of pattern   */
    ushort  depth;          /* depth (bits/pixel)  */
    PTR     data;           /* pointer to data     */
    int     (*hsrv)();      /* pointer to horz fill routine */
    int     (*srv)();       /* pointer to general fill routine */
} PATTERN;

/*--------------------------------------------------------------------------*/
/*  PALET structure definition                                              */
/*                                                                          */
/*      This structure contains the rgb and intensity components for a      */
/*      palette entry.                                                      */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    uchar   r;
    uchar   g;
    uchar   b;
    uchar   i;
} PALET;

/*--------------------------------------------------------------------------*/
/*  OFFSCREEN structure definitions                                         */
/*                                                                          */
/*      These structures contain definitions of offscreen work areas        */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    PTR     addr;   /* address in gsp space of an offscreen work area */
    ushort  xext;   /* x extension in the current screen pixel size   */
    ushort  yext;   /* y extension using default screen pitch         */
} OFFSCREEN_AREA;

/*--------------------------------------------------------------------------*/
/*  MODEINFO structure definition                                           */
/*                                                                          */
/*      This structure contains information pertaining to the current mode  */ 
/*      of operation.                                                       */
/*--------------------------------------------------------------------------*/
typedef struct
{
    ulong   disp_pitch;         /* display pitch y::x                   */
    ushort  disp_vres;          /* vertical resolution (pixels)         */
    ushort  disp_hres;          /* horizontal resolution (pixels)       */
    short   screen_wide;        /* screen width                         */
    short   screen_high;        /* screen height                        */
    ushort  disp_psize;         /* pixel size                           */
    ulong   pixel_mask;         /* pixel mask                           */
    ushort  palet_gun_depth;    /* # of bits per gun                    */    
    ulong   palet_size;         /* number of palette entries            */
    short   palet_inset;        /* offset from frame start to data      */ 
    ushort  num_pages;          /* number of display pages              */
    short   num_offscrn_areas;  /* number off offscreen work areas      */
    ulong   wksp_addr;          /* address of offscreen workspace       */
    ulong   wksp_pitch;         /* pitch of offscreen workspace         */
    ushort  vram_block_write;   /* flag for VRAM block write capability */
} MODEINFO;

/*--------------------------------------------------------------------------*/
/*  CONFIG structure definition                                             */
/*                                                                          */
/*      This structure contains the current hardware operating              */
/*      configuration.                                                      */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    ushort      version_number;
    ulong       comm_buff_size;
    ulong       sys_flags;
    ulong       device_rev;
    ushort      num_modes;
    ushort      current_mode;
    ulong       program_mem_start;
    ulong       program_mem_end;
    ulong       display_mem_start;
    ulong       display_mem_end;
    ulong       stack_size;
    ulong       shared_mem_size;
    HPTR        shared_host_addr;
    PTR         shared_gsp_addr;
    MODEINFO    mode;
} CONFIG;

/*--------------------------------------------------------------------------*/
/*  ENVIRONMENT structure definition                                        */
/*                                                                          */
/*      This structure contains the current values of environment global    */
/*      variables.                                                          */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    ulong   xyorigin;      /* xy drawing origin      */
    ulong   pensize;       /* pensize height::width  */
    BITMAP  *srcbm;        /* source bitmap struct   */
    BITMAP  *dstbm;        /*   dest bitmap struct   */
    ulong   stylemask;     /* styled line patn mask  */
} ENVIRONMENT;

/*-----------------------------------------------------------------------*/
/* params data structure definition                                      */
/*                                                                       */
/*   Data structure for storage of parameters for filled pie arc.        */
/*                                                                       */
/*-----------------------------------------------------------------------*/
struct params 
{
     short width;
     short height;   /* dimensions of rect. containing oval */
     short xnorm;
     short ynorm;    /* normalized arc starting coordinates */
     short xcount;
     short ycount;   /* counters for movement in x and y */
     short xcoord;
     short ycoord;   /* actual arc starting coordinates */
     short deltax;
     short deltay;   /* x and y increments */
     short patn;     /* 1 => pattern fill, 0 => solid fill */
};

/*----------------------------------------------------------------------*/
/*  FONT structure definition                                           */
/*                                                                      */
/*  This structure defines the data associated with a font              */
/*----------------------------------------------------------------------*/
typedef struct
{
    ushort magic;        /* font type code                               */
    long   length;       /* Length of font in bytes                      */
    char   facename[30];
    short  deflt;	 /* ASCII code of default character		 */
    short  first;        /* ASCII code of first character                */
    short  last;         /* ASCII code of last character                 */
    short  maxwide;      /* maximum character width                      */
    short  maxkern;      /* maximum character kerning amount             */
    short  charwide;     /* Width of characters (0 if proportional)      */
    short  avgwide;      /* Average width of characters                  */
    short  charhigh;     /* character height                             */
    short  ascent;       /* ascent (how far above base line)             */
    short  descent;      /* descent (how far below base line)            */
    short  leading;      /* leading (row bottom to next row top)         */
    long   rowpitch;     /* bits per row of char patterns                */
    long   oPatnTbl;     /* Bit offset to PatnTbl (from bof)             */
    long   oLocTbl;      /* Bit offset to LocTbl (from bof)              */
    long   oOwTbl;       /* Bit offset to OWTbl (from bof)               */
} FONT;

/*----------------------------------------------------------------------*/
/*  FONTINFO   structure definition                                     */
/*----------------------------------------------------------------------*/
typedef struct
{
    char  facename[30];
    short deflt;	/* ASCII code of default character		*/
    short first;        /* ASCII code of first character                */
    short last;         /* ASCII code of last character                 */
    short maxwide;      /* maximum character width                      */
    short avgwide;      /* Average width of characters                  */
    short maxkern;      /* Max character kerning amount                 */
    short charwide;     /* Width of characters (0=proportional)         */
    short charhigh;     /* character height                             */
    short ascent;       /* ascent (how far above base line)             */
    short descent;      /* descent (how far below base line)            */
    short leading;      /* leading (row bottom to next row top)         */
    FONT  *fontptr;     /* address of font in gsp memory                */
    short id;           /* id of font (set at install time)             */
} FONTINFO;

/*----------------------------------------------------------------------*/
/*  ENVTEXT structure definition                                        */
/*                                                                      */
/*  This structure defines the data associated with the text environment*/
/*----------------------------------------------------------------------*/
typedef struct
{
    short installed;    /* Number of fonts installed                    */
    short allocated;    /* Number of slots allocated                    */
    FONT  **font;       /* Pointer to installed fonts                   */
    FONT  *selected;    /* Currently selected font address              */
    short align;        /* Alignment (relative to baseline or topleft)  */
    short charextra;    /* Additional intercharacter spacing            */
    long  effects;	/* Special effects				*/
    short xposn;	/* Current x position				*/
    short yposn;	/* Current y position				*/
} ENVTEXT;

/*--------------------------------------------------------------------------*/
/*  PAGE structure definitions						    */
/*                                                                          */
/*      These structures contain definitions used to implement multiple     */
/*      display pages.  The information in these structures is used to      */
/*      display a given page.                                               */
/*--------------------------------------------------------------------------*/
typedef struct 
{
    ulong   BaseAddr;	/* Base address of start of page		*/
    ulong   DpyStart;	/* Value loaded in Display Start i/o register	*/
} PAGE;

/*--------------------------------------------------------------------------*/
/*  MONITORINFO10 structure definition                                      */
/*                                                                          */
/*      Note this definition is specific to the 34010                       */
/*      This structure contains video timing parameters.                    */
/*--------------------------------------------------------------------------*/
typedef struct
{
    ushort  hesync10;
    ushort  heblnk10;
    ushort  hsblnk10;
    ushort  htotal10;
    ushort  vesync10;
    ushort  veblnk10;
    ushort  vsblnk10;
    ushort  vtotal10;
    ushort  dpyctl10;
    ushort  screen_delay10;
    ushort  flags10;
} MONITORINFO10;

/*--------------------------------------------------------------------------*/
/*  MONITORINFO20 structure definition                                      */
/*                                                                          */
/*      Note this definition is specific to the 34020                       */
/*      This structure contains video timing parameters.                    */
/*--------------------------------------------------------------------------*/
typedef struct
{
    ushort  vesync20;
    ushort  hesync20;
    ushort  veblnk20;
    ushort  heblnk20;
    ushort  vsblnk20;
    ushort  hsblnk20;
    ushort  vtotal20;
    ushort  htotal20;
    ushort  dpyctl20;
    ushort  dincl20;
    ushort  dinch20;
    ushort  heserr20;
    ushort  dpymsk20;
    ushort  screen_delay20;
    ushort  flags20;
} MONITORINFO20;

#endif

