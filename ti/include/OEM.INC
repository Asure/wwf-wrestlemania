;-------------------------------------------------------------------------;
;                                  TIGA                                   ;
;		Copyright (c) 1988,90 Texas Instruments Inc.		  ;
;-------------------------------------------------------------------------;
;   TMS340 Graphics Library						  ;
;-------------------------------------------------------------------------;
;  oem.inc								  ;
;									  ;
;    This is the assembly-language include file "oem.inc" for the core    ;
;    and extended primitives contained in the graphics library's          ;
;    \corprims and \extprims subdirectories.  The constants GSP_34010 and ;
;    GSP_34020 defined in this file control the conditional assembly of   ;
;    34010-compatible and 34020-specific blocks of code in a number of	  ;
;    functions.  One of the two constants, GSP_34010 or GSP_34020, must   ;
;    be set to 1, and the other to 0.  Setting GSP_34010 to 1 (and	  ;
;    GSP_34020 to 0) causes the functions to be conditionally assembled   ;
;    to generate generic TMS340x0 code that will run on both the 34010	  ;
;    and 34020.  On the other hand, setting GSP_34020 to 1 (and GSP_34010 ;
;    to 0) causes these functions to be conditionally assembled to take   ;
;    advantage of the graphics acceleration features of the 34020.  In	  ;
;    this case, the resulting code will not execute on the 34010.	  ;
;-------------------------------------------------------------------------;
;   05/18/90...Modified for TMS340 Graphics Library........J.R. Van Aken  ;
;-------------------------------------------------------------------------;
GSP_34010	.set  1 		;generic code runs on '10 and '20
GSP_34020	.set  0 		;34020-specific code

