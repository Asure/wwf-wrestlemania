/*-----------------------------------------------------------------------*/
/*                                 TIGA                                  */
/*       Copyright (c) 1988-1990 Texas Instruments Incorporated.         */
/*                         All Rights Reserved                           */
/*-----------------------------------------------------------------------*/
/*  TIGA - Header file                                                   */
/*-----------------------------------------------------------------------*/
/*                                                                       */
/*  file            gspreg.h                                             */
/*                                                                       */
/*  description     This is a C header file that defines symbolic        */
/*                  names for A- and B-file registers, and for I/O       */   
/*                  registers in the 34010 and 34020.  It can be         */
/*                  included in the C source code for a GSP-resident     */    
/*                  code module.                                         */
/*                                                                       */
/*-----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------*/
/* Names of special A- and B-file registers                              */
/*-----------------------------------------------------------------------*/
#define FP     13    /* register A13 - Frame pointer, param. stack       */  
#define STK    14    /* register A14 - Parameter stack pointer           */
#define SADDR  0     /* register B0   - Source address register          */
#define SPTCH  1     /* register B1   - Source pitch register            */
#define DADDR  2     /* register B2   - Dest. address register           */
#define DPTCH  3     /* register B3   - Dest. pitch register             */
#define OFFSET 4     /* register B4   - XY offset register               */
#define WSTART 5     /* register B5   - Window start register            */
#define WEND   6     /* register B6   - Window end register              */
#define DYDX   7     /* register B7   - Delta X/delta Y register         */
#define COLOR0 8     /* register B8   - Color 0 register                 */
#define COLOR1 9     /* register B9   - Color 1 register                 */
#define MADDR  10    /* register B10 - 34020 mask address                */
#define MPTCH  11    /* register B11 - 34020 mask pitch                  */
#define PATTRN 13    /* register B13 - 34020 pattern                     */
                                                                         
/*-----------------------------------------------------------------------*/
/* Define base location of TMS340s on-chip I/O register file.            */
/*-----------------------------------------------------------------------*/
#define IO_BASE   0xC0000000  /* address of 1st I/O register             */
                  				                                                       
/*-----------------------------------------------------------------------*/
/* Define names of I/O registers common to 34010 and 34020.              */
/*-----------------------------------------------------------------------*/
#define DPYCTL    0xC0000080  /* display control                         */
#define DPYSTRT   0xC0000090  /* display start address                   */
#define DPYINT    0xC00000A0  /* display interrupt vertical count        */
#define CONTROL   0xC00000B0  /* control                                 */
#define HSTDATA   0xC00000C0  /* host interface data                     */
#define HSTADRL   0xC00000D0  /* host interface address low              */
#define HSTADRH   0xC00000E0  /* host interface address high             */
#define HSTCTLL   0xC00000F0  /* host interface control low              */
#define HSTCTLH   0xC0000100  /* host interface control high             */
#define INTENB    0xC0000110  /* interrupt enable                        */
#define INTPEND   0xC0000120  /* interrupt pending                       */
#define CONVSP    0xC0000130  /* conversion factor, source pitch         */
#define CONVDP    0xC0000140  /* conversion factor, dest'n pitch         */
#define PSIZE     0xC0000150  /* pixel size                              */
#define PMASK     0xC0000160  /* plane mask                              */
#define DPYTAP    0xC00001B0  /* display tap point                       */
#define DPYADR    0xC00001E0  /* display address                         */
#define REFCNT    0xC00001F0  /* DRAM refresh count                      */

/*-----------------------------------------------------------------------*/
/* Define names of display interrupt control bits common to 34010/20.    */
/*-----------------------------------------------------------------------*/
#define DIE       (INTENB+10) /* display interrupt enable bit            */
#define DIP       (INTPEND+10)/* display interrupt pending bit           */
                                                                         
/*-----------------------------------------------------------------------*/
/* Masks for I/O register fields common to 34010/20                      */
/*-----------------------------------------------------------------------*/
#define TRN_MASK  0x0020      /* Mask for T field in CONTROL             */
#define WDW_MASK  0x00C0      /* Mask for W field in CONTROL             */
#define PBH_MASK  0x0100      /* Mask for Pixblt Horiz. Dir. in CONTROL  */
#define PBV_MASK  0x0200      /* Mask for Pixblt Vert.  Dir. in CONTROL  */ 
#define PPOP_MASK 0x7C00      /* Mask for PPOP in CONTROL                */
#define SRT_MASK  0x0800      /* Mask for SRT bit in DPYCTL              */
#define SRE_MASK  0x1000      /* Mask for SRE bit in DPYCTL              */
#define ENV_MASK  0x8000      /* Mask for ENV bit in DPYCTL              */
#define DI_MASK   0x0400      /* Mask for DI bit in INTPEND              */
                              
/*-----------------------------------------------------------------------*/
/* 34010-specific I/O register names.                                    */
/*-----------------------------------------------------------------------*/
#define HESYNC10  0xC0000000   /* horizontal end sync                    */
#define HEBLNK10  0xC0000010   /* horizontal end blank                   */
#define HSBLNK10  0xC0000020   /* horizontal start blank                 */
#define HTOTAL10  0xC0000030   /* horizontal total                       */
#define VESYNC10  0xC0000040   /* vertical end sync                      */
#define VEBLNK10  0xC0000050   /* vertical end blank                     */
#define VSBLNK10  0xC0000060   /* vertical start blank                   */
#define VTOTAL10  0xC0000070   /* vertical total                         */
#define HCOUNT10  0xC00001C0   /* horizontal count                       */
#define VCOUNT10  0xC00001D0   /* vertical count                         */
                                                                         
/*-----------------------------------------------------------------------*/
/* 34020-specific I/O register names.                                    */
/*-----------------------------------------------------------------------*/
#define VESYNC20  0xC0000000   /* vertical end sync                      */
#define HESYNC20  0xC0000010   /* horizontal end sync                    */
#define VEBLNK20  0xC0000020   /* vertical end blank                     */
#define HEBLNK20  0xC0000030   /* horizontal end blank                   */
#define VSBLNK20  0xC0000040   /* vertical start blank                   */
#define HSBLNK20  0xC0000050   /* horizontal start blank                 */
#define VTOTAL20  0xC0000060   /* vertical total                         */
#define HTOTAL20  0xC0000070   /* horizontal total                       */
#define CONVMP20  0xC0000180   /* conversion factor, mask pitch          */
#define CONTROL20 0xC0000190   /* control                                */
#define CONFIG20  0xC00001A0   /* configuration                          */
#define VCOUNT20  0xC00001C0   /* vertical count                         */
#define HCOUNT20  0xC00001D0   /* horizontal count                       */
#define DPYST20   0xC0000200   /* display start (32-bit)                 */
#define DPYNX20   0xC0000220   /* display next (32-bit)                  */
#define DINC20    0xC0000240   /* display increment (32-bit)             */
#define HESERR20  0xC0000270   /* horizontal end serration               */
#define SCOUNT20  0xC00002C0   /* shift clock count                      */
#define BSFLTST20 0xC00002D0   /* bus fault status                       */
#define DPYMASK20 0xC00002E0   /* display mask                           */
#define SETVCNT20 0xC0000300   /* set vertical count                     */
#define SETHCNT20 0xC0000310   /* set horizontal count                   */
#define BSFLTD20  0xC0000320   /* bus fault data                         */
                                                                         
/*-----------------------------------------------------------------------*/
/* GSP part number fields in code produced by REV instruction            */
/*-----------------------------------------------------------------------*/
#define REV_34010 3            /* REV bit number if 34010                */
#define REV_34020 4            /* REV bit number if 34020                */
#define REV_MASK  0xFFF8       /* GSP part number mask                   */

