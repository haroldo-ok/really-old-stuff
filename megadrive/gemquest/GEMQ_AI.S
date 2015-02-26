	.bss
	.globl	_ai_recs
	.comm	_ai_recs,624
	.data
	.globl	_enminfo
_enminfo:
	.dc.w	16
	.dc.w	768
	.dc.w	2
	.dc.w	2048
	.dc.w	1
	.dc.w	832
	.dc.w	0
	.dc.w	512
	.dc.w	1
	.dc.w	832
	.dc.w	2
	.dc.w	1024
	.dc.w	1
	.dc.w	896
	.dc.w	0
	.dc.w	336
	.dc.w	1
	.dc.w	896
	.dc.w	2
	.dc.w	768
	.dc.w	1
	.dc.w	960
	.dc.w	0
	.dc.w	1024
	.dc.w	1
	.dc.w	960
	.dc.w	2
	.dc.w	1536
	.globl	_cos_table
_cos_table:
	.dc.w	256
	.dc.w	237
	.dc.w	181
	.dc.w	98
	.dc.w	0
	.dc.w	-98
	.dc.w	-181
	.dc.w	-237
	.dc.w	-256
	.dc.w	-237
	.dc.w	-181
	.dc.w	-98
	.dc.w	0
	.dc.w	98
	.dc.w	181
	.dc.w	237
	.text
	.globl	_ai_reset
_ai_reset:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.l	#_ai_recs,a3
	move.l	#_actor_sprites+42,a4
	moveq.l	#0,d3
L3:
	cmp.w	#39,d3
	beq	L2
	move.l	a3,-(sp)
	jsr	_ai_reset_enemy
	addq.w	#4,sp
	lea	16(a3),a3
	move.w	#-32,4(a4)
	lea	42(a4),a4
	addq.w	#1,d3
	bra	L3
L2:
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_ai_accelerate
_ai_accelerate:
	link	a6,#0
	movem.l	d3-d4/a3,-(sp)
	move.l	8(a6),a3
	move.w	12(a6),d3
	move.w	14(a6),d4
	lsr.w	#4,d3
	move.w	d3,d0
	and.w	#15,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_cos_table,d1
	move.l	d1,a0
	move.w	(a0),d0
	muls	d4,d0
	move.w	d0,12(a3)
	tst.w	12(a3)
	bge	L9
	move.w	12(a3),d0
	neg.w	d0
	asr.w	#8,d0
	neg.w	d0
L10:
	move.w	d0,12(a3)
	move.w	d3,d0
	addq.w	#4,d0
	and.w	#15,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_cos_table,d1
	move.l	d1,a0
	move.w	(a0),d0
	muls	d4,d0
	move.w	d0,14(a3)
	tst.w	14(a3)
	bge	L11
	move.w	14(a3),d0
	neg.w	d0
	asr.w	#8,d0
	neg.w	d0
L12:
	move.w	d0,14(a3)
	movem.l	(sp)+,d3-d4/a3
	unlk	a6
	rts
L11:
	move.w	14(a3),d0
	asr.w	#8,d0
	bra	L12
L9:
	move.w	12(a3),d0
	asr.w	#8,d0
	bra	L10
	.text
	.globl	_ai_accelerate_towards
_ai_accelerate_towards:
	link	a6,#0
	movem.l	d3-d7/a3-a4,-(sp)
	move.l	8(a6),a3
	move.l	12(a6),a4
	move.w	16(a6),d3
	move.w	18(a6),d4
	move.w	20(a6),d5
	sub.w	2(a4),d3
	sub.w	4(a4),d4
	tst.w	d3
	bge	L16
	move.w	d3,d0
	neg.w	d0
L17:
	move.w	d0,d6
	tst.w	d4
	bge	L18
	move.w	d4,d0
	neg.w	d0
L19:
	move.w	d0,d7
	tst.w	d7
	bcc	L21
	move.w	d7,d0
	neg.w	d0
	lsr.w	#1,d0
	neg.w	d0
L22:
	cmp.w	d0,d6
	bcc	L20
	moveq.l	#0,d3
L20:
	tst.w	d6
	bcc	L24
	move.w	d6,d0
	neg.w	d0
	lsr.w	#1,d0
	neg.w	d0
L25:
	cmp.w	d0,d7
	bcc	L23
	moveq.l	#0,d4
L23:
	move.w	#0,12(a3)
	move.w	#0,14(a3)
	tst.w	d3
	beq	L26
	tst.w	d3
	bge	L27
	move.w	d5,d0
	neg.w	d0
	move.w	d0,12(a3)
L26:
	tst.w	d4
	beq	L15
	tst.w	d4
	bge	L30
	move.w	d5,d0
	neg.w	d0
	move.w	d0,14(a3)
L15:
	movem.l	(sp)+,d3-d7/a3-a4
	unlk	a6
	rts
L30:
	move.w	d5,14(a3)
	bra	L15
L27:
	move.w	d5,12(a3)
	bra	L26
L24:
	move.w	d6,d0
	lsr.w	#1,d0
	bra	L25
L21:
	move.w	d7,d0
	lsr.w	#1,d0
	bra	L22
L18:
	move.w	d4,d0
	bra	L19
L16:
	move.w	d3,d0
	bra	L17
	.text
	.globl	_ai_check_shot
_ai_check_shot:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	8(a6),a3
	move.l	12(a6),a4
	move.w	#2,-(sp)
	move.w	4(a4),d0
	add.w	#16,d0
	move.w	d0,-(sp)
	move.w	2(a4),d0
	add.w	#16,d0
	move.w	d0,-(sp)
	move.w	4(a4),-(sp)
	move.w	2(a4),-(sp)
	jsr	_shot_at
	lea	10(sp),sp
	tst.w	d0
	beq	L35
	subq.w	#1,(a3)
L35:
	tst.w	(a3)
	bne	L36
	move.w	_level,d0
	mulu	2(a3),d0
	lsr.w	#1,d0
	add.w	#10,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,_score
	clr.w	-(sp)
	move.w	4(a4),-(sp)
	move.w	2(a4),-(sp)
	jsr	_ai_spawn_enemy
	addq.w	#6,sp
	move.l	#L37,-(sp)
	jsr	_play_GFS_sound
	addq.w	#4,sp
	moveq.l	#1,d0
L34:
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
L36:
	clr.w	d0
	bra	L34
	.text
	.globl	_ai_check_collision
_ai_check_collision:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	8(a6),a3
	move.l	12(a6),a4
	move.w	2(a4),d0
	add.w	#15,d0
	move.l	_player,a0
	move.w	2(a0),d1
	addq.w	#4,d1
	cmp.w	d1,d0
	ble	L41
	move.l	_player,a0
	move.w	2(a0),d0
	add.w	#19,d0
	move.w	2(a4),d1
	cmp.w	d0,d1
	bge	L41
	move.w	4(a4),d0
	add.w	#15,d0
	move.l	_player,a0
	move.w	4(a0),d1
	addq.w	#4,d1
	cmp.w	d1,d0
	ble	L41
	move.l	_player,a0
	move.w	4(a0),d0
	add.w	#19,d0
	move.w	4(a4),d1
	cmp.w	d0,d1
	bge	L41
	move.w	#0,(a3)
	jsr	_kill_player
L41:
	tst.w	(a3)
	bne	L42
	clr.w	-(sp)
	move.w	4(a4),-(sp)
	move.w	2(a4),-(sp)
	jsr	_ai_spawn_enemy
	addq.w	#6,sp
	moveq.l	#1,d0
L40:
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
L42:
	clr.w	d0
	bra	L40
	.text
	.globl	_ai_handle
_ai_handle:
	link	a6,#-2
	movem.l	d3/a3-a4,-(sp)
	move.l	#_ai_recs,a4
	move.l	#_actor_sprites+42,a3
	moveq.l	#1,d3
L46:
	cmp.w	#40,d3
	beq	L45
	tst.w	(a4)
	beq	L49
	move.w	2(a4),d0
	beq	L52
	cmp.w	#1,d0
	beq	L53
	cmp.w	#2,d0
	beq	L53
	cmp.w	#3,d0
	beq	L60
	cmp.w	#4,d0
	beq	L60
	cmp.w	#5,d0
	beq	L69
	cmp.w	#6,d0
	beq	L69
L50:
	move.w	12(a4),d0
	add.w	d0,24(a3)
	move.w	14(a4),d0
	add.w	d0,34(a3)
	cmp.w	#16,2(a3)
	bge	L79
	move.w	#16,2(a3)
	move.w	24(a3),d0
	neg.w	d0
	move.w	d0,24(a3)
	move.w	12(a4),d0
	neg.w	d0
	move.w	d0,12(a4)
L80:
	cmp.w	#16,4(a3)
	bge	L82
	move.w	#16,4(a3)
	move.w	34(a3),d0
	neg.w	d0
	move.w	d0,34(a3)
	move.w	14(a4),d0
	neg.w	d0
	move.w	d0,14(a4)
L85:
	lea	16(a4),a4
	lea	42(a3),a3
	addq.w	#1,d3
	bra	L46
L82:
	cmp.w	#728,4(a3)
	ble	L85
	move.w	#728,4(a3)
	move.w	34(a3),d0
	neg.w	d0
	move.w	d0,34(a3)
	move.w	14(a4),d0
	neg.w	d0
	move.w	d0,14(a4)
	bra	L85
L79:
	cmp.w	#728,2(a3)
	ble	L80
	move.w	#728,2(a3)
	move.w	24(a3),d0
	neg.w	d0
	move.w	d0,24(a3)
	move.w	12(a4),d0
	neg.w	d0
	move.w	d0,12(a4)
	bra	L80
L69:
	tst.w	4(a4)
	bne	L70
	cmp.w	#6,2(a4)
	beq	L71
	move.w	#20,-2(a6)
L72:
	move.w	-2(a6),-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	beq	L73
	move.w	#512,-(sp)
	move.w	#8,-(sp)
	jsr	_random
	asl.w	#5,d0
	move.w	d0,(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate
	addq.w	#8,sp
L74:
	cmp.w	#6,2(a4)
	beq	L75
	move.w	#70,-2(a6)
L76:
	move.w	-2(a6),-(sp)
	jsr	_random
	addq.w	#2,sp
	add.w	-2(a6),d0
	move.w	d0,6(a4)
L77:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	bra	L50
L75:
	move.w	#30,-2(a6)
	bra	L76
L73:
	move.w	#512,-(sp)
	move.w	_actor_sprites+4,-(sp)
	move.w	_actor_sprites+2,-(sp)
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate_towards
	lea	14(sp),sp
	bra	L74
L71:
	move.w	#10,-2(a6)
	bra	L72
L70:
	subq.w	#1,4(a4)
	bra	L77
L60:
	tst.w	4(a4)
	bne	L61
	move.w	#10,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	beq	L62
	move.w	#32,-(sp)
	jsr	_random
	add.w	#32,d0
	move.w	d0,(sp)
	move.w	#256,-(sp)
	jsr	_random
	move.w	d0,(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate
	addq.w	#8,sp
L63:
	move.w	#70,-(sp)
	jsr	_random
	addq.w	#2,sp
	add.w	#70,d0
	move.w	d0,4(a4)
L64:
	tst.w	6(a4)
	bne	L65
	move.w	#2,-(sp)
	move.w	#8434,-(sp)
	move.w	#1024,-(sp)
	move.w	#256,-(sp)
	jsr	_random
	move.w	d0,(sp)
	move.w	#8,-(sp)
	move.w	4(a3),d0
	addq.w	#6,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	addq.w	#6,d0
	move.w	d0,-(sp)
	jsr	_shot_shoot
	lea	14(sp),sp
	cmp.w	#4,2(a4)
	beq	L66
	move.w	#40,-2(a6)
L67:
	move.w	-2(a6),-(sp)
	jsr	_random
	addq.w	#2,sp
	add.w	-2(a6),d0
	move.w	d0,6(a4)
L68:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	bra	L50
L66:
	move.w	#15,-2(a6)
	bra	L67
L65:
	subq.w	#1,6(a4)
	bra	L68
L62:
	move.w	#32,-(sp)
	move.w	_actor_sprites+4,-(sp)
	move.w	_actor_sprites+2,-(sp)
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate_towards
	lea	14(sp),sp
	bra	L63
L61:
	subq.w	#1,4(a4)
	bra	L64
L53:
	tst.w	4(a4)
	bne	L54
	cmp.w	#2,2(a4)
	beq	L55
	move.w	#10,-2(a6)
L56:
	move.w	-2(a6),-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	beq	L57
	move.w	#32,-(sp)
	jsr	_random
	add.w	#48,d0
	move.w	d0,(sp)
	move.w	#256,-(sp)
	jsr	_random
	move.w	d0,(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate
	addq.w	#8,sp
L58:
	move.w	#70,-(sp)
	jsr	_random
	addq.w	#2,sp
	moveq.l	#7,d1
	mulu	-2(a6),d1
	add.w	d0,d1
	move.w	d1,4(a4)
L59:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	bra	L50
L57:
	move.w	#80,-(sp)
	move.w	_actor_sprites+4,-(sp)
	move.w	_actor_sprites+2,-(sp)
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate_towards
	lea	14(sp),sp
	bra	L58
L55:
	move.w	#3,-2(a6)
	bra	L56
L54:
	subq.w	#1,4(a4)
	bra	L59
L52:
	subq.w	#1,(a4)
	bra	L50
L49:
	move.w	#-64,4(a3)
	bra	L85
L45:
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_ai_reset_enemy
_ai_reset_enemy:
	link	a6,#-2
	movem.l	d3/a3,-(sp)
	move.l	8(a6),a3
	move.w	#0,(a3)
	move.w	#0,2(a3)
	moveq.l	#0,d3
L89:
	cmp.w	#4,d3
	beq	L91
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	#0,4(a3,d1.l)
	addq.w	#1,d3
	bra	L89
L91:
	move.w	#0,12(a3)
	move.w	#0,14(a3)
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
	.data
L37:	.dc.b	$45,$58,$50,$4c,$4f,$44,$45,$32,$2e,$53,$4e
	.dc.b	$44
	.dc.b	0
	.text
	.globl	_ai_spawn_enemy
_ai_spawn_enemy:
	link	a6,#-4
	movem.l	d3/d4/d5/a3/a4,-(sp)
	move.w	12(a6),d5
	move.w	d5,d0
	lsl.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_enminfo,d1
	move.l	d1,d4
	move.l	#_ai_recs,a4
	move.l	#_actor_sprites+42,a3
	moveq.l	#1,d3
L95:
	cmp.w	#40,d3
	beq	L97
	tst.w	(a4)
	beq	L97
	lea	16(a4),a4
	lea	42(a3),a3
	addq.w	#1,d3
	bra	L95
L97:
	cmp.w	#40,d3
	bne	L98
	clr.w	d0
L94:
	movem.l	(sp)+,d3/d4/d5/a3/a4
	unlk	a6
	rts
L98:
	move.w	#4,-(sp)
	move.l	d4,a0
	move.w	4(a0),d0
	moveq.l	#13,d1
	lsl.w	d1,d0
	move.l	d4,a0
	or.w	2(a0),d0
	move.w	d0,-(sp)
	move.w	#1280,-(sp)
	move.w	10(a6),-(sp)
	move.w	8(a6),-(sp)
	move.w	d3,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	move.l	a3,-(sp)
	jsr	_sprite_init
	lea	16(sp),sp
	move.w	#16,20(a3)
	move.w	#255,18(a3)
	move.w	#8,26(a3)
	move.w	#8,36(a3)
	move.l	d4,a0
	move.w	6(a0),30(a3)
	move.l	d4,a0
	move.w	6(a0),40(a3)
	move.w	d5,2(a4)
	move.l	d4,a0
	move.w	(a0),(a4)
	move.w	d5,d0
	cmp.w	#1,d0
	beq	L99
L99:
	move.w	d3,d0
	bra	L94
