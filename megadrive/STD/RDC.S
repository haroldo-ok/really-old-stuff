	.text
	.globl	_RDC_Decompress_aux
_RDC_Decompress_aux:
	link	a6,#-14
	movem.l	d3/d4/d5/d6/d7/a3/a4/a5,-(sp)
	move.l	14(a6),d6
	moveq.l	#0,d4
	move.l	8(a6),a0
	move.l	(a0),a3
	move.l	d6,a0
	move.l	(a0),a4
	moveq.l	#0,d0
	move.w	12(a6),d0
	add.l	a3,d0
	move.l	d0,-8(a6)
L3:
	cmp.l	-8(a6),a3
	bcc	L4
	move.w	d4,d0
	lsr.w	#1,d0
	move.w	d0,d4
	bne	L5
	clr.w	d0
	move.b	(a3)+,d0
	move.w	d0,d7
	clr.w	d0
	move.b	(a3)+,d0
	asl.w	#8,d0
	or.w	d0,d7
	move.w	#32768,d4
L5:
	move.w	d7,d0
	and.w	d4,d0
	bne	L6
	move.b	(a3)+,(a4)+
	bra	L3
L6:
	clr.w	d0
	move.b	(a3),d0
	asr.w	#4,d0
	and.w	#15,d0
	move.w	d0,-10(a6)
	clr.w	d0
	move.b	(a3),d0
	and.w	#15,d0
	move.w	d0,d3
	addq.l	#1,a3
	move.w	-10(a6),d0
	beq	L9
	cmp.w	#1,d0
	beq	L13
	cmp.w	#2,d0
	beq	L17
	move.w	d3,d0
	addq.w	#3,d0
	move.w	d0,d5
	clr.w	d0
	move.b	(a3)+,d0
	asl.w	#4,d0
	add.w	d0,d5
	moveq.l	#0,d0
	move.w	d5,d0
	move.l	a4,d1
	sub.l	d0,d1
	move.l	d1,a5
	move.w	-10(a6),d3
L22:
	tst.w	d3
	beq	L3
	move.b	(a5)+,(a4)+
	subq.w	#1,d3
	bra	L22
L17:
	move.w	d3,d0
	addq.w	#3,d0
	move.w	d0,d5
	clr.w	d0
	move.b	(a3)+,d0
	asl.w	#4,d0
	add.w	d0,d5
	clr.w	d0
	move.b	(a3)+,d0
	move.w	d0,d3
	add.w	#16,d3
	moveq.l	#0,d0
	move.w	d5,d0
	move.l	a4,d1
	sub.l	d0,d1
	move.l	d1,a5
L18:
	tst.w	d3
	beq	L3
	move.b	(a5)+,(a4)+
	subq.w	#1,d3
	bra	L18
L13:
	clr.w	d0
	move.b	(a3)+,d0
	asl.w	#4,d0
	add.w	d0,d3
	add.w	#19,d3
L14:
	tst.w	d3
	beq	L16
	move.b	(a3),(a4)+
	subq.w	#1,d3
	bra	L14
L16:
	addq.l	#1,a3
	bra	L3
L9:
	addq.w	#3,d3
L10:
	tst.w	d3
	beq	L12
	move.b	(a3),(a4)+
	subq.w	#1,d3
	bra	L10
L12:
	addq.l	#1,a3
	bra	L3
L4:
	move.l	d6,a0
	move.l	a4,d0
	sub.l	(a0),d0
	move.w	d0,d3
	move.l	8(a6),a0
	move.l	a3,(a0)
	move.l	d6,a0
	move.l	a4,(a0)
	move.w	d3,d0
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3/a4/a5
	unlk	a6
	rts
	.data
	.text
	.globl	_RDC_Decompress
_RDC_Decompress:
	link	a6,#-4
	movem.l	d3/d4/d5,-(sp)
	moveq.l	#1,d4
L28:
	tst.w	d4
	beq	L27
	move.l	8(a6),d0
	addq.l	#1,8(a6)
	move.l	d0,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,d4
	move.l	8(a6),d0
	addq.l	#1,8(a6)
	move.l	d0,a0
	clr.w	d0
	move.b	(a0),d0
	asl.w	#8,d0
	or.w	d0,d4
	tst.w	d4
	beq	L28
	tst.w	d4
	bge	L31
	move.w	d4,d0
	neg.w	d0
	move.w	d0,d5
	move.w	d0,d3
L32:
	tst.w	d3
	beq	L28
	move.l	8(a6),d0
	addq.l	#1,8(a6)
	move.l	d0,a0
	move.l	12(a6),d0
	addq.l	#1,12(a6)
	move.l	d0,a1
	move.b	(a0),(a1)
	subq.w	#1,d3
	bra	L32
L31:
	pea	12(a6)
	move.w	d4,-(sp)
	pea	8(a6)
	jsr	_RDC_Decompress_aux
	lea	10(sp),sp
	move.w	d0,d5
	bra	L28
L27:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
