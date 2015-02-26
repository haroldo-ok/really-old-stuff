	.bss
	.globl	_shots
	.comm	_shots,1920
	.globl	_curr_shot_num
	.comm	_curr_shot_num,2
	.text
	.globl	_shot_reset
_shot_reset:
	link	a6,#0
	move.l	d3,-(sp)
	moveq.l	#0,d3
L3:
	cmp.w	#120,d3
	beq	L5
	move.w	d3,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_shots,d1
	move.l	d1,a0
	move.w	#0,(a0)
	addq.w	#1,d3
	bra	L3
L5:
	move.w	#0,_curr_shot_num
	move.l	(sp)+,d3
	unlk	a6
	rts
	.text
	.globl	_shot_move
_shot_move:
	link	a6,#0
	movem.l	d3/a3,-(sp)
	move.l	#_shots,a3
	moveq.l	#120,d3
L9:
	tst.w	d3
	beq	L8
	tst.w	(a3)
	beq	L12
	move.w	12(a3),d0
	add.w	d0,8(a3)
	move.w	8(a3),d0
	asr.w	#8,d0
	ext.w	d0
	add.w	d0,4(a3)
	and.w	#255,8(a3)
	move.w	14(a3),d0
	add.w	d0,10(a3)
	move.w	10(a3),d0
	asr.w	#8,d0
	ext.w	d0
	add.w	d0,6(a3)
	and.w	#255,10(a3)
	cmp.w	#16,4(a3)
	blt	L14
	cmp.w	#744,4(a3)
	bgt	L14
	cmp.w	#16,6(a3)
	blt	L14
	cmp.w	#744,6(a3)
	ble	L12
L14:
	move.w	#0,(a3)
L12:
	lea	16(a3),a3
	subq.w	#1,d3
	bra	L9
L8:
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
	.text
	.globl	_shot_draw
_shot_draw:
	link	a6,#0
	movem.l	d3-d6/a3,-(sp)
	cmp.w	#120,_curr_shot_num
	bcs	L18
	move.w	#0,_curr_shot_num
L18:
	move.w	_curr_shot_num,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_shots,d1
	move.l	d1,a3
	moveq.l	#120,d3
	moveq.l	#41,d4
L19:
	tst.w	d3
	beq	L25
	cmp.w	#81,d4
	beq	L25
	tst.w	(a3)
	beq	L22
	move.w	4(a3),d0
	sub.w	_sprite_offs_x,d0
	move.w	d0,d5
	move.w	6(a3),d0
	sub.w	_sprite_offs_y,d0
	move.w	d0,d6
	cmp.w	#-32,d5
	ble	L22
	cmp.w	#352,d5
	bge	L22
	cmp.w	#-32,d6
	ble	L22
	cmp.w	#272,d6
	bge	L22
	move.w	(a3),-(sp)
	clr.w	-(sp)
	move.w	d6,-(sp)
	move.w	d5,-(sp)
	move.w	d4,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	addq.w	#1,d4
L22:
	lea	16(a3),a3
	addq.w	#1,_curr_shot_num
	cmp.w	#120,_curr_shot_num
	bne	L20
	move.w	#0,_curr_shot_num
	move.l	#_shots,a3
L20:
	subq.w	#1,d3
	bra	L19
L25:
	cmp.w	#81,d4
	beq	L17
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	#-32,-(sp)
	move.w	#-32,-(sp)
	move.w	d4,-(sp)
	jsr	_def_sprite
	lea	10(sp),sp
	addq.w	#1,d4
	bra	L25
L17:
	movem.l	(sp)+,d3-d6/a3
	unlk	a6
	rts
	.text
	.globl	_shot_shoot
_shot_shoot:
	link	a6,#0
	movem.l	d3/d4/d5/d6/a3,-(sp)
	move.w	16(a6),d6
	move.w	14(a6),d5
	move.l	#_shots,a3
	moveq.l	#120,d3
L30:
	tst.w	d3
	beq	L32
	tst.w	(a3)
	beq	L32
	lea	16(a3),a3
	subq.w	#1,d3
	bra	L30
L32:
	tst.w	d3
	bne	L33
	clr.w	d0
L29:
	movem.l	(sp)+,d3/d4/d5/d6/a3
	unlk	a6
	rts
L33:
	move.w	d5,d0
	lsr.w	#4,d0
	move.w	d0,d5
	move.w	18(a6),(a3)
	move.w	20(a6),2(a3)
	move.w	d5,d0
	and.w	#15,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_cos_table,d1
	move.l	d1,a0
	move.w	(a0),d0
	mulu	12(a6),d0
	move.w	d0,4(a3)
	tst.w	4(a3)
	bge	L34
	move.w	4(a3),d0
	neg.w	d0
	asr.w	#8,d0
	neg.w	d0
L35:
	move.w	d0,4(a3)
	move.w	8(a6),d0
	add.w	d0,4(a3)
	move.w	d5,d0
	addq.w	#4,d0
	and.w	#15,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_cos_table,d1
	move.l	d1,a0
	move.w	(a0),d0
	mulu	12(a6),d0
	move.w	d0,6(a3)
	tst.w	6(a3)
	bge	L36
	move.w	6(a3),d0
	neg.w	d0
	asr.w	#8,d0
	neg.w	d0
L37:
	move.w	d0,6(a3)
	move.w	10(a6),d0
	add.w	d0,6(a3)
	move.w	#0,8(a3)
	move.w	#0,10(a3)
	move.w	d5,d0
	and.w	#15,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_cos_table,d1
	move.l	d1,a0
	move.w	(a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	lmul
	addq.w	#8,sp
	move.l	d0,d4
	tst.l	d4
	bge	L38
	move.l	d4,d0
	neg.l	d0
	asr.l	#8,d0
	neg.l	d0
L39:
	move.w	d0,12(a3)
	move.w	d5,d0
	addq.w	#4,d0
	and.w	#15,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_cos_table,d1
	move.l	d1,a0
	move.w	(a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	lmul
	addq.w	#8,sp
	move.l	d0,d4
	tst.l	d4
	bge	L40
	move.l	d4,d0
	neg.l	d0
	asr.l	#8,d0
	neg.l	d0
L41:
	move.w	d0,14(a3)
	moveq.l	#1,d0
	bra	L29
L40:
	move.l	d4,d0
	asr.l	#8,d0
	bra	L41
L38:
	move.l	d4,d0
	asr.l	#8,d0
	bra	L39
L36:
	move.w	6(a3),d0
	asr.w	#8,d0
	bra	L37
L34:
	move.w	4(a3),d0
	asr.w	#8,d0
	bra	L35
	.data
	.text
	.globl	_shot_at
_shot_at:
	link	a6,#-2
	movem.l	d3-d7/a3,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	move.w	12(a6),d5
	move.w	14(a6),d6
	move.w	16(a6),d7
	move.l	#_shots,a3
	subq.w	#4,d3
	subq.w	#4,d5
	subq.w	#4,d4
	subq.w	#4,d6
	move.w	#120,-2(a6)
L45:
	tst.w	-2(a6)
	beq	L47
	tst.w	(a3)
	beq	L48
	move.w	2(a3),d0
	cmp.w	d7,d0
	beq	L48
	move.w	4(a3),d0
	cmp.w	d3,d0
	bls	L48
	move.w	4(a3),d0
	cmp.w	d5,d0
	bcc	L48
	move.w	6(a3),d0
	cmp.w	d4,d0
	bls	L48
	move.w	6(a3),d0
	cmp.w	d6,d0
	bcc	L48
	move.w	2(a3),d0
L44:
	movem.l	(sp)+,d3-d7/a3
	unlk	a6
	rts
L48:
	lea	16(a3),a3
	subq.w	#1,-2(a6)
	bra	L45
L47:
	clr.w	d0
	bra	L44
