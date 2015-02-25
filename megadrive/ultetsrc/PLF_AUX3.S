	.text
	.globl	_count_special_blocks
_count_special_blocks:
	link	a6,#0
	movem.l	d3/d4/d5/d6,-(sp)
	move.l	8(a6),d6
	moveq.l	#0,d5
	moveq.l	#0,d3
L3:
	move.l	d6,a0
	cmp.w	426(a0),d3
	beq	L5
	moveq.l	#0,d4
L6:
	move.l	d6,a0
	cmp.w	424(a0),d4
	beq	L4
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	cmp.b	#6,(a0)
	bne	L7
	addq.w	#1,d5
L7:
	addq.w	#1,d4
	bra	L6
L4:
	addq.w	#1,d3
	bra	L3
L5:
	move.w	d5,d0
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
	.text
	.globl	_check_plf_meta
_check_plf_meta:
	link	a6,#-4
	movem.l	d3/d4,-(sp)
	moveq.l	#0,d4
	moveq.l	#0,d3
L13:
	cmp.w	#4,d3
	beq	L15
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	8(a6),a0
	lea	542(a0),a0
	add.l	d1,a0
	tst.w	(a0)
	beq	L14
	moveq.l	#1,d4
L14:
	addq.w	#1,d3
	bra	L13
L15:
	tst.w	d4
	seq	d0
	and.w	#1,d0
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_init_playfield
_init_playfield:
	link	a6,#0
	movem.l	d3/d4/d5/d6,-(sp)
	move.l	8(a6),d6
	moveq.l	#0,d3
L20:
	cmp.w	#30,d3
	beq	L22
	moveq.l	#0,d4
L23:
	cmp.w	#14,d4
	beq	L21
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#0,(a0)
	addq.w	#1,d4
	bra	L23
L21:
	addq.w	#1,d3
	bra	L20
L22:
	move.l	d6,a0
	move.w	#2,422(a0)
	move.l	_curr_plf_opt,a0
	moveq.l	#28,d0
	sub.w	4(a0),d0
	lsr.w	#1,d0
	move.l	d6,a0
	move.w	d0,420(a0)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.w	2(a0),424(a1)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.w	4(a0),426(a1)
	moveq.l	#0,d3
L26:
	cmp.w	#4,d3
	beq	L28
	moveq.l	#0,d4
L29:
	cmp.w	#4,d4
	beq	L27
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	428(a0),a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d4,d0
	add.l	d0,a0
	move.b	#0,(a0)
	moveq.l	#0,d5
L32:
	cmp.w	#4,d5
	beq	L30
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
	move.b	#0,(a0)
	addq.w	#1,d5
	bra	L32
L30:
	addq.w	#1,d4
	bra	L29
L27:
	addq.w	#1,d3
	bra	L26
L28:
	move.l	d6,a0
	move.w	#0,512(a0)
	move.l	d6,a0
	move.w	#28672,514(a0)
	move.l	d6,a0
	move.w	#0,516(a0)
	move.l	d6,a0
	move.w	#0,518(a0)
	move.l	d6,a0
	move.w	#0,528(a0)
	move.l	d6,a0
	move.w	#0,520(a0)
	move.l	_curr_plf_opt,a0
	move.w	10(a0),d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_speed_table,d1
	move.l	d1,a0
	move.l	d6,a1
	move.w	(a0),522(a1)
	move.l	d6,a0
	move.w	#0,524(a0)
	move.l	d6,a0
	move.w	#4,526(a0)
	move.l	d6,a0
	move.w	#0,530(a0)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.w	10(a0),552(a1)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.w	10(a0),550(a1)
	move.l	d6,a0
	move.w	#0,532(a0)
	moveq.l	#0,d3
L35:
	cmp.w	#4,d3
	beq	L37
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	534(a0),a0
	add.l	d1,a0
	move.w	#0,(a0)
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	542(a0),a0
	add.l	d1,a0
	move.w	#0,(a0)
	addq.w	#1,d3
	bra	L35
L37:
	move.l	d6,a0
	move.l	#0,554(a0)
	move.l	d6,-(sp)
	jsr	_count_special_blocks
	move.l	d6,a0
	move.w	d0,562(a0)
	move.l	d6,(sp)
	jsr	_check_plf_meta
	addq.w	#4,sp
	move.l	d6,a0
	move.w	d0,564(a0)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.b	7(a0),558(a1)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.b	9(a0),559(a1)
	move.l	_curr_plf_opt,a0
	move.l	d6,a1
	move.w	12(a0),560(a1)
	move.l	d6,a0
	move.w	#0,566(a0)
	move.l	d6,a0
	move.b	#1,568(a0)
	move.l	d6,a0
	move.b	#1,569(a0)
	moveq.l	#0,d3
L38:
	cmp.w	#4,d3
	beq	L40
	moveq.l	#0,d4
L41:
	cmp.w	#4,d4
	beq	L39
	move.w	d3,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	lea	574(a0),a0
	add.l	d1,a0
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,a0
	move.w	#0,(a0)
	addq.w	#1,d4
	bra	L41
L39:
	addq.w	#1,d3
	bra	L38
L40:
	move.l	d6,a0
	move.w	#0,606(a0)
	move.l	d6,a0
	move.l	#0,570(a0)
	moveq.l	#0,d3
L44:
	cmp.w	#5,d3
	beq	L46
	move.l	d6,-(sp)
	jsr	_new_piece
	addq.w	#4,sp
	addq.w	#1,d3
	bra	L44
L46:
	move.l	d6,a0
	move.w	#255,608(a0)
	move.l	d6,a0
	move.w	#0,610(a0)
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
	.data
	.text
	.globl	_gameover_sequence
_gameover_sequence:
	link	a6,#0
	movem.l	d3/d4/d5/d6,-(sp)
	move.l	8(a6),d6
	move.l	d6,a0
	cmp.w	#140,566(a0)
	bhi	L50
	move.l	d6,a0
	subq.w	#1,566(a0)
L49:
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
L50:
	move.l	d6,a0
	move.w	426(a0),d0
	add.w	#140,d0
	move.l	d6,a0
	move.w	566(a0),d1
	cmp.w	d0,d1
	bcc	L52
	move.l	d6,a0
	move.w	566(a0),d0
	sub.w	#140,d0
	move.l	d6,a0
	move.w	426(a0),d1
	sub.w	d0,d1
	move.w	d1,d4
	moveq.l	#0,d3
L53:
	move.l	d6,a0
	cmp.w	424(a0),d3
	beq	L55
	moveq.l	#14,d0
	mulu	d4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d6,a0
	add.l	d1,a0
	moveq.l	#0,d0
	move.w	d3,d0
	add.l	d0,a0
	move.b	#7,(a0)
	addq.w	#1,d3
	bra	L53
L55:
	move.l	d6,a0
	subq.w	#1,566(a0)
	move.l	d6,a0
	move.b	#1,569(a0)
	bra	L49
L52:
	move.l	d6,-(sp)
	jsr	_clear_lines
	addq.w	#4,sp
	bra	L49
