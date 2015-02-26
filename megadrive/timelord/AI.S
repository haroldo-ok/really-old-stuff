	.bss
	.globl	_ai_sync
	.comm	_ai_sync,2
	.globl	_ai_recs
	.comm	_ai_recs,464
	.globl	_saucer_checkpoints
	.comm	_saucer_checkpoints,128
	.globl	_saucers_cnt
	.comm	_saucers_cnt,2
	.globl	_saucers_deployed
	.comm	_saucers_deployed,2
	.globl	_saucers_shoot
	.comm	_saucers_shoot,2
	.data
	.globl	_enminfo
_enminfo:
	.dc.w	16
	.dc.w	400
	.dc.w	2
	.dc.w	2048
	.dc.w	1280
	.dc.w	4
	.dc.w	1
	.dc.w	512
	.dc.w	2
	.dc.w	1024
	.dc.w	1280
	.dc.w	4
	.dc.w	1
	.dc.w	768
	.dc.w	3
	.dc.w	1024
	.dc.w	3840
	.dc.w	16
	.dc.w	1
	.dc.w	576
	.dc.w	2
	.dc.w	1024
	.dc.w	1280
	.dc.w	4
	.dc.w	1
	.dc.w	640
	.dc.w	2
	.dc.w	512
	.dc.w	1280
	.dc.w	4
	.dc.w	1
	.dc.w	704
	.dc.w	1
	.dc.w	1024
	.dc.w	1280
	.dc.w	4
	.dc.w	1
	.dc.w	960
	.dc.w	2
	.dc.w	1536
	.dc.w	1280
	.dc.w	4
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
	.globl	_snd_saucer1
_snd_saucer1:
	.dc.w	10248
	.dc.w	5520
	.dc.w	5420
	.dc.w	5320
	.dc.w	5220
	.dc.w	5320
	.dc.w	5420
	.dc.w	11334
	.dc.w	10240
	.dc.w	0
	.text
	.globl	_ai_reset
_ai_reset:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.l	#_ai_recs,a3
	move.l	#_actor_sprites+42,a4
	moveq.l	#0,d3
L3:
	cmp.w	#29,d3
	beq	L5
	move.l	a3,-(sp)
	jsr	_ai_reset_enemy
	addq.w	#4,sp
	lea	16(a3),a3
	move.w	#-32,4(a4)
	lea	42(a4),a4
	addq.w	#1,d3
	bra	L3
L5:
	move.w	#8,_saucers_cnt
	move.w	#0,_saucers_deployed
	move.w	#16,_saucers_shoot
	move.w	#0,_ai_sync
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_ai_accelerate
_ai_accelerate:
	link	a6,#-4
	movem.l	d3/d4/d5/a3,-(sp)
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
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d4
	move.l	d4,-(sp)
	jsr	lmul
	addq.w	#8,sp
	move.l	d0,d5
	tst.l	d5
	bge	L9
	move.l	d5,d0
	neg.l	d0
	asr.l	#8,d0
	neg.l	d0
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
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d4
	move.l	d4,-(sp)
	jsr	lmul
	addq.w	#8,sp
	move.l	d0,d5
	tst.l	d5
	bge	L11
	move.l	d5,d0
	neg.l	d0
	asr.l	#8,d0
	neg.l	d0
L12:
	move.w	d0,14(a3)
	movem.l	(sp)+,d3/d4/d5/a3
	unlk	a6
	rts
L11:
	move.l	d5,d0
	asr.l	#8,d0
	bra	L12
L9:
	move.l	d5,d0
	asr.l	#8,d0
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
	.globl	_get_bearing
_get_bearing:
	link	a6,#0
	movem.l	d3-d7,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	tst.w	d3
	bge	L46
	move.w	d3,d0
	neg.w	d0
L47:
	move.w	d0,d6
	tst.w	d4
	bge	L48
	move.w	d4,d0
	neg.w	d0
L49:
	move.w	d0,d7
	moveq.l	#0,d5
	move.w	d7,d0
	asr.w	#1,d0
	add.w	d7,d0
	cmp.w	d0,d6
	blt	L50
	tst.w	d3
	bge	L51
	moveq.l	#4,d5
L53:
	move.w	d5,d0
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts
L51:
	moveq.l	#0,d5
	bra	L53
L50:
	move.w	d6,d0
	asr.w	#1,d0
	add.w	d6,d0
	cmp.w	d0,d7
	blt	L54
	tst.w	d4
	bge	L55
	moveq.l	#2,d5
	bra	L53
L55:
	moveq.l	#6,d5
	bra	L53
L54:
	tst.w	d4
	bge	L58
	tst.w	d3
	bge	L59
	moveq.l	#3,d5
	bra	L53
L59:
	moveq.l	#1,d5
	bra	L53
L58:
	tst.w	d3
	bge	L62
	moveq.l	#5,d5
	bra	L53
L62:
	moveq.l	#7,d5
	bra	L53
L48:
	move.w	d4,d0
	bra	L49
L46:
	move.w	d3,d0
	bra	L47
	.text
	.globl	_ai_checkpoint_mark
_ai_checkpoint_mark:
	link	a6,#0
	movem.l	d3/a3-a5,-(sp)
	move.w	8(a6),d3
	move.l	10(a6),a3
	move.l	14(a6),a4
	move.w	d3,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_saucer_checkpoints,d1
	move.l	d1,a5
	move.w	12(a3),(a5)
	move.w	14(a3),2(a5)
	move.w	2(a4),4(a5)
	move.w	4(a4),6(a5)
	move.w	22(a4),8(a5)
	move.w	24(a4),10(a5)
	move.w	32(a4),12(a5)
	move.w	34(a4),14(a5)
	movem.l	(sp)+,d3/a3-a5
	unlk	a6
	rts
	.text
	.globl	_ai_checkpoint_retrieve
_ai_checkpoint_retrieve:
	link	a6,#0
	movem.l	d3/a3-a5,-(sp)
	move.w	8(a6),d3
	move.l	10(a6),a3
	move.l	14(a6),a4
	move.w	d3,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_saucer_checkpoints,d1
	move.l	d1,a5
	move.w	(a5),12(a3)
	move.w	2(a5),14(a3)
	move.w	4(a5),2(a4)
	move.w	6(a5),4(a4)
	move.w	8(a5),22(a4)
	move.w	10(a5),24(a4)
	move.w	12(a5),32(a4)
	move.w	14(a5),34(a4)
	movem.l	(sp)+,d3/a3-a5
	unlk	a6
	rts
	.text
	.globl	_ai_saucer_new_leader
_ai_saucer_new_leader:
	link	a6,#0
	movem.l	d3-d4/a3-a4,-(sp)
	move.w	#1000,d4
	sub.l	a4,a4
	move.l	#_ai_recs,a3
	moveq.l	#1,d3
L73:
	cmp.w	#30,d3
	beq	L75
	tst.w	(a3)
	beq	L76
	cmp.w	#1,2(a3)
	bne	L76
	move.w	10(a3),d0
	cmp.w	d4,d0
	bcc	L76
	move.w	10(a3),d4
	move.l	a3,a4
L76:
	lea	16(a3),a3
	addq.w	#1,d3
	bra	L73
L75:
	cmp.l	#0,a4
	beq	L72
	move.w	#0,10(a4)
L72:
	movem.l	(sp)+,d3-d4/a3-a4
	unlk	a6
	rts
	.text
	.globl	_ai_handle
_ai_handle:
	link	a6,#-6
	movem.l	d3/d4/d5/a3/a4,-(sp)
	move.l	#_ai_recs,a4
	move.l	#_actor_sprites+42,a3
	moveq.l	#1,d3
L82:
	cmp.w	#30,d3
	beq	L84
	tst.w	(a4)
	beq	L85
	move.w	#208,d4
	moveq.l	#0,d5
	move.w	2(a4),d0
	beq	L88
	cmp.w	#1,d0
	beq	L89
	cmp.w	#3,d0
	beq	L107
	cmp.w	#4,d0
	beq	L109
	cmp.w	#5,d0
	beq	L113
L86:
	move.w	12(a4),d0
	add.w	d0,24(a3)
	move.w	14(a4),d0
	add.w	d0,34(a3)
	tst.w	d5
	beq	L128
	tst.w	2(a3)
	bge	L122
	move.w	#0,2(a3)
	move.w	24(a3),d0
	neg.w	d0
	move.w	d0,24(a3)
	move.w	12(a4),d0
	neg.w	d0
	move.w	d0,12(a4)
L123:
	tst.w	4(a3)
	bge	L125
	move.w	#0,4(a3)
	move.w	34(a3),d0
	neg.w	d0
	move.w	d0,34(a3)
	move.w	14(a4),d0
	neg.w	d0
	move.w	d0,14(a4)
L128:
	lea	16(a4),a4
	lea	42(a3),a3
	addq.w	#1,d3
	bra	L82
L125:
	move.w	4(a3),d0
	cmp.w	d4,d0
	bls	L128
	move.w	d4,4(a3)
	move.w	34(a3),d0
	neg.w	d0
	move.w	d0,34(a3)
	move.w	14(a4),d0
	neg.w	d0
	move.w	d0,14(a4)
	bra	L128
L122:
	cmp.w	#304,2(a3)
	ble	L123
	move.w	#304,2(a3)
	move.w	24(a3),d0
	neg.w	d0
	move.w	d0,24(a3)
	move.w	12(a4),d0
	neg.w	d0
	move.w	d0,12(a4)
	bra	L123
L113:
	cmp.w	#200,4(a3)
	ble	L114
	move.l	_player,a0
	move.w	2(a3),d0
	cmp.w	2(a0),d0
	bge	L115
	move.w	#15,12(a4)
L116:
	tst.w	4(a4)
	bne	L117
	move.w	#0,(a4)
L118:
	move.w	#0,34(a3)
L119:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	bra	L86
L117:
	subq.w	#1,4(a4)
	bra	L118
L115:
	move.w	#-15,12(a4)
	bra	L116
L114:
	move.w	#256,34(a3)
	bra	L119
L109:
	cmp.w	#224,4(a3)
	ble	L110
	move.w	#0,(a4)
L110:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	move.l	_player,a0
	move.w	2(a3),d0
	cmp.w	2(a0),d0
	bge	L111
	move.w	#15,12(a4)
L112:
	move.w	#256,34(a3)
	bra	L86
L111:
	move.w	#-15,12(a4)
	bra	L112
L107:
	cmp.w	#224,4(a3)
	ble	L108
	move.w	#0,(a4)
L108:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	move.w	#0,24(a3)
	move.w	#511,34(a3)
	bra	L86
L89:
	tst.w	10(a4)
	bne	L90
	move.w	_ai_sync,d0
	and.w	#7,d0
	bne	L90
	move.l	#_snd_saucer1,-(sp)
	move.w	#2,-(sp)
	jsr	_start_sound
	addq.w	#6,sp
L90:
	move.w	_ai_sync,d0
	and.w	#3,d0
	bne	L92
	tst.w	10(a4)
	bne	L93
	move.w	#5,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	bne	L94
	move.w	_level,d0
	lsl.w	#5,d0
	add.w	#240,d0
	move.w	d0,-(sp)
	move.w	#256,-(sp)
	jsr	_random
	move.w	d0,(sp)
	move.l	a4,-(sp)
	jsr	_ai_accelerate
	addq.w	#8,sp
	tst.w	12(a4)
	bge	L95
	move.w	12(a4),d0
	neg.w	d0
	asr.w	#1,d0
	neg.w	d0
L96:
	add.w	d0,12(a4)
L94:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.w	4(a4),-(sp)
	jsr	_ai_checkpoint_mark
	lea	10(sp),sp
	tst.w	_saucers_deployed
	beq	L98
	tst.w	_saucers_shoot
	beq	L98
	subq.w	#1,_saucers_shoot
L98:
	tst.w	8(a4)
	bne	L99
	cmp.w	#7,10(a4)
	beq	L99
	cmp.w	#1,4(a4)
	bne	L99
	move.w	10(a4),d0
	addq.w	#1,d0
	move.w	d0,8(a4)
	move.w	2(a4),-(sp)
	move.w	4(a3),-(sp)
	move.w	2(a3),-(sp)
	jsr	_ai_spawn_enemy
	addq.w	#6,sp
	move.w	d0,-2(a6)
	moveq.l	#42,d0
	mulu	-2(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,-(sp)
	move.w	-2(a6),d0
	subq.w	#1,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_ai_recs,d1
	move.l	d1,-(sp)
	move.w	4(a4),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_ai_checkpoint_retrieve
	lea	10(sp),sp
	move.w	-2(a6),d0
	subq.w	#1,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_ai_recs,d1
	move.l	d1,a0
	move.w	8(a4),10(a0)
	cmp.w	#7,8(a4)
	bne	L99
	move.w	#1,_saucers_deployed
L99:
	tst.w	_saucers_shoot
	bne	L101
	move.w	_saucers_cnt,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	bne	L101
	move.w	_level,d0
	lsr.w	#1,d0
	addq.w	#1,d0
	move.w	d0,-2(a6)
	cmp.w	#3,d0
	bls	L102
	move.w	#3,-2(a6)
L102:
	move.w	-2(a6),-(sp)
	jsr	_random
	addq.w	#3,d0
	move.w	d0,(sp)
	move.w	4(a3),d0
	addq.w	#8,d0
	move.w	d0,-(sp)
	move.w	2(a3),-(sp)
	jsr	_ai_spawn_enemy
	addq.w	#6,sp
	cmp.w	#15,_level
	bcc	L103
	moveq.l	#20,d0
	sub.w	_level,d0
	move.w	d0,_saucers_shoot
L101:
	addq.w	#1,4(a4)
	cmp.w	#8,4(a4)
	bne	L92
	move.w	#0,4(a4)
L92:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_collision
	addq.w	#8,sp
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	jsr	_ai_check_shot
	addq.w	#8,sp
	tst.w	d0
	beq	L106
	subq.w	#1,_saucers_cnt
	jsr	_ai_saucer_new_leader
L106:
	moveq.l	#1,d5
	move.w	#140,d4
	bra	L86
L103:
	move.w	#5,_saucers_shoot
	bra	L101
L95:
	move.w	12(a4),d0
	asr.w	#1,d0
	bra	L96
L93:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move.w	4(a4),-(sp)
	jsr	_ai_checkpoint_retrieve
	lea	10(sp),sp
	bra	L98
L88:
	subq.w	#1,(a4)
	moveq.l	#1,d5
	bra	L86
L85:
	move.w	#-64,4(a3)
	bra	L128
L84:
	addq.w	#1,_ai_sync
	movem.l	(sp)+,d3/d4/d5/a3/a4
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
L132:
	cmp.w	#4,d3
	beq	L134
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	#0,4(a3,d1.l)
	addq.w	#1,d3
	bra	L132
L134:
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
	movem.l	d3/d4/a3/a4,-(sp)
	moveq.l	#12,d0
	mulu	12(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_enminfo,d1
	move.l	d1,d4
	move.l	#_ai_recs,a4
	move.l	#_actor_sprites+42,a3
	moveq.l	#1,d3
L138:
	cmp.w	#30,d3
	beq	L140
	tst.w	(a4)
	beq	L140
	lea	16(a4),a4
	lea	42(a3),a3
	addq.w	#1,d3
	bra	L138
L140:
	cmp.w	#30,d3
	bne	L141
	clr.w	d0
L137:
	movem.l	(sp)+,d3/d4/a3/a4
	unlk	a6
	rts
L141:
	move.l	d4,a0
	move.w	10(a0),-(sp)
	move.l	d4,a0
	move.w	4(a0),d0
	moveq.l	#13,d1
	lsl.w	d1,d0
	move.l	d4,a0
	or.w	2(a0),d0
	move.w	d0,-(sp)
	move.l	d4,a0
	move.w	8(a0),-(sp)
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
	move.w	12(a6),2(a4)
	move.l	d4,a0
	move.w	(a0),(a4)
	move.w	#0,12(a4)
	move.w	#0,14(a4)
	move.w	12(a6),d0
	cmp.w	#1,d0
	beq	L144
	cmp.w	#3,d0
	beq	L145
	cmp.w	#4,d0
	beq	L146
	cmp.w	#5,d0
	beq	L147
L142:
	move.w	d3,d0
	bra	L137
L147:
	move.w	#0,36(a3)
	move.w	#0,24(a3)
	move.w	#511,34(a3)
	move.w	#80,4(a4)
	bra	L142
L146:
	move.w	#0,36(a3)
	move.w	#0,24(a3)
	move.w	#256,34(a3)
	bra	L142
L145:
	move.w	#0,36(a3)
	move.w	#0,24(a3)
	move.w	#511,34(a3)
	bra	L142
L144:
	move.w	_level,d0
	lsl.w	#7,d0
	add.w	d0,30(a3)
	move.w	_level,d0
	lsl.w	#7,d0
	add.w	d0,40(a3)
	bra	L142
