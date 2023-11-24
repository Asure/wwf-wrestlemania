;-------------------------------------------------------------------------;
;                                  TIGA                                   ;
;        Copyright (c) 1988-1990  Texas Instruments Incorporated.         ;
;			   All Rights Reserved				  ;
;-------------------------------------------------------------------------;
;   TIGA - Include file                                                   ;
;-------------------------------------------------------------------------;
;                                                                         ;      
;  file            gspglobs.inc (GSP Assembly version of gspglobs.h)      ;
;                                                                         ;
;  description     This file contains references to global variables      ;
;                  used in the Graphics Manager portion of TIGA.          ;
;                  It is needed for the gsp side of an application,       ;
;                  written in GSP-Assembler, which accesses TIGA global   ;
;                  variables.                                             ;
;                                                                         ;
;-------------------------------------------------------------------------;
;   04/23/90...Deleted functions not used in graphics lib...J.R. Van Aken ;
;-------------------------------------------------------------------------;
    .globl  _bottom_of_stack
    .globl  _config
    .globl  _DEFAULT_PALET
    .globl  _end_of_dram
    .globl  _env
    .globl  _envtext
    .globl  _modeinfo
    .globl  _monitorinfo
    .globl  _offscreen
    .globl  _page
    .globl  _palet
    .globl  _pattern
    .globl  _setup
    .globl  _sin_tbl
    .globl  _stack_size
    .globl  _start_of_dram
    .globl  _sysfont
               
