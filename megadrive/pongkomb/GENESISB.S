	.bss
	.globl	_extWIDTH
	.comm	_extWIDTH,2
	.text
	.globl	_init_GFX
_init_GFX:
	link	a6,#0
	move.l	a3,-(sp)
	move.l	#12582916,a3
	move.w	#32790,(a3)
	move.w	#33140,(a3)
	move.w	#33328,(a3)
	move.w	#33580,(a3)
	move.w	#33799,(a3)
	move.w	#34142,(a3)
	move.w	#34304,(a3)
	move.w	#34560,(a3)
	move.w	#34816,(a3)
	move.w	#35072,(a3)
	move.w	#35329,(a3)
	move.w	#35584,(a3)
	move.w	#35969,(a3)
	move.w	#36142,(a3)
	move.w	#36352,(a3)
	move.w	#36610,(a3)
	move.w	#36881,(a3)
	move.w	#64,_extWIDTH
	move.w	#37120,(a3)
	move.w	#37631,(a3)
	clr.w	-(sp)
	move.w	#49152,-(sp)
	move.w	#64,-(sp)
	move.w	_extWIDTH,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	clr.w	-(sp)
	move.w	#57344,-(sp)
	move.w	#64,-(sp)
	move.w	_extWIDTH,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.l	(sp)+,a3
	unlk	a6
	rts
	.text
	.globl	_put_tile
_put_tile:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.w	14(a6),d0
	mulu	_extWIDTH,d0
	add.w	12(a6),d0
	lsl.w	#1,d0
	add.w	16(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d3
	move.l	#12582916,a3
	move.l	d3,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d3,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	move.w	8(a6),d0
	or.w	10(a6),d0
	move.w	d0,(a4)
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_set_bkg_data
_set_bkg_data:
	link	a6,#0
	movem.l	d3/d4/d5,-(sp)
	move.l	12(a6),d5
	move.w	10(a6),d4
	move.w	8(a6),d0
	lsl.w	#5,d0
	move.w	d0,d3
L9:
	tst.w	d4
	beq	L8
	cmp.w	#32,d4
	bls	L12
	move.w	#1024,-(sp)
	move.w	d3,-(sp)
	move.l	d5,-(sp)
	jsr	_dma_vram_copy
	addq.w	#8,sp
	sub.w	#32,d4
L13:
	add.l	#1024,d5
	add.w	#1024,d3
	bra	L9
L12:
	move.w	d4,d0
	lsl.w	#5,d0
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	move.l	d5,-(sp)
	jsr	_dma_vram_copy
	addq.w	#8,sp
	moveq.l	#0,d4
	bra	L13
L8:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_set_bkg_tiles
_set_bkg_tiles:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7/a3/a4,-(sp)
	move.l	16(a6),d7
	move.w	10(a6),d6
	moveq.l	#0,d4
L17:
	cmp.w	14(a6),d4
	beq	L16
	move.w	d6,d0
	mulu	_extWIDTH,d0
	add.w	8(a6),d0
	lsl.w	#1,d0
	add.w	20(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d3
	move.l	#12582916,a3
	move.l	d3,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d3,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d5
L20:
	cmp.w	12(a6),d5
	beq	L22
	move.l	d7,a0
	move.w	(a0),d0
	add.w	22(a6),d0
	move.w	d0,(a4)
	addq.l	#2,d7
	addq.w	#1,d5
	bra	L20
L22:
	addq.w	#1,d6
	addq.w	#1,d4
	bra	L17
L16:
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3/a4
	unlk	a6
	rts
	.text
	.globl	_fill_bkg_rect
_fill_bkg_rect:
	link	a6,#0
	movem.l	d3/d4/d5/d6/a3/a4,-(sp)
	move.w	10(a6),d6
	moveq.l	#0,d4
L26:
	cmp.w	14(a6),d4
	beq	L25
	move.w	d6,d0
	mulu	_extWIDTH,d0
	add.w	8(a6),d0
	lsl.w	#1,d0
	add.w	16(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d3
	move.l	#12582916,a3
	move.l	d3,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d3,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d5
L29:
	cmp.w	12(a6),d5
	beq	L31
	move.w	18(a6),(a4)
	addq.w	#1,d5
	bra	L29
L31:
	addq.w	#1,d6
	addq.w	#1,d4
	bra	L26
L25:
	movem.l	(sp)+,d3/d4/d5/d6/a3/a4
	unlk	a6
	rts
	.data
	.text
	.globl	_fade_from_to
_fade_from_to:
	link	a6,#-32
	movem.l	d3-d6/a3-a5,-(sp)
	move.w	16(a6),d0
	lsl.w	#5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d6
	moveq.l	#0,d3
L35:
	cmp.w	#16,d3
	bcc	L37
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	8(a6),d1
	move.l	d1,a0
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	(a0),-32(a6,d1.l)
	addq.w	#1,d3
	bra	L35
L37:
	moveq.l	#0,d3
L38:
	cmp.w	#16,d3
	bcc	L34
	move.l	12(a6),a5
	move.l	#12582916,a3
	move.l	d6,d0
	and.l	#16383,d0
	add.l	#-16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d6,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d4
L41:
	cmp.w	#16,d4
	bcc	L43
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#3840,d0
	move.w	d0,d5
	move.w	(a5),d0
	and.w	#3840,d0
	cmp.w	d0,d5
	bcc	L44
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	add.w	#256,(a0)
L45:
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#240,d0
	move.w	d0,d5
	move.w	(a5),d0
	and.w	#240,d0
	cmp.w	d0,d5
	bcc	L47
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	add.w	#16,(a0)
L48:
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#15,d0
	move.w	d0,d5
	move.w	(a5),d0
	and.w	#15,d0
	cmp.w	d0,d5
	bcc	L50
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	addq.w	#1,(a0)
L51:
	addq.l	#2,a5
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),(a4)
	addq.w	#1,d4
	bra	L41
L50:
	move.w	(a5),d0
	and.w	#15,d0
	cmp.w	d0,d5
	bls	L51
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	subq.w	#1,(a0)
	bra	L51
L47:
	move.w	(a5),d0
	and.w	#240,d0
	cmp.w	d0,d5
	bls	L48
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	sub.w	#16,(a0)
	bra	L48
L44:
	move.w	(a5),d0
	and.w	#3840,d0
	cmp.w	d0,d5
	bls	L45
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	sub.w	#256,(a0)
	bra	L45
L43:
	moveq.l	#0,d4
L53:
	cmp.w	#4,d4
	bcc	L39
	jsr	_wait_sync
	addq.w	#1,d4
	bra	L53
L39:
	addq.w	#1,d3
	bra	L38
L34:
	movem.l	(sp)+,d3-d6/a3-a5
	unlk	a6
	rts
