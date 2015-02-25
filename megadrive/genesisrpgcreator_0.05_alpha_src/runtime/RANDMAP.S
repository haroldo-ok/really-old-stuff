	.bss
	.globl	_randmap_rooms
	.comm	_randmap_rooms,128
	.globl	_randmap_room_order
	.comm	_randmap_room_order,32
	.text
	.globl	_randmap_reorder_rooms
_randmap_reorder_rooms:
	link	a6,#0
	movem.l	d3-d6,-(sp)
	moveq.l	#0,d3
L3:
	cmp.w	#16,d3
	beq	L5
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_randmap_room_order,d1
	move.l	d1,a0
	move.w	d3,(a0)
	addq.w	#1,d3
	bra	L3
L5:
	moveq.l	#16,d3
L6:
	tst.w	d3
	beq	L2
	move.w	#16,-(sp)
	jsr	_random
	move.w	d0,d4
	move.w	#16,(sp)
	jsr	_random
	addq.w	#2,sp
	move.w	d0,d5
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_randmap_room_order,d1
	move.l	d1,a0
	move.w	(a0),d6
	move.w	d5,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_randmap_room_order,d1
	move.l	d1,a0
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_randmap_room_order,d1
	move.l	d1,a1
	move.w	(a0),(a1)
	move.w	d5,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_randmap_room_order,d1
	move.l	d1,a0
	move.w	d6,(a0)
	subq.w	#1,d3
	bra	L6
L2:
	movem.l	(sp)+,d3-d6
	unlk	a6
	rts
	.text
	.globl	_randmap_link_rooms
_randmap_link_rooms:
	link	a6,#-2
	movem.l	d3-d7/a3-a4,-(sp)
	move.l	8(a6),a3
	move.l	12(a6),a4
	move.w	4(a3),d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	jsr	_random
	add.w	2(a3),d0
	addq.w	#1,d0
	move.w	d0,d3
	move.w	6(a3),d0
	subq.w	#2,d0
	move.w	d0,(sp)
	jsr	_random
	add.w	(a3),d0
	addq.w	#1,d0
	move.w	d0,d4
	move.w	4(a4),d0
	subq.w	#2,d0
	move.w	d0,(sp)
	jsr	_random
	add.w	2(a4),d0
	addq.w	#1,d0
	move.w	d0,d5
	move.w	6(a4),d0
	subq.w	#2,d0
	move.w	d0,(sp)
	jsr	_random
	add.w	(a4),d0
	addq.w	#1,d0
	move.w	d0,d6
	move.w	d3,d0
	add.w	d5,d0
	lsr.w	#1,d0
	move.w	d0,d7
	move.w	d4,d0
	add.w	d6,d0
	lsr.w	#1,d0
	move.w	d0,-2(a6)
	move.w	#2,(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	beq	L23
L13:
	cmp.w	d5,d3
	bne	L16
	cmp.w	d6,d4
	beq	L11
L16:
	cmp.w	d7,d3
	beq	L19
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	tst.b	d0
	beq	L18
	move.w	#1,-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
L18:
	addq.w	#1,d3
	and.w	_map_w_mask,d3
	bra	L16
L19:
	cmp.w	-2(a6),d4
	beq	L20
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	tst.b	d0
	beq	L21
	move.w	#1,-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
L21:
	addq.w	#1,d4
	and.w	_map_h_mask,d4
	bra	L19
L20:
	move.w	d5,d7
	move.w	d6,-2(a6)
	bra	L13
L11:
	movem.l	(sp)+,d3-d7/a3-a4
	unlk	a6
	rts
L23:
	cmp.w	d5,d3
	bne	L26
	cmp.w	d6,d4
	beq	L11
L26:
	cmp.w	d7,d3
	beq	L29
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	tst.b	d0
	beq	L28
	move.w	#1,-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
L28:
	addq.w	#1,d3
	and.w	_map_w_mask,d3
	bra	L26
L29:
	cmp.w	-2(a6),d4
	beq	L30
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	tst.b	d0
	beq	L31
	move.w	#1,-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
L31:
	addq.w	#1,d4
	and.w	_map_h_mask,d4
	bra	L29
L30:
	move.w	d5,d7
	move.w	d6,-2(a6)
	bra	L23
	.data
	.text
	.globl	_randmap_build
_randmap_build:
	link	a6,#-2
	movem.l	d3-d7/a3-a4,-(sp)
	move.w	_map_w,d0
	lsr.w	#2,d0
	move.w	d0,d5
	move.w	_map_h,d0
	lsr.w	#2,d0
	move.w	d0,d6
	move.w	#8,-(sp)
	move.w	_map_h,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	_map_w,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_rpg_map_draw_rectangle
	lea	10(sp),sp
	moveq.l	#0,d7
	move.w	#0,-2(a6)
	move.l	#_randmap_rooms,a3
	moveq.l	#0,d3
L35:
	cmp.w	#4,d3
	beq	L37
	moveq.l	#0,d7
	moveq.l	#0,d4
L38:
	cmp.w	#4,d4
	beq	L40
	move.w	d5,d0
	sub.w	#10,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	jsr	_random
	addq.w	#1,d0
	move.w	d0,2(a3)
	move.w	d6,d0
	sub.w	#10,d0
	subq.w	#2,d0
	move.w	d0,(sp)
	jsr	_random
	addq.w	#1,d0
	move.w	d0,(a3)
	move.w	d5,d0
	sub.w	2(a3),d0
	sub.w	#10,d0
	move.w	d0,(sp)
	jsr	_random
	add.w	#10,d0
	move.w	d0,4(a3)
	move.w	d6,d0
	sub.w	(a3),d0
	sub.w	#10,d0
	move.w	d0,(sp)
	jsr	_random
	add.w	#10,d0
	move.w	d0,6(a3)
	add.w	d7,2(a3)
	move.w	-2(a6),d0
	add.w	d0,(a3)
	move.w	#4,(sp)
	move.w	(a3),d0
	add.w	6(a3),d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	add.w	4(a3),d0
	move.w	d0,-(sp)
	move.w	(a3),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_rpg_map_draw_rectangle
	lea	10(sp),sp
	clr.w	-(sp)
	move.w	(a3),d0
	add.w	6(a3),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	add.w	4(a3),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	(a3),-(sp)
	move.w	2(a3),-(sp)
	jsr	_rpg_map_draw_rectangle
	lea	10(sp),sp
	add.w	d5,d7
	addq.l	#8,a3
	addq.w	#1,d4
	bra	L38
L40:
	add.w	d6,-2(a6)
	addq.w	#1,d3
	bra	L35
L37:
	jsr	_randmap_reorder_rooms
	move.l	#_randmap_rooms,a3
	lea	8(a3),a4
	moveq.l	#15,d3
L41:
	tst.w	d3
	beq	L43
	move.l	a4,-(sp)
	move.l	a3,-(sp)
	jsr	_randmap_link_rooms
	addq.w	#8,sp
	addq.l	#8,a3
	addq.l	#8,a4
	subq.w	#1,d3
	bra	L41
L43:
	move.l	#_randmap_rooms,a3
	move.w	4(a3),d0
	lsr.w	#1,d0
	add.w	2(a3),d0
	move.w	d0,_map_x
	move.w	6(a3),d0
	lsr.w	#1,d0
	add.w	(a3),d0
	move.w	d0,_map_y
	movem.l	(sp)+,d3-d7/a3-a4
	unlk	a6
	rts
