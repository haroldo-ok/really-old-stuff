	.bss
	.globl	_actor_sprites
	.comm	_actor_sprites,2176
	.globl	_actor_progs
	.comm	_actor_progs,1280
	.globl	_actor_map_x
	.comm	_actor_map_x,2
	.globl	_actor_map_y
	.comm	_actor_map_y,2
	.text
	.globl	_actor_init_all
_actor_init_all:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.l	#_actor_sprites,a3
	move.l	#_actor_progs,a4
	moveq.l	#0,d3
L3:
	cmp.w	#64,d3
	beq	L2
	move.w	#1,32(a3)
	move.l	#0,14(a4)
	lea	34(a3),a3
	lea	20(a4),a4
	addq.w	#1,d3
	bra	L3
L2:
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_actor_walk
_actor_walk:
	link	a6,#-4
	movem.l	d3-d7/a3-a4,-(sp)
	move.w	10(a6),d3
	moveq.l	#34,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a3
	move.w	4(a3),d4
	move.w	6(a3),d5
	move.w	#0,-2(a6)
	move.w	d3,d0
	beq	L11
	cmp.w	#1,d0
	beq	L12
	cmp.w	#2,d0
	beq	L13
	cmp.w	#3,d0
	beq	L14
L9:
	and.w	_map_w_mask,d4
	and.w	_map_h_mask,d5
	move.w	d5,-(sp)
	move.w	d4,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	clr.w	d1
	move.b	d0,d1
	move.w	d1,d6
	move.w	d1,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_tileset_attrs,d1
	move.l	d1,a0
	move.w	(a0),d7
	move.w	d7,d0
	and.w	-2(a6),d0
	beq	L16
	move.b	d3,18(a3)
	move.l	a3,-(sp)
	jsr	_walker_checkbaseframe
	addq.w	#4,sp
	move.w	#3,-(sp)
	moveq.l	#20,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_progs,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_zop_signal_event
	addq.w	#6,sp
	clr.w	d0
L8:
	movem.l	(sp)+,d3-d7/a3-a4
	unlk	a6
	rts
L16:
	move.l	#_actor_sprites,a4
	move.w	#0,-4(a6)
L17:
	cmp.w	#64,-4(a6)
	beq	L19
	move.w	-4(a6),d0
	cmp.w	8(a6),d0
	beq	L20
	move.w	32(a4),d0
	and.w	#1,d0
	bne	L20
	move.w	4(a4),d0
	cmp.w	d4,d0
	bne	L20
	move.w	6(a4),d0
	cmp.w	d5,d0
	bne	L20
	move.b	d3,18(a3)
	move.l	a3,-(sp)
	jsr	_walker_checkbaseframe
	addq.w	#4,sp
	tst.w	8(a6)
	bne	L22
	move.w	#1,-(sp)
	moveq.l	#20,d0
	mulu	-4(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_progs,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_zop_signal_event
	addq.w	#6,sp
L22:
	clr.w	d0
	bra	L8
L20:
	lea	34(a4),a4
	addq.w	#1,-4(a6)
	bra	L17
L19:
	move.w	#1,-(sp)
	move.w	d3,-(sp)
	move.l	a3,-(sp)
	jsr	_walker_walkto
	addq.w	#8,sp
	moveq.l	#1,d0
	bra	L8
L14:
	or.w	#8,-2(a6)
	addq.w	#1,d4
	bra	L9
L13:
	or.w	#4,-2(a6)
	subq.w	#1,d4
	bra	L9
L12:
	or.w	#2,-2(a6)
	addq.w	#1,d5
	bra	L9
L11:
	or.w	#1,-2(a6)
	subq.w	#1,d5
	bra	L9
	.text
	.globl	_actor_talk
_actor_talk:
	link	a6,#0
	movem.l	d3-d5/a3-a4,-(sp)
	moveq.l	#34,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a3
	move.w	4(a3),d3
	move.w	6(a3),d4
	clr.w	d0
	move.b	18(a3),d0
	tst.w	d0
	beq	L28
	cmp.w	#1,d0
	beq	L29
	cmp.w	#2,d0
	beq	L30
	cmp.w	#3,d0
	beq	L31
L26:
	and.w	_map_w_mask,d3
	and.w	_map_h_mask,d4
	move.l	#_actor_sprites,a4
	moveq.l	#0,d5
L33:
	cmp.w	#64,d5
	beq	L35
	cmp.w	8(a6),d5
	beq	L36
	move.w	32(a4),d0
	and.w	#1,d0
	bne	L36
	move.w	4(a4),d0
	cmp.w	d3,d0
	bne	L36
	move.w	6(a4),d0
	cmp.w	d4,d0
	bne	L36
	move.w	#2,-(sp)
	moveq.l	#20,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_progs,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_zop_signal_event
	addq.w	#6,sp
	moveq.l	#1,d0
L25:
	movem.l	(sp)+,d3-d5/a3-a4
	unlk	a6
	rts
L36:
	lea	34(a4),a4
	addq.w	#1,d5
	bra	L33
L35:
	clr.w	d0
	bra	L25
L31:
	addq.w	#1,d3
	bra	L26
L30:
	subq.w	#1,d3
	bra	L26
L29:
	addq.w	#1,d4
	bra	L26
L28:
	subq.w	#1,d4
	bra	L26
	.text
	.globl	_actor_move
_actor_move:
	link	a6,#-4
	movem.l	d3-d4/a3,-(sp)
	moveq.l	#34,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a3
	move.l	d1,-(sp)
	jsr	_handle_walker
	addq.w	#4,sp
	tst.w	8(a6)
	bne	L41
	move.w	(a3),d0
	sub.w	#152,d0
	move.w	d0,_actor_map_x
	move.w	2(a3),d0
	sub.w	#104,d0
	move.w	d0,_actor_map_y
L41:
	move.w	_map_coord_x_mask,d0
	and.w	d0,(a3)
	move.w	_map_coord_y_mask,d0
	and.w	d0,2(a3)
	move.w	_map_w_mask,d0
	and.w	d0,4(a3)
	move.w	_map_h_mask,d0
	and.w	d0,6(a3)
	movem.l	(sp)+,d3-d4/a3
	unlk	a6
	rts
	.text
	.globl	_actor_draw
_actor_draw:
	link	a6,#0
	move.l	a3,-(sp)
	moveq.l	#34,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,-(sp)
	jsr	_draw_walker
	addq.w	#4,sp
	move.l	(sp)+,a3
	unlk	a6
	rts
	.text
	.globl	_actor_exec_all
_actor_exec_all:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.l	#_actor_sprites,a3
	move.l	#_actor_progs,a4
	moveq.l	#0,d3
L48:
	cmp.w	#64,d3
	beq	L47
	move.w	32(a3),d0
	and.w	#1,d0
	bne	L51
	move.l	a4,-(sp)
	jsr	_zop_exec_frame
	addq.w	#4,sp
L51:
	lea	20(a4),a4
	lea	34(a3),a3
	addq.w	#1,d3
	bra	L48
L47:
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_actor_move_all
_actor_move_all:
	link	a6,#0
	movem.l	d3/a3,-(sp)
	move.l	#_actor_sprites,a3
	moveq.l	#0,d3
L55:
	cmp.w	#64,d3
	beq	L54
	move.w	32(a3),d0
	and.w	#1,d0
	bne	L58
	move.w	d3,-(sp)
	jsr	_actor_move
	addq.w	#2,sp
L58:
	lea	34(a3),a3
	addq.w	#1,d3
	bra	L55
L54:
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
	.data
	.text
	.globl	_actor_draw_all
_actor_draw_all:
	link	a6,#-200
	movem.l	d3/d4/d5/d6/d7/a3,-(sp)
	lea	-64(a6),a0
	move.l	a0,d6
	lea	-196(a6),a0
	move.l	a0,d7
	move.l	#_actor_sprites,a3
	moveq.l	#0,d4
	moveq.l	#0,d3
L62:
	cmp.w	#64,d3
	beq	L64
	move.w	2(a3),d0
	sub.w	_actor_map_y,d0
	sub.w	#16,d0
	move.w	d0,d5
	cmp.w	#-32,d5
	ble	L65
	cmp.w	#240,d5
	bge	L65
	move.w	32(a3),d0
	and.w	#1,d0
	bne	L65
	move.l	d6,a0
	move.b	d3,(a0)
	addq.l	#1,d6
	move.w	d5,d0
	neg.w	d0
	move.l	d7,a0
	move.w	d0,(a0)
	addq.l	#2,d7
	addq.w	#1,d4
L65:
	lea	34(a3),a3
	addq.w	#1,d3
	bra	L62
L64:
	move.w	d4,-(sp)
	pea	-196(a6)
	pea	-64(a6)
	jsr	_quicksort_zorder
	lea	10(sp),sp
	move.w	#1,_wlk_sprnum
	moveq.l	#0,d3
L66:
	cmp.w	d4,d3
	beq	L61
	moveq.l	#0,d0
	move.w	d3,d0
	lea	-64(a6,d0.l),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,-(sp)
	jsr	_actor_draw
	addq.w	#2,sp
	addq.w	#1,d3
	bra	L66
L61:
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3
	unlk	a6
	rts
