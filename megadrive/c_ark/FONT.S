	.data
	.text
	.globl	_loadfont
_loadfont:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7/a3/a4,-(sp)
	move.b	17(a6),d7
	and.b	#15,d7
	and.b	#15,19(a6)
	move.w	12(a6),d0
	lsl.w	#5,d0
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
	move.l	#12582912,a3
	move.l	8(a6),a4
	move.w	14(a6),d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d3
L3:
	tst.l	d3
	beq	L2
	moveq.l	#0,d4
	move.l	a4,d0
	addq.l	#1,a4
	move.l	d0,a0
	move.b	(a0),d5
	moveq.l	#8,d6
L6:
	tst.w	d6
	beq	L8
	lsl.l	#4,d4
	clr.w	d0
	move.b	d5,d0
	and.w	#128,d0
	beq	L9
	moveq.l	#0,d0
	move.b	d7,d0
	or.l	d0,d4
L10:
	lsl.b	#1,d5
	subq.w	#1,d6
	bra	L6
L9:
	moveq.l	#0,d0
	move.b	19(a6),d0
	or.l	d0,d4
	bra	L10
L8:
	move.l	d4,(a3)
	subq.l	#1,d3
	bra	L3
L2:
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3/a4
	unlk	a6
	rts
