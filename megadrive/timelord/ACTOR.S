	.bss
	.globl	_actor_sprites
	.comm	_actor_sprites,1680
	.globl	_actor_map_x
	.comm	_actor_map_x,2
	.globl	_actor_map_y
	.comm	_actor_map_y,2
	.data
	.text
	.globl	_actor_move
_actor_move:
	link	a6,#-4
	movem.l	d3/d4/d5/d6/a3,-(sp)
	moveq.l	#42,d0
	mulu	8(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a3
	move.w	2(a3),d5
	move.w	4(a3),d6
	move.l	a3,-(sp)
	jsr	_sprite_move
	addq.w	#4,sp
	move.w	2(a3),d3
	move.w	4(a3),d4
	movem.l	(sp)+,d3/d4/d5/d6/a3
	unlk	a6
	rts
