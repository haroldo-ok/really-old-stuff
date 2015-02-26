	.data
	.globl	__title1_pal
__title1_pal:
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	512
	.dc.w	512
	.dc.w	512
	.dc.w	1024
	.dc.w	1024
	.dc.w	1024
	.dc.w	1536
	.dc.w	1536
	.dc.w	1536
	.dc.w	2048
	.dc.w	2560
	.dc.w	3072
	.globl	__title2_pal
__title2_pal:
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	512
	.dc.w	1024
	.dc.w	1536
	.dc.w	2560
	.dc.w	0
	.dc.w	1024
	.dc.w	1536
	.dc.w	2048
	.dc.w	514
	.dc.w	1538
	.dc.w	518
	.dc.w	10
	.globl	__title3_pal
__title3_pal:
	.dc.w	0
	.dc.w	0
	.dc.w	32
	.dc.w	64
	.dc.w	512
	.dc.w	512
	.dc.w	2560
	.dc.w	3584
	.dc.w	1024
	.dc.w	544
	.dc.w	3072
	.dc.w	3584
	.dc.w	4
	.dc.w	10
	.dc.w	1542
	.dc.w	2152
	.globl	__gameover_pal
__gameover_pal:
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	2
	.dc.w	2
	.dc.w	6
	.dc.w	8
	.dc.w	8
	.dc.w	8
	.dc.w	10
	.dc.w	10
	.dc.w	12
	.dc.w	12
	.dc.w	14
	.dc.w	14
	.globl	_backgrounds
_backgrounds:
	.dc.l	L0
	.dc.l	L1
	.dc.l	__title1_pal
	.dc.l	L2
	.dc.l	L3
	.dc.l	__title2_pal
	.dc.l	L4
	.dc.l	L5
	.dc.l	__title3_pal
	.dc.l	L6
	.dc.l	L7
	.dc.l	__gameover_pal
	.bss
	.globl	_curr_bkg
	.comm	_curr_bkg,4
	.globl	_huge_buffer
	.comm	_huge_buffer,35840
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
	move.w	#1120,-(sp)
	move.w	#256,-(sp)
	jsr	_set_bkg_data
	addq.w	#8,sp
	move.l	_curr_bkg,a0
	move.l	4(a0),-(sp)
	pea	-4(a6)
	jsr	_get_GFS_fileaddr
	addq.w	#8,sp
	move.w	#256,-(sp)
	move.w	#57344,-(sp)
	move.l	-4(a6),-(sp)
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
	.data
L7:	.dc.b	$47,$41,$4d,$45,$4f,$56,$45,$52,$2e,$4d,$41
	.dc.b	$50
	.dc.b	0
L6:	.dc.b	$47,$41,$4d,$45,$4f,$56,$45,$52,$2e,$52,$44
	.dc.b	$43
	.dc.b	0
L5:	.dc.b	$54,$49,$54,$4c,$45,$33,$2e,$4d,$41,$50
	.dc.b	0
L4:	.dc.b	$54,$49,$54,$4c,$45,$33,$2e,$52,$44,$43
	.dc.b	0
L3:	.dc.b	$54,$49,$54,$4c,$45,$32,$2e,$4d,$41,$50
	.dc.b	0
L2:	.dc.b	$54,$49,$54,$4c,$45,$32,$2e,$52,$44,$43
	.dc.b	0
L1:	.dc.b	$54,$49,$54,$4c,$45,$31,$2e,$4d,$41,$50
	.dc.b	0
L0:	.dc.b	$54,$49,$54,$4c,$45,$31,$2e,$52,$44,$43
	.dc.b	0
	.text
	.globl	_load_bkgnd_dly
_load_bkgnd_dly:
	link	a6,#0
	move.w	8(a6),-(sp)
	jsr	_load_bkgnd
	move.w	10(a6),(sp)
	jsr	_wait_delay
	unlk	a6
	rts
