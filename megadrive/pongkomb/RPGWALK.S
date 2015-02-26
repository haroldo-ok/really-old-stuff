	.text
	.globl	_init_walker
_init_walker:
	link	a6,#0
	movem.l	d3/d4,-(sp)
	move.w	12(a6),d4
	move.l	8(a6),d3
	move.l	d3,a0
	move.w	#0,(a0)
	move.l	d3,a0
	move.w	#0,2(a0)
	move.l	d3,a0
	move.w	#0,4(a0)
	move.l	d3,a0
	move.w	#0,6(a0)
	move.l	d3,a0
	move.w	#0,8(a0)
	move.l	d3,a0
	move.w	#1,10(a0)
	move.l	d3,a0
	move.w	#64,12(a0)
	move.l	d3,a0
	move.w	#1,14(a0)
	move.l	d3,a0
	move.w	#1,16(a0)
	move.l	d3,a0
	move.b	#1,18(a0)
	move.l	d3,a0
	move.w	#1,20(a0)
	move.l	d3,a0
	move.w	#1,22(a0)
	move.l	d3,a0
	move.w	d4,24(a0)
	move.l	d3,a0
	move.w	d4,26(a0)
	move.l	d3,a0
	move.w	#0,28(a0)
	move.l	d3,a0
	move.b	#10,30(a0)
	move.l	d3,a0
	move.b	#10,31(a0)
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.data
	.globl	_frame_step_mapping
_frame_step_mapping:
	.dc.w	0
	.dc.w	8
	.dc.w	0
	.dc.w	16
	.globl	_frame_dir_mapping
_frame_dir_mapping:
	.dc.w	72
	.dc.w	0
	.dc.w	24
	.dc.w	48
	.text
	.globl	_handle_walker
_handle_walker:
	link	a6,#0
	move.l	d3,-(sp)
	move.l	8(a6),d3
	move.l	d3,a0
	tst.w	12(a0)
	beq	L5
	move.l	d3,a0
	tst.w	16(a0)
	bne	L7
	move.l	d3,a0
	move.l	d3,a1
	move.w	8(a0),d0
	add.w	d0,(a1)
	move.l	d3,a0
	move.l	d3,a1
	move.w	10(a0),d0
	add.w	d0,2(a1)
	move.l	d3,a0
	subq.w	#1,12(a0)
	move.l	d3,a0
	move.l	d3,a1
	move.w	14(a0),16(a1)
L5:
	move.l	(sp)+,d3
	unlk	a6
	rts
L7:
	move.l	d3,a0
	subq.w	#1,16(a0)
	bra	L5
	.text
	.globl	_draw_walker
_draw_walker:
	link	a6,#0
	move.l	d3,-(sp)
	move.l	8(a6),d3
	move.l	d3,a0
	move.w	28(a0),d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_frame_step_mapping,d1
	move.l	d1,a0
	move.l	d3,a1
	move.w	26(a1),d0
	add.w	(a0),d0
	move.l	d3,a0
	move.w	22(a0),d1
	moveq.l	#13,d2
	lsl.w	d2,d1
	or.w	d0,d1
	move.w	d1,-(sp)
	move.w	#1792,-(sp)
	move.l	d3,a0
	move.w	2(a0),-(sp)
	move.l	d3,a0
	move.w	(a0),-(sp)
	move.l	d3,a0
	move.w	20(a0),-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	move.l	d3,a0
	tst.w	12(a0)
	beq	L12
	move.l	d3,a0
	tst.b	30(a0)
	bne	L13
	move.l	d3,a0
	addq.w	#1,28(a0)
	move.l	d3,a0
	cmp.w	#4,28(a0)
	bne	L14
	move.l	d3,a0
	move.w	#0,28(a0)
L14:
	move.l	d3,a0
	move.l	d3,a1
	move.b	31(a0),30(a1)
L11:
	move.l	(sp)+,d3
	unlk	a6
	rts
L13:
	move.l	d3,a0
	subq.b	#1,30(a0)
	bra	L11
L12:
	move.l	d3,a0
	move.w	#0,28(a0)
	bra	L11
	.text
	.globl	_walker_checkbaseframe
_walker_checkbaseframe:
	link	a6,#0
	move.l	8(a6),a0
	clr.w	d0
	move.b	18(a0),d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_frame_dir_mapping,d1
	move.l	d1,a0
	move.l	8(a6),a1
	move.w	24(a1),d0
	add.w	(a0),d0
	move.l	8(a6),a0
	move.w	d0,26(a0)
	unlk	a6
	rts
	.data
	.text
	.globl	_walker_walkto
_walker_walkto:
	link	a6,#0
	movem.l	d3/d4,-(sp)
	move.w	14(a6),d4
	move.l	8(a6),d3
	move.w	12(a6),d0
	beq	L25
	cmp.w	#1,d0
	beq	L26
	cmp.w	#2,d0
	beq	L27
	cmp.w	#3,d0
	beq	L28
L22:
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
L28:
	move.l	d3,a0
	move.b	13(a6),18(a0)
	move.l	d3,a0
	move.w	#1,8(a0)
	move.l	d3,a0
	move.w	#0,10(a0)
	move.w	d4,d0
	lsl.w	#4,d0
	move.l	d3,a0
	move.w	d0,12(a0)
	move.l	d3,-(sp)
	jsr	_walker_checkbaseframe
	addq.w	#4,sp
	bra	L22
L27:
	move.l	d3,a0
	move.b	13(a6),18(a0)
	move.l	d3,a0
	move.w	#-1,8(a0)
	move.l	d3,a0
	move.w	#0,10(a0)
	move.w	d4,d0
	lsl.w	#4,d0
	move.l	d3,a0
	move.w	d0,12(a0)
	move.l	d3,-(sp)
	jsr	_walker_checkbaseframe
	addq.w	#4,sp
	bra	L22
L26:
	move.l	d3,a0
	move.b	13(a6),18(a0)
	move.l	d3,a0
	move.w	#0,8(a0)
	move.l	d3,a0
	move.w	#1,10(a0)
	move.w	d4,d0
	lsl.w	#4,d0
	move.l	d3,a0
	move.w	d0,12(a0)
	move.l	d3,-(sp)
	jsr	_walker_checkbaseframe
	addq.w	#4,sp
	bra	L22
L25:
	move.l	d3,a0
	move.b	13(a6),18(a0)
	move.l	d3,a0
	move.w	#0,8(a0)
	move.l	d3,a0
	move.w	#-1,10(a0)
	move.w	d4,d0
	lsl.w	#4,d0
	move.l	d3,a0
	move.w	d0,12(a0)
	move.l	d3,-(sp)
	jsr	_walker_checkbaseframe
	addq.w	#4,sp
	bra	L22
