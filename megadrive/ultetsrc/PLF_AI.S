	.text
	.globl	_rotate_piece_nocheck
_rotate_piece_nocheck:
	link	a6,#-16
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d5
	moveq.l	#0,d3
L3:
	cmp.w	#4,d3
	beq	L5
	moveq.l	#0,d4
L6:
	cmp.w	#4,d4
	beq	L4
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
	bra	L6
L4:
	addq.w	#1,d3
	bra	L3
L5:
	moveq.l	#0,d3
L9:
	cmp.w	#4,d3
	beq	L11
	moveq.l	#0,d4
L12:
	cmp.w	#4,d4
	beq	L10
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
	bra	L12
L10:
	addq.w	#1,d3
	bra	L9
L11:
	move.l	d5,-(sp)
	jsr	_update_piece_w
	addq.w	#4,sp
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_count_holes
_count_holes:
	link	a6,#0
	movem.l	d3-d7,-(sp)
	moveq.l	#0,d7
	moveq.l	#0,d3
L18:
	cmp.w	#3,d3
	beq	L20
	move.l	8(a6),a0
	move.w	514(a0),d0
	add.w	d3,d0
	and.w	#32768,d0
	beq	L21
L19:
	addq.w	#1,d3
	bra	L18
L21:
	moveq.l	#0,d4
L23:
	cmp.w	#4,d4
	beq	L19
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	8(a6),a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	beq	L24
	move.l	8(a6),a0
	move.w	514(a0),d0
	add.w	d3,d0
	addq.w	#1,d0
	mulu	#14,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	8(a6),a0
	add.l	d1,a0
	move.l	8(a6),a1
	move.w	516(a1),d0
	add.w	d4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.b	0(a0,d1.l),d5
	bne	L27
	move.w	d3,d0
	addq.w	#1,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	8(a6),a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	tst.b	(a0)
	bne	L27
	clr	d0
L28:
	move.w	d0,d5
	bne	L24
	move.l	8(a6),a0
	move.w	514(a0),d0
	add.w	d3,d0
	addq.w	#1,d0
	move.w	d0,d6
L30:
	move.l	8(a6),a0
	cmp.w	426(a0),d6
	beq	L24
	moveq.l	#14,d0
	mulu	d6,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	8(a6),a0
	add.l	d1,a0
	move.l	8(a6),a1
	move.w	516(a1),d0
	add.w	d4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,a0
	tst.b	(a0)
	bne	L24
	addq.w	#1,d7
	addq.w	#1,d6
	bra	L30
L24:
	addq.w	#1,d4
	bra	L23
L27:
	moveq	#1,d0
	bra	L28
L20:
	move.w	d7,d0
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts
	.bss
	.globl	_best_ai_result
	.comm	_best_ai_result,2
	.globl	_best_ai_x
	.comm	_best_ai_x,2
	.globl	_best_ai_rot
	.comm	_best_ai_rot,2
	.globl	_need_ai_update
	.comm	_need_ai_update,2
	.globl	_ai_step
	.comm	_ai_step,2
	.globl	_ai_r_step
	.comm	_ai_r_step,2
	.text
	.globl	_simulate_drop
_simulate_drop:
	link	a6,#-4
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	8(a6),d6
	move.l	d6,a0
	move.w	514(a0),d7
L36:
	move.l	d6,-(sp)
	jsr	_check_piece_pos
	addq.w	#4,sp
	tst.w	d0
	beq	L37
	move.l	d6,a0
	addq.w	#1,514(a0)
	bra	L36
L37:
	move.l	d6,a0
	subq.w	#1,514(a0)
	move.l	d6,-(sp)
	jsr	_count_holes
	addq.w	#4,sp
	lsl.w	#2,d0
	move.l	d6,a0
	move.b	447(a0),d1
	ext.w	d1
	move.l	d6,a0
	add.w	514(a0),d1
	move.l	d6,a0
	move.b	446(a0),d2
	ext.w	d2
	add.w	d2,d1
	add.w	#2048,d1
	sub.w	d0,d1
	move.w	d1,-4(a6)
	move.l	d6,a0
	move.w	d7,514(a0)
	move.w	-4(a6),d0
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
	.data
	.text
	.globl	_plf_ai
_plf_ai:
	link	a6,#-1226
	movem.l	d3/d4/d5,-(sp)
	move.l	8(a6),d4
	move.l	d4,a0
	cmp.w	#28672,514(a0)
	bne	L41
	move.w	#0,_best_ai_result
	move.w	#1,_need_ai_update
	move.l	d4,a0
	move.b	444(a0),d0
	ext.w	d0
	neg.w	d0
	move.w	d0,_ai_step
	move.w	#0,_ai_r_step
	clr.w	d0
L40:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
L41:
	tst.w	_need_ai_update
	beq	L42
	move.l	d4,a0
	move.w	524(a0),d0
	and.w	#1,d0
	beq	L43
	clr.w	d0
	bra	L40
L43:
	move.l	d4,a0
	move.w	_ai_step,512(a0)
	move.l	d4,-(sp)
	jsr	_update_pcs
	move.l	d4,(sp)
	jsr	_simulate_drop
	addq.w	#4,sp
	move.w	d0,d5
	cmp.w	_best_ai_result,d0
	bls	L44
	move.w	d5,_best_ai_result
	move.w	_ai_step,_best_ai_x
	move.w	_ai_r_step,_best_ai_rot
L44:
	move.l	d4,-(sp)
	jsr	_rotate_piece_nocheck
	addq.w	#4,sp
	addq.w	#1,_ai_r_step
	cmp.w	#4,_ai_r_step
	bne	L45
	move.w	#0,_ai_r_step
	addq.w	#1,_ai_step
	move.l	d4,a0
	move.w	_ai_step,d0
	cmp.w	424(a0),d0
	bne	L45
	moveq.l	#0,d3
L47:
	cmp.w	_best_ai_rot,d3
	beq	L49
	move.l	d4,-(sp)
	jsr	_rotate_piece
	addq.w	#4,sp
	addq.w	#1,d3
	bra	L47
L49:
	move.l	d4,a0
	move.w	_best_ai_x,512(a0)
	move.l	d4,-(sp)
	jsr	_update_pcs
	addq.w	#4,sp
	move.w	#0,_need_ai_update
L45:
	clr.w	d0
	bra	L40
L42:
	moveq.l	#2,d0
	bra	L40
