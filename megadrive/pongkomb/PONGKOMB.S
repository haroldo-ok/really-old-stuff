	.text
	.globl	_main
_main:
	link	a6,#0
	movem.l	d3-d5,-(sp)
	jsr	_init_GFX
	jsr	_wait_sync
	jsr	_init_GFS
	jsr	_init_joypad
L3:
	jsr	_atract_mode
	bra	L3
	.text
	.globl	_show_atract_screen
_show_atract_screen:
	link	a6,#-4
	movem.l	d3/d4/d5,-(sp)
	move.w	8(a6),d3
	move.w	#350,d4
	move.w	d3,d0
	beq	L10
	cmp.w	#1,d0
	beq	L11
	cmp.w	#2,d0
	beq	L12
	cmp.w	#3,d0
	beq	L13
	cmp.w	#4,d0
	beq	L14
	cmp.w	#5,d0
	beq	L15
	cmp.w	#6,d0
	beq	L16
	cmp.w	#7,d0
	beq	L17
L8:
	move.w	d3,-(sp)
	jsr	_load_bkgnd
	addq.w	#2,sp
	jsr	_read_joypad1
	move.w	d0,-(sp)
	jsr	_read_joypad2
	or.w	(sp)+,d0
	move.w	d0,d5
L19:
	move.w	d5,d0
	and.w	#128,d0
	bne	L7
	tst.w	d4
	beq	L7
	jsr	_wait_sync
	jsr	_read_joypad1
	move.w	d0,-(sp)
	jsr	_read_joypad2
	or.w	(sp)+,d0
	move.w	d0,d5
	subq.w	#1,d4
	bra	L19
L7:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
L17:
	move.w	#5,-(sp)
	jsr	_random
	addq.w	#2,sp
	add.w	#26,d0
	move.w	d0,d3
	bra	L8
L16:
	moveq.l	#10,d3
	bra	L8
L15:
	moveq.l	#8,d3
	moveq.l	#70,d4
	bra	L8
L14:
	moveq.l	#9,d3
	moveq.l	#70,d4
	bra	L8
L13:
	moveq.l	#2,d3
	bra	L8
L12:
	move.w	#5,-(sp)
	jsr	_random
	addq.w	#2,sp
	add.w	#26,d0
	move.w	d0,d3
	bra	L8
L11:
	moveq.l	#1,d3
	bra	L8
L10:
	moveq.l	#0,d3
	bra	L8
	.data
	.text
	.globl	_atract_mode
_atract_mode:
	link	a6,#-4
	movem.l	d3/d4,-(sp)
	jsr	_read_joypad1
	move.w	d0,-(sp)
	jsr	_read_joypad2
	or.w	(sp)+,d0
	move.w	d0,d3
L24:
	move.w	d3,d0
	and.w	#128,d0
	bne	L23
	clr.w	-(sp)
	jsr	_show_atract_screen
	addq.w	#2,sp
	move.w	d0,d3
	and.w	#128,d0
	bne	L24
	moveq.l	#1,d4
L27:
	cmp.w	#8,d4
	beq	L24
	move.w	d3,d0
	and.w	#128,d0
	bne	L24
	move.w	d4,-(sp)
	jsr	_show_atract_screen
	addq.w	#2,sp
	move.w	d0,d3
	addq.w	#1,d4
	bra	L27
L23:
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
