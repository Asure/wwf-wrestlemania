	.FILE "finimg.asm"
	.OPTION B,D,L,T

	.include finiseq.glo
	.DATA
	.even

	.include finiseq.tbl
	.include finpal.asm
	.include fintbl.asm

******************************************************************************

	.even
	.include "doink.seq"

	.global	D2ST2B03

******************************************************************************

	.end

