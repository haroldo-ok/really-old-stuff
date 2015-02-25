	.data
	.text
	.globl	_btl_stone_enm_pieces
_btl_stone_enm_pieces:
	link	a6,#-4
	movem.l	d3/d4/d5/d6,-(sp)
	move.l	8(a6),a0
	move.l	570(a0),d6
	moveq.l	#0,d5
L3:
	cmp.w	#2,d5
	beq	L2
	moveq.l	#0,d3
L6:
	cmp.w	#4,d3
	beq	L4
	moveq.l	#0,d4
L9:
	cmp.w	#4,d4
	beq	L7
	move.w	d5,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	448(a0),a0
	add.l	d1,a0
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	beq	L10
	move.w	d5,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	448(a0),a0
	add.l	d1,a0
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#7,(a0)
L10:
	addq.w	#1,d4
	bra	L9
L7:
	addq.w	#1,d3
	bra	L6
L4:
	addq.w	#1,d5
	bra	L3
L2:
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
