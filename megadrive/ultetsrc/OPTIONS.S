	.bss
	.globl	_curr_game_mode
	.comm	_curr_game_mode,2
	.globl	_plf_opt
	.comm	_plf_opt,70
	.globl	_curr_plf_opt
	.comm	_curr_plf_opt,4
	.data
	.globl	_wh_settings
_wh_settings:
	.dc.w	10
	.dc.w	22
	.dc.w	0
	.dc.w	8
	.dc.w	20
	.dc.w	1
	.dc.w	12
	.dc.w	26
	.dc.w	2
	.dc.w	8
	.dc.w	22
	.dc.w	3
	.data
	.text
	.globl	_init_options
_init_options:
	link	a6,#0
	move.l	d3,-(sp)
	moveq.l	#0,d3
L3:
	cmp.w	#4,d3
	beq	L5
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#0,(a0)
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#14,2(a0)
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#30,4(a0)
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#0,6(a0)
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#0,8(a0)
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#0,10(a0)
	moveq.l	#14,d0
	mulu	d3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_plf_opt,d1
	move.l	d1,a0
	move.w	#4,12(a0)
	addq.w	#1,d3
	bra	L3
L5:
	move.l	#_plf_opt,_curr_plf_opt
	move.l	(sp)+,d3
	unlk	a6
	rts
