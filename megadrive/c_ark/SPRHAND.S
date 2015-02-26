	.bss
	.globl	_huge_buffer
	.comm	_huge_buffer,35840
	.text
	.globl	_sprite_init
_sprite_init:
	link	a6,#0
	move.l	d3,-(sp)
	move.l	8(a6),d3
	move.l	d3,a0
	move.w	12(a6),(a0)
	move.l	d3,a0
	move.w	14(a6),2(a0)
	move.l	d3,a0
	move.w	16(a6),4(a0)
	move.l	d3,a0
	move.w	18(a6),6(a0)
	move.l	d3,a0
	move.w	20(a6),8(a0)
	move.l	d3,a0
	move.w	22(a6),10(a0)
	move.l	d3,a0
	move.w	#0,12(a0)
	move.l	d3,a0
	move.w	#0,14(a0)
	move.l	d3,a0
	move.w	#0,16(a0)
	move.l	d3,a0
	move.w	#0,18(a0)
	move.l	d3,a0
	move.w	#1,20(a0)
	move.l	d3,a0
	move.w	#0,22(a0)
	move.l	d3,a0
	move.w	#0,24(a0)
	move.l	d3,a0
	move.w	#0,26(a0)
	move.l	d3,a0
	move.w	#0,28(a0)
	move.l	d3,a0
	move.w	#0,30(a0)
	move.l	d3,a0
	move.w	#0,32(a0)
	move.l	d3,a0
	move.w	#0,34(a0)
	move.l	d3,a0
	move.w	#0,36(a0)
	move.l	d3,a0
	move.w	#0,38(a0)
	move.l	d3,a0
	move.w	#0,40(a0)
	move.l	(sp)+,d3
	unlk	a6
	rts
	.text
	.globl	_sprite_move
_sprite_move:
	link	a6,#0
	movem.l	d3/a3,-(sp)
	move.l	8(a6),a3
	move.w	18(a3),d0
	add.w	d0,16(a3)
	move.w	16(a3),d0
	asr.w	#8,d0
	ext.w	d0
	move.w	14(a3),d1
	sub.w	d0,d1
	move.w	d1,d3
	tst.w	20(a3)
	beq	L6
L7:
	tst.w	d3
	bge	L9
	add.w	20(a3),d3
	bra	L7
L9:
	cmp.w	20(a3),d3
	bcs	L6
	sub.w	20(a3),d3
	bra	L9
L6:
	move.w	d3,14(a3)
	and.w	#255,16(a3)
	move.w	28(a3),d0
	add.w	d0,24(a3)
	move.w	38(a3),d0
	add.w	d0,34(a3)
	tst.w	30(a3)
	beq	L11
	tst.w	24(a3)
	beq	L11
	move.w	24(a3),d3
	cmp.w	30(a3),d3
	ble	L12
	move.w	30(a3),d3
L13:
	move.w	d3,24(a3)
L11:
	tst.w	40(a3)
	beq	L15
	tst.w	34(a3)
	beq	L15
	move.w	34(a3),d3
	cmp.w	40(a3),d3
	ble	L16
	move.w	40(a3),d3
L17:
	move.w	d3,34(a3)
L15:
	tst.w	26(a3)
	beq	L19
	tst.w	24(a3)
	beq	L19
	move.w	24(a3),d3
	tst.w	d3
	bge	L20
	add.w	26(a3),d3
	tst.w	d3
	ble	L22
	moveq.l	#0,d3
L22:
	move.w	d3,24(a3)
L19:
	tst.w	36(a3)
	beq	L25
	tst.w	34(a3)
	beq	L25
	move.w	34(a3),d3
	tst.w	d3
	bge	L26
	add.w	36(a3),d3
	tst.w	d3
	ble	L28
	moveq.l	#0,d3
L28:
	move.w	d3,34(a3)
L25:
	move.w	24(a3),d0
	add.w	d0,22(a3)
	move.w	22(a3),d0
	asr.w	#8,d0
	ext.w	d0
	add.w	d0,2(a3)
	and.w	#255,22(a3)
	move.w	34(a3),d0
	add.w	d0,32(a3)
	move.w	32(a3),d0
	asr.w	#8,d0
	ext.w	d0
	add.w	d0,4(a3)
	and.w	#255,32(a3)
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
L26:
	tst.w	d3
	ble	L28
	sub.w	36(a3),d3
	tst.w	d3
	bge	L28
	moveq.l	#0,d3
	bra	L28
L20:
	tst.w	d3
	ble	L22
	sub.w	26(a3),d3
	tst.w	d3
	bge	L22
	moveq.l	#0,d3
	bra	L22
L16:
	move.w	40(a3),d0
	neg.w	d0
	cmp.w	d0,d3
	bge	L17
	move.w	40(a3),d0
	neg.w	d0
	move.w	d0,d3
	bra	L17
L12:
	move.w	30(a3),d0
	neg.w	d0
	cmp.w	d0,d3
	bge	L13
	move.w	30(a3),d0
	neg.w	d0
	move.w	d0,d3
	bra	L13
	.text
	.globl	_sprite_draw
_sprite_draw:
	link	a6,#0
	move.l	a3,-(sp)
	move.l	8(a6),a3
	move.w	8(a3),d0
	add.w	12(a3),d0
	move.w	10(a3),d1
	mulu	14(a3),d1
	add.w	d1,d0
	move.w	d0,-(sp)
	move.w	6(a3),-(sp)
	move.w	4(a3),-(sp)
	move.w	2(a3),-(sp)
	move.w	(a3),-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	move.l	(sp)+,a3
	unlk	a6
	rts
	.text
	.globl	_sprite_prepare
_sprite_prepare:
	link	a6,#0
	move.l	d3,-(sp)
	moveq.l	#1,d3
L37:
	cmp.w	#80,d3
	beq	L36
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	#-16,-(sp)
	move.w	#-16,-(sp)
	move.w	d3,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	addq.w	#1,d3
	bra	L37
L36:
	move.l	(sp)+,d3
	unlk	a6
	rts
	.data
	.text
	.globl	_tileset_load_RDC
_tileset_load_RDC:
	link	a6,#-8
	move.l	8(a6),-(sp)
	pea	-8(a6)
	pea	-4(a6)
	jsr	_get_GFS_file
	lea	12(sp),sp
	move.l	#_huge_buffer,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_RDC_Decompress
	addq.w	#8,sp
	move.l	#_huge_buffer,-(sp)
	move.w	14(a6),-(sp)
	move.w	12(a6),-(sp)
	jsr	_set_bkg_data
	unlk	a6
	rts
