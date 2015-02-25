	.text
	.globl	_prepare_gameover
_prepare_gameover:
	link	a6,#0
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d5
	moveq.l	#0,d3
L3:
	move.l	d5,a0
	cmp.w	426(a0),d3
	beq	L5
	moveq.l	#0,d4
L6:
	move.l	d5,a0
	cmp.w	424(a0),d4
	beq	L4
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	beq	L7
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#17,(a0)
L7:
	addq.w	#1,d4
	bra	L6
L4:
	addq.w	#1,d3
	bra	L3
L5:
	move.l	d5,a0
	move.w	426(a0),d0
	add.w	#23,d0
	sub.w	#17,d0
	add.w	#141,d0
	move.l	d5,a0
	move.w	d0,566(a0)
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_detonate_bomb
_detonate_bomb:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.w	10(a6),d7
	move.w	8(a6),d6
	move.l	12(a6),d5
	moveq.l	#-1,d3
L13:
	cmp.w	#2,d3
	beq	L15
	move.w	d7,d0
	add.w	d3,d0
	tst.w	d0
	blt	L14
	move.l	d5,a0
	move.w	d7,d0
	add.w	d3,d0
	cmp.w	426(a0),d0
	bcc	L14
	moveq.l	#-1,d4
L17:
	cmp.w	#2,d4
	beq	L14
	move.w	d6,d0
	add.w	d4,d0
	tst.w	d0
	blt	L18
	move.l	d5,a0
	move.w	d6,d0
	add.w	d4,d0
	cmp.w	424(a0),d0
	bcc	L18
	move.w	d7,d0
	add.w	d3,d0
	muls	#14,d0
	ext.l	d0
	move.l	d5,a0
	add.l	d0,a0
	move.w	d6,d0
	add.w	d4,d0
	ext.l	d0
	add.l	d0,a0
	move.b	#17,(a0)
	move.l	d5,a0
	add.l	#10,554(a0)
L18:
	addq.w	#1,d4
	bra	L17
L14:
	addq.w	#1,d3
	bra	L13
L15:
	move.l	#_Explode1,-(sp)
	move.w	#1,-(sp)
	jsr	_start_sound
	addq.w	#6,sp
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
	.text
	.globl	_check_plf_sprites
_check_plf_sprites:
	link	a6,#0
	movem.l	d3/d4/d5,-(sp)
	move.w	16(a6),d5
	move.l	8(a6),d4
	cmp.w	#1,d5
	bls	L24
	move.l	d4,a0
	move.w	d5,606(a0)
	moveq.l	#0,d3
L25:
	cmp.w	d5,d3
	beq	L24
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	12(a6),d1
	move.l	d1,a0
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a1
	lea	574(a1),a1
	add.l	d1,a1
	move.w	(a0),(a1)
	move.l	d4,a0
	move.w	422(a0),d0
	lsl.w	#3,d0
	move.l	d4,a0
	move.w	424(a0),d1
	subq.w	#6,d1
	lsl.w	#2,d1
	add.w	d1,d0
	move.w	d3,d1
	lsl.w	#3,d1
	moveq.l	#0,d2
	move.w	d1,d2
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d2,a0
	move.w	d0,2(a0)
	moveq.l	#3,d0
	mulu	d3,d0
	addq.w	#1,d0
	move.w	d3,d1
	lsl.w	#3,d1
	moveq.l	#0,d2
	move.w	d1,d2
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d2,a0
	move.w	d0,4(a0)
	addq.w	#1,d3
	bra	L25
L24:
	move.w	d5,d0
	beq	L23
	cmp.w	#1,d0
	beq	L23
	cmp.w	#2,d0
	beq	L32
	cmp.w	#3,d0
	beq	L38
	cmp.w	#4,d0
	beq	L44
L23:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
L44:
	moveq.l	#0,d3
L45:
	cmp.w	#4,d3
	beq	L23
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d1,a0
	move.w	#24,6(a0)
	addq.w	#1,d3
	bra	L45
L38:
	moveq.l	#0,d3
L39:
	cmp.w	#3,d3
	beq	L23
	tst.w	_curr_language
	beq	L42
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d1,a0
	move.w	#12,6(a0)
L40:
	addq.w	#1,d3
	bra	L39
L42:
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d1,a0
	move.w	#18,6(a0)
	bra	L40
L32:
	moveq.l	#0,d3
L33:
	cmp.w	#2,d3
	beq	L23
	tst.w	_curr_language
	beq	L36
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d1,a0
	move.w	#0,6(a0)
L34:
	addq.w	#1,d3
	bra	L33
L36:
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d1,a0
	addq.w	#4,2(a0)
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d4,a0
	lea	574(a0),a0
	add.l	d1,a0
	move.w	#6,6(a0)
	bra	L34
	.text
	.globl	_check_for_lines
_check_for_lines:
	link	a6,#-8
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	8(a6),d7
	moveq.l	#0,d6
	moveq.l	#0,d3
L52:
	move.l	d7,a0
	cmp.w	426(a0),d3
	beq	L54
	moveq.l	#1,d5
	moveq.l	#0,d4
L55:
	move.l	d7,a0
	cmp.w	424(a0),d4
	beq	L57
	tst.w	d5
	beq	L58
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	beq	L58
	moveq	#1,d0
L59:
	tst.w	d0
	beq	L60
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	cmp.b	#7,(a0)
	beq	L60
	moveq	#1,d0
L61:
	move.w	d0,d5
	addq.w	#1,d4
	bra	L55
L60:
	clr	d0
	bra	L61
L58:
	clr	d0
	bra	L59
L57:
	tst.w	d5
	beq	L53
	moveq.l	#0,d4
L63:
	move.l	d7,a0
	cmp.w	424(a0),d4
	beq	L65
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	move.b	0(a0,d0.l),d0
	ext.w	d0
	cmp.w	#8,d0
	beq	L68
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#17,(a0)
	move.l	d7,a0
	addq.l	#5,554(a0)
L64:
	addq.w	#1,d4
	bra	L63
L68:
	move.l	d7,-(sp)
	move.w	d3,-(sp)
	move.w	d4,-(sp)
	jsr	_detonate_bomb
	addq.w	#8,sp
	bra	L64
L65:
	move.l	d7,a0
	move.w	420(a0),d0
	add.w	d3,d0
	lsl.w	#3,d0
	move.w	d6,d1
	lsl.w	#1,d1
	moveq.l	#0,d2
	move.w	d1,d2
	move.w	d0,-8(a6,d2.l)
	addq.w	#1,d6
L53:
	addq.w	#1,d3
	bra	L52
L54:
	move.w	d6,-(sp)
	pea	-8(a6)
	move.l	d7,-(sp)
	jsr	_check_plf_sprites
	lea	10(sp),sp
	move.l	d7,a0
	move.b	#1,568(a0)
	move.w	d6,d0
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
	.data
	.text
	.globl	_clear_lines
_clear_lines:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	8(a6),d7
	moveq.l	#1,d6
	moveq.l	#0,d3
L73:
	move.l	d7,a0
	cmp.w	426(a0),d3
	beq	L75
	moveq.l	#0,d4
L76:
	move.l	d7,a0
	cmp.w	424(a0),d4
	beq	L74
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	move.b	0(a0,d0.l),d0
	ext.w	d0
	move.w	d0,d5
	cmp.w	#17,d5
	bcs	L77
	cmp.w	#23,d5
	bcc	L77
	addq.w	#1,d5
	cmp.w	#23,d5
	bne	L80
	moveq.l	#0,d5
L80:
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	d5,(a0)
	moveq.l	#0,d6
L77:
	addq.w	#1,d4
	bra	L76
L74:
	addq.w	#1,d3
	bra	L73
L75:
	tst.w	d6
	beq	L81
	move.l	d7,a0
	move.w	524(a0),d0
	and.w	#3,d0
	bne	L81
	moveq.l	#-1,d6
	move.l	d7,a0
	move.w	426(a0),d0
	subq.w	#1,d0
	move.w	d0,d3
L82:
	cmp.w	#1,d3
	beq	L84
	cmp.w	#-1,d6
	bne	L84
	moveq.l	#1,d5
	moveq.l	#0,d4
L85:
	move.l	d7,a0
	cmp.w	424(a0),d4
	beq	L87
	tst.w	d5
	beq	L88
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	bne	L88
	moveq	#1,d0
L89:
	move.w	d0,d5
	addq.w	#1,d4
	bra	L85
L88:
	clr	d0
	bra	L89
L87:
	tst.w	d5
	beq	L83
	move.w	d3,d6
L83:
	subq.w	#1,d3
	bra	L82
L84:
	cmp.w	#-1,d6
	beq	L91
	move.w	d6,d3
L92:
	tst.w	d3
	beq	L94
	moveq.l	#0,d4
L95:
	move.l	d7,a0
	cmp.w	424(a0),d4
	beq	L93
	move.w	d3,d0
	subq.w	#1,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a1
	add.l	d1,a1
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.w	#1,d4
	bra	L95
L93:
	subq.w	#1,d3
	bra	L92
L94:
	moveq.l	#0,d4
L98:
	move.l	d7,a0
	cmp.w	424(a0),d4
	beq	L100
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#0,(a0)
	addq.w	#1,d4
	bra	L98
L100:
	move.l	d7,a0
	subq.w	#1,530(a0)
L81:
	move.l	d7,a0
	cmp.w	#1,566(a0)
	bls	L102
	move.l	d7,a0
	subq.w	#1,566(a0)
L102:
	move.l	d7,a0
	move.b	#1,569(a0)
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
L91:
	move.l	d7,a0
	move.w	#0,530(a0)
	bra	L81
