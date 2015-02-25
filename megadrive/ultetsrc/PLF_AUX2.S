	.text
	.globl	_update_pcs
_update_pcs:
	link	a6,#0
	move.l	d3,-(sp)
	move.l	8(a6),d3
	move.l	d3,a0
	move.l	d3,a1
	move.w	512(a0),516(a1)
	move.l	d3,a0
	move.l	d3,a1
	move.w	514(a0),518(a1)
	move.l	d3,a0
	move.b	444(a0),d0
	ext.w	d0
	move.l	d3,a0
	add.w	516(a0),d0
	tst.w	d0
	bge	L3
	move.l	d3,a0
	move.b	444(a0),d0
	ext.w	d0
	neg.w	d0
	move.l	d3,a0
	move.w	d0,516(a0)
L2:
	move.l	(sp)+,d3
	unlk	a6
	rts
L3:
	move.l	d3,a0
	move.b	445(a0),d0
	ext.w	d0
	move.l	d3,a0
	add.w	516(a0),d0
	move.l	d3,a0
	move.w	424(a0),d1
	subq.w	#1,d1
	cmp.w	d1,d0
	bls	L2
	move.l	d3,a0
	move.b	445(a0),d0
	ext.w	d0
	move.l	d3,a0
	move.w	424(a0),d1
	sub.w	d0,d1
	subq.w	#1,d1
	move.l	d3,a0
	move.w	d1,516(a0)
	bra	L2
	.text
	.globl	_update_piece_w
_update_piece_w:
	link	a6,#0
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d5
	move.l	d5,a0
	move.b	#3,444(a0)
	move.l	d5,a0
	move.b	#0,445(a0)
	move.l	d5,a0
	move.b	#3,446(a0)
	move.l	d5,a0
	move.b	#0,447(a0)
	moveq.l	#0,d3
L9:
	cmp.w	#4,d3
	beq	L11
	moveq.l	#0,d4
L12:
	cmp.w	#4,d4
	beq	L10
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	beq	L13
	move.l	d5,a0
	move.b	444(a0),d0
	ext.w	d0
	cmp.w	d0,d4
	bcc	L16
	move.l	d5,a0
	move.b	d4,444(a0)
L16:
	move.l	d5,a0
	move.b	445(a0),d0
	ext.w	d0
	cmp.w	d0,d4
	bls	L17
	move.l	d5,a0
	move.b	d4,445(a0)
L17:
	move.l	d5,a0
	move.b	446(a0),d0
	ext.w	d0
	cmp.w	d0,d3
	bcc	L18
	move.l	d5,a0
	move.b	d3,446(a0)
L18:
	move.l	d5,a0
	move.b	447(a0),d0
	ext.w	d0
	cmp.w	d0,d3
	bls	L13
	move.l	d5,a0
	move.b	d3,447(a0)
L13:
	addq.w	#1,d4
	bra	L12
L10:
	addq.w	#1,d3
	bra	L9
L11:
	move.l	d5,-(sp)
	jsr	_update_pcs
	addq.w	#4,sp
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_check_piece_pos
_check_piece_pos:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	8(a6),d7
	move.l	d7,a0
	move.l	d7,a1
	move.w	514(a0),518(a1)
	moveq.l	#0,d3
L23:
	cmp.w	#4,d3
	beq	L25
	move.l	d7,a0
	move.w	518(a0),d0
	add.w	d3,d0
	and.w	#32768,d0
	beq	L26
L24:
	addq.w	#1,d3
	bra	L23
L26:
	moveq.l	#0,d4
L28:
	cmp.w	#4,d4
	beq	L24
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	move.b	0(a0,d0.l),d6
	ext.w	d6
	beq	L29
	move.l	d7,a0
	move.w	518(a0),d0
	add.w	d3,d0
	move.l	d7,a0
	move.w	426(a0),d1
	subq.w	#1,d1
	cmp.w	d1,d0
	bls	L32
	clr.w	d0
L22:
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
L32:
	move.l	d7,a0
	move.w	518(a0),d0
	add.w	d3,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d7,a0
	add.l	d1,a0
	move.l	d7,a1
	move.w	516(a1),d0
	add.w	d4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.b	0(a0,d1.l),d5
	ext.w	d5
	beq	L29
	clr.w	d0
	bra	L22
L29:
	addq.w	#1,d4
	bra	L28
L25:
	moveq.l	#1,d0
	bra	L22
	.text
	.globl	_rotate_piece_rev
_rotate_piece_rev:
	link	a6,#-16
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d5
	moveq.l	#0,d3
L38:
	cmp.w	#4,d3
	beq	L40
	moveq.l	#0,d4
L41:
	cmp.w	#4,d4
	beq	L39
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-16(a6,d1.l),a1
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.w	#1,d4
	bra	L41
L39:
	addq.w	#1,d3
	bra	L38
L40:
	moveq.l	#0,d3
L44:
	cmp.w	#4,d3
	beq	L37
	moveq.l	#0,d4
L47:
	cmp.w	#4,d4
	beq	L45
	moveq.l	#3,d0
	sub.w	d4,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-16(a6,d1.l),a0
	moveq.l	#0,d0
	move.w	d3,d0
	add.l	d0,a0
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a1
	lea	428(a1),a1
	add.l	d1,a1
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.w	#1,d4
	bra	L47
L45:
	addq.w	#1,d3
	bra	L44
L37:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_rotate_piece
_rotate_piece:
	link	a6,#-16
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d5
	moveq.l	#0,d3
L53:
	cmp.w	#4,d3
	beq	L55
	moveq.l	#0,d4
L56:
	cmp.w	#4,d4
	beq	L54
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-16(a6,d1.l),a1
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.w	#1,d4
	bra	L56
L54:
	addq.w	#1,d3
	bra	L53
L55:
	moveq.l	#0,d3
L59:
	cmp.w	#4,d3
	beq	L61
	moveq.l	#0,d4
L62:
	cmp.w	#4,d4
	beq	L60
	move.w	d4,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-16(a6,d1.l),a0
	moveq.l	#3,d0
	sub.w	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,a0
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a1
	lea	428(a1),a1
	add.l	d1,a1
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.w	#1,d4
	bra	L62
L60:
	addq.w	#1,d3
	bra	L59
L61:
	move.l	d5,-(sp)
	jsr	_update_piece_w
	move.l	d5,(sp)
	jsr	_check_piece_pos
	addq.w	#4,sp
	tst.b	d0
	bne	L52
	move.l	d5,-(sp)
	jsr	_rotate_piece_rev
	move.l	d5,(sp)
	jsr	_update_piece_w
	addq.w	#4,sp
L52:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_lower_piece
_lower_piece:
	link	a6,#0
	movem.l	d3/d4/d5/d6,-(sp)
	move.l	8(a6),d6
	move.l	d6,a0
	addq.w	#1,514(a0)
	move.l	d6,-(sp)
	jsr	_check_piece_pos
	addq.w	#4,sp
	tst.b	d0
	bne	L68
	move.l	d6,a0
	subq.w	#1,514(a0)
	move.l	d6,a0
	move.l	d6,a1
	move.w	514(a0),518(a1)
	moveq.l	#0,d3
L70:
	cmp.w	#4,d3
	beq	L72
	move.l	d6,a0
	move.w	518(a0),d0
	add.w	d3,d0
	and.w	#32768,d0
	bne	L71
	moveq.l	#0,d4
L74:
	cmp.w	#4,d4
	beq	L71
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	move.b	0(a0,d0.l),d5
	ext.w	d5
	beq	L75
	move.l	d6,a0
	move.w	518(a0),d0
	add.w	d3,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	add.l	d1,a0
	move.l	d6,a1
	move.w	516(a1),d0
	add.w	d4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,a0
	move.b	d5,(a0)
L75:
	addq.w	#1,d4
	bra	L74
L71:
	addq.w	#1,d3
	bra	L70
L72:
	move.l	d6,a0
	move.l	d6,a1
	move.b	446(a1),d0
	ext.w	d0
	add.w	514(a0),d0
	tst.w	d0
	bge	L78
	move.l	d6,-(sp)
	jsr	_prepare_gameover
	addq.w	#4,sp
L78:
	move.l	d6,a0
	move.w	#28672,514(a0)
	move.l	d6,-(sp)
	jsr	_check_for_lines
	addq.w	#4,sp
	move.l	d6,a0
	move.w	d0,530(a0)
	move.l	d6,a0
	move.b	#1,569(a0)
L68:
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
	.text
	.globl	_move_piece_lr
_move_piece_lr:
	link	a6,#0
	move.b	13(a6),d0
	ext.w	d0
	move.l	8(a6),a0
	add.w	d0,512(a0)
	move.l	8(a6),-(sp)
	jsr	_update_pcs
	move.l	8(a6),(sp)
	jsr	_check_piece_pos
	addq.w	#4,sp
	tst.b	d0
	bne	L81
	move.b	13(a6),d0
	ext.w	d0
	move.l	8(a6),a0
	sub.w	d0,512(a0)
	move.l	8(a6),-(sp)
	jsr	_update_pcs
L81:
	unlk	a6
	rts
	.data
	.text
	.globl	_add_plf_lines
_add_plf_lines:
	link	a6,#0
	movem.l	d3/d4/d5/d6,-(sp)
	move.w	12(a6),d6
	move.l	8(a6),d5
L86:
	tst.w	d6
	beq	L88
	moveq.l	#0,d3
L89:
	move.l	d5,a0
	move.w	426(a0),d0
	subq.w	#1,d0
	cmp.w	d0,d3
	beq	L91
	moveq.l	#0,d4
L92:
	move.l	d5,a0
	cmp.w	424(a0),d4
	beq	L90
	move.w	d3,d0
	addq.w	#1,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a1
	add.l	d1,a1
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.w	#1,d4
	bra	L92
L90:
	addq.w	#1,d3
	bra	L89
L91:
	moveq.l	#0,d3
L95:
	tst.w	d3
	beq	L97
	move.l	d5,a0
	move.w	424(a0),d0
	subq.w	#1,d0
	cmp.w	d0,d3
	bne	L87
L97:
	moveq.l	#0,d3
	moveq.l	#0,d4
L98:
	move.l	d5,a0
	cmp.w	424(a0),d4
	beq	L95
	move.w	#2,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	beq	L101
	move.l	d5,a0
	move.w	426(a0),d0
	subq.w	#1,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#1,(a0)
	addq.w	#1,d3
L99:
	addq.w	#1,d4
	bra	L98
L101:
	move.l	d5,a0
	move.w	426(a0),d0
	subq.w	#1,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d5,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#0,(a0)
	bra	L99
L87:
	subq.w	#1,d6
	bra	L86
L88:
	move.l	d5,a0
	move.b	#1,569(a0)
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
