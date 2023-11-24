/*-----------------------------------------------------------------------*/
/*                                 TIGA                                  */
/*       Copyright (c) 1988-1990 Texas Instruments Incorporated.         */
/*                         All Rights Reserved                           */
/*-----------------------------------------------------------------------*/
/*  TMS340 Graphic Library						 */
/*-----------------------------------------------------------------------*/
/*                                                                       */
/*  file            gsptiga.h (GSP-C equivalent of tiga.h)               */
/*                                                                       */
/*  description     This file contains references to TIGA core functions */
/*                  It is needed for the gsp side of an application,     */
/*                  written in GSP-C, which invokes TIGA core functions. */
/*                                                                       */
/*-----------------------------------------------------------------------*/
/*  04/23/90...Deleted functions not in graphics library..J. R. Van Aken */
/*-----------------------------------------------------------------------*/

/*----------------------------------------------------------------------*/
/*  Reference Core Primitives                                           */
/*----------------------------------------------------------------------*/
extern clear_frame_buffer();
extern clear_page();
extern clear_screen();
extern cpw();
extern get_colors();
extern get_config();
extern get_fontinfo();
extern get_nearest_color();
extern get_offscreen_memory();
extern get_palet();
extern get_palet_entry();
extern get_pmask();
extern get_ppop();
extern get_transp();
extern get_vector();
extern get_windowing();
extern get_wksp();
extern gsp2gsp();
extern init_palet();
extern init_text();
extern lmo();
extern page_busy();
extern page_flip();
extern peek_breg();
extern poke_breg();
extern rmo();
extern set_bcolor();
extern set_clip_rect();
extern set_colors();
extern set_fcolor();
extern set_palet();
extern set_palet_entry();
extern set_pmask();
extern set_ppop();
extern set_transp();	 /* implemented for 34020 only */
extern set_vector();
extern set_windowing();
extern set_wksp();
extern text_out();
extern text_outp();
extern transp_off();
extern transp_on();
extern wait_scan();

/*----------------------------------*/
/* Colors of the default TIGA palet */
/*----------------------------------*/
#define  BLACK          0
#define  BLUE           1
#define  GREEN          2
#define  CYAN           3
#define  RED            4
#define  MAGENTA        5
#define  BROWN          6
#define  LIGHT_GRAY     7
#define  DARK_GRAY      8
#define  LIGHT_BLUE     9
#define  LIGHT_GREEN    10
#define  LIGHT_CYAN     11
#define  LIGHT_RED      12
#define  LIGHT_MAGENTA  13
#define  YELLOW         14
#define  WHITE          15

