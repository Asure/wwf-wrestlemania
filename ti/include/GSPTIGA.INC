;-------------------------------------------------------------------------;
;                                  TIGA                                   ;
;        Copyright (c) 1988-1990  Texas Instruments Incorporated.         ;
;			   All Rights Reserved				  ;
;-------------------------------------------------------------------------;
;   TMS340 Graphics Library						  ;
;-------------------------------------------------------------------------;
;                                                                         ;
;  file            gsptiga.inc (GSP Assembler version of tiga.h)          ;
;                                                                         ;
;  description     This file contains references to TIGA core functions   ;
;                  It is needed for the gsp side of an application,       ;
;                  written in GSP-Assembler, which invokes TIGA core      ;
;                  functions.                                             ;
;                                                                         ;
;-------------------------------------------------------------------------;
;   04/23/90...Deleted functions not in graphics library....J.R. Van Aken ;
;-------------------------------------------------------------------------;

;-------------------------------------------------------------------------;
;  Reference Core Primitives                                              ;
;-------------------------------------------------------------------------;
        .globl    _clear_frame_buffer
        .globl    _clear_page
        .globl    _clear_screen
        .globl    _cpw
        .globl    _get_colors
        .globl    _get_config
        .globl    _get_fontinfo 
        .globl    _get_nearest_color
        .globl    _get_offscreen_memory
        .globl    _get_palet
        .globl    _get_palet_entry
        .globl    _get_pmask
        .globl    _get_ppop
        .globl    _get_transp
        .globl    _get_vector
        .globl    _get_vector
        .globl    _get_windowing
        .globl    _get_wksp
        .globl    _gsp2gsp
        .globl    _init_palet
        .globl    _init_text
        .globl    _lmo
        .globl    _page_busy
        .globl    _page_flip
        .globl    _peek_breg
        .globl    _poke_breg
        .globl    _rmo
        .globl    _set_bcolor
        .globl    _set_clip_rect
        .globl    _set_colors
        .globl    _set_fcolor
        .globl    _set_palet
        .globl    _set_palet_entry
        .globl    _set_pmask
        .globl    _set_ppop
        .globl    _set_transp         ;defined only for 34020
        .globl    _set_vector
        .globl    _set_windowing
        .globl    _set_wksp
        .globl    _text_out
        .globl    _text_outp
        .globl    _transp_off
        .globl    _transp_on
        .globl    _wait_scan

;-------------------------------------------------------------------------;
; Colors of the default TIGA palet                                        ;
;-------------------------------------------------------------------------;
BLACK           .set    0
BLUE            .set    1
GREEN           .set    2
CYAN            .set    3
RED             .set    4
MAGENTA         .set    5
BROWN           .set    6
LIGHT_GRAY      .set    7
DARK_GRAY       .set    8
LIGHT_BLUE      .set    9
LIGHT_GREEN     .set    10
LIGHT_CYAN      .set    11
LIGHT_RED       .set    12
LIGHT_MAGENTA   .set    13
YELLOW          .set    14
WHITE           .set    15


