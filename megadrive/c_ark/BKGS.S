	.data
	.globl	__bkg01_pal
__bkg01_pal:
	.dc.w	546
	.dc.w	580
	.dc.w	612
	.dc.w	614
	.dc.w	616
	.dc.w	1160
	.dc.w	1642
	.dc.w	1674
	.dc.w	110
	.dc.w	142
	.dc.w	654
	.dc.w	1166
	.dc.w	1164
	.dc.w	1676
	.dc.w	1198
	.dc.w	1710
	.globl	_backgrounds
_backgrounds:
	.dc.l	L0
	.dc.l	L1
	.dc.l	__bkg01_pal
	.bss
	.globl	_curr_bkg
	.comm	_curr_bkg,4
	.data
L1:	.dc.b	$42,$4b,$47,$30,$31,$5f,$4d,$2e,$52,$44,$43
	.dc.b	0
L0:	.dc.b	$42,$4b,$47,$30,$31,$5f,$54,$2e,$52,$44,$43
	.dc.b	0
	.text
	.globl	_load_bkgnd
_load_bkgnd:
	link	a6,#-4
	moveq.l	#12,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_backgrounds,d1
	move.l	d1,a0
	move.l	d1,_curr_bkg
	move.l	(a0),-(sp)
	pea	-4(a6)
	jsr	_get_GFS_fileaddr
	addq.w	#8,sp
	move.l	#_huge_buffer,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_RDC_Decompress
	addq.w	#8,sp
	move.l	#_huge_buffer,-(sp)
	move.w	#830,-(sp)
	move.w	#578,-(sp)
	jsr	_set_bkg_data
	addq.w	#8,sp
	move.l	_curr_bkg,a0
	move.l	4(a0),-(sp)
	pea	-4(a6)
	jsr	_get_GFS_fileaddr
	addq.w	#8,sp
	move.l	#_huge_buffer,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_RDC_Decompress
	addq.w	#8,sp
	move.w	#578,-(sp)
	move.w	#57344,-(sp)
	move.l	#_huge_buffer,-(sp)
	move.w	#28,-(sp)
	move.w	#40,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_set_bkg_tiles
	lea	16(sp),sp
	move.l	_curr_bkg,a0
	move.l	8(a0),-(sp)
	clr.w	-(sp)
	jsr	_set_colors
	unlk	a6
	rts
