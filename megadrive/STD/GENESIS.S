	.bss
	.globl	_vtimer
	.comm	_vtimer,4
	.globl	_sprites_def
	.comm	_sprites_def,800
	.data
	.globl	_pal_black
_pal_black:
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.text
	.globl	_dma_vram_copy
_dma_vram_copy:
	link	a6,#0
	movem.l	d3/d4/d5/a3/a4,-(sp)
	move.w	12(a6),d5
	move.w	14(a6),d4
	move.l	8(a6),d3
	move.l	#10555648,a3
	move.w	#256,(a3)
	move.l	#12582916,a3
	move.w	d4,d0
	lsr.w	#1,d0
	move.w	d0,d4
	and.w	#255,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#37632,d1
	move.w	d1,(a3)
	move.w	d4,d0
	lsr.w	#8,d0
	and.w	#255,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#37888,d1
	move.w	d1,(a3)
	move.l	d3,d0
	lsr.l	#1,d0
	move.l	d0,d3
	and.l	#255,d0
	add.l	#38144,d0
	move.w	d0,(a3)
	move.l	d3,d0
	lsr.l	#8,d0
	move.l	d0,d3
	and.l	#255,d0
	add.l	#38400,d0
	move.w	d0,(a3)
	move.l	d3,d0
	lsr.l	#8,d0
	move.l	d0,d3
	and.l	#255,d0
	add.l	#38656,d0
	move.w	d0,(a3)
	move.l	#12582916,a4
	moveq.l	#0,d0
	move.w	d5,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	asl.l	d1,d0
	moveq.l	#0,d1
	move.w	d5,d1
	moveq.l	#14,d2
	asr.l	d2,d1
	or.l	#128,d1
	add.l	d1,d0
	move.l	d0,(a4)
	move.l	#10555648,a3
	move.w	#0,(a3)
	movem.l	(sp)+,d3/d4/d5/a3/a4
	unlk	a6
	rts
	.text
	.globl	_show_tiles
_show_tiles:
	link	a6,#0
	movem.l	d3-d4/a3-a4,-(sp)
	move.w	16(a6),d0
	mulu	_extWIDTH,d0
	add.w	14(a6),d0
	lsl.w	#1,d0
	add.w	18(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d3
	move.l	#12582916,a3
	move.l	d3,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d3,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	move.w	24(a6),d0
	moveq.l	#11,d1
	lsl.w	d1,d0
	move.w	22(a6),d1
	moveq.l	#12,d2
	lsl.w	d2,d1
	add.w	d1,d0
	move.w	12(a6),d1
	moveq.l	#13,d2
	lsl.w	d2,d1
	add.w	d1,d0
	move.w	20(a6),d1
	moveq.l	#15,d2
	lsl.w	d2,d1
	add.w	d1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d4
	moveq.l	#0,d0
	move.w	8(a6),d0
	move.l	d0,d3
L6:
	move.w	10(a6),d0
	addq.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	cmp.l	d1,d3
	bcc	L5
	move.l	d4,d0
	add.l	d3,d0
	move.w	d0,(a4)
	addq.l	#1,d3
	bra	L6
L5:
	movem.l	(sp)+,d3-d4/a3-a4
	unlk	a6
	rts
	.text
	.globl	_load_tiles_sp
_load_tiles_sp:
	link	a6,#0
	movem.l	d3/d4/a3,-(sp)
	move.w	12(a6),d4
	addq.w	#1,d4
	move.l	#12582916,a3
	move.l	#1073741824,(a3)
	move.l	#12582912,a3
	moveq.l	#0,d3
L12:
	move.w	d4,d0
	lsl.w	#3,d0
	cmp.w	d0,d3
	bcc	L11
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	8(a6),d1
	move.l	d1,a0
	move.l	(a0),(a3)
	addq.w	#1,d3
	bra	L12
L11:
	movem.l	(sp)+,d3/d4/a3
	unlk	a6
	rts
	.text
	.globl	_def_sprite
_def_sprite:
	link	a6,#-2
	movem.l	d3/d4,-(sp)
	move.w	8(a6),d4
	move.w	d4,d0
	subq.w	#1,d0
	mulu	#5,d0
	move.w	d0,d3
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	12(a6),(a0)
	move.w	d3,d0
	addq.w	#1,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	14(a6),(a0)
	move.w	d3,d0
	addq.w	#2,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	d4,(a0)
	move.w	d3,d0
	addq.w	#3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	16(a6),(a0)
	move.w	d3,d0
	addq.w	#4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	10(a6),(a0)
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_show_sprite
_show_sprite:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.l	#12582916,a3
	move.l	#2080374786,(a3)
	move.l	#12582912,a4
	move.w	8(a6),d0
	subq.w	#1,d0
	mulu	#5,d0
	move.w	d0,d3
L21:
	moveq.l	#5,d0
	mulu	10(a6),d0
	cmp.w	d0,d3
	bcc	L20
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	(a0),d0
	add.w	#128,d0
	move.w	d0,(a4)
	move.w	d3,d0
	addq.w	#1,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	d3,d0
	addq.w	#2,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a1
	move.w	(a0),d0
	or.w	(a1),d0
	move.w	d0,(a4)
	move.w	d3,d0
	addq.w	#3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	(a0),(a4)
	move.w	d3,d0
	addq.w	#4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_sprites_def,d1
	move.l	d1,a0
	move.w	(a0),d0
	add.w	#128,d0
	move.w	d0,(a4)
	move.w	d3,d0
	addq.w	#5,d0
	move.w	d0,d3
	bra	L21
L20:
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_reset_sprites
_reset_sprites:
	link	a6,#0
	movem.l	d3/a3,-(sp)
	move.l	#12582916,a3
	move.l	#2080374786,(a3)
	move.l	#12582912,a3
	moveq.l	#0,d3
L27:
	move.w	8(a6),d0
	addq.w	#1,d0
	mulu	#1024,d0
	cmp.w	d0,d3
	bcc	L26
	move.l	#0,(a3)
	addq.w	#1,d3
	bra	L27
L26:
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
	.text
	.globl	_set_colors
_set_colors:
	link	a6,#0
	movem.l	d3-d4/a3-a4,-(sp)
	move.w	8(a6),d0
	lsl.w	#5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d4
	move.l	#12582916,a3
	move.l	d4,d0
	and.l	#16383,d0
	add.l	#-16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d4,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d3
L33:
	cmp.w	#16,d3
	bcc	L32
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	10(a6),d1
	move.l	d1,a0
	move.w	(a0),(a4)
	addq.w	#1,d3
	bra	L33
L32:
	movem.l	(sp)+,d3-d4/a3-a4
	unlk	a6
	rts
	.text
	.globl	_fade_in
_fade_in:
	link	a6,#-32
	movem.l	d3-d6/a3-a5,-(sp)
	move.w	12(a6),d0
	lsl.w	#5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d6
	moveq.l	#0,d3
L39:
	cmp.w	#16,d3
	bcc	L41
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	#0,-32(a6,d1.l)
	addq.w	#1,d3
	bra	L39
L41:
	moveq.l	#0,d3
L42:
	cmp.w	#16,d3
	bcc	L38
	move.l	8(a6),a5
	move.l	#12582916,a3
	move.l	d6,d0
	and.l	#16383,d0
	add.l	#-16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d6,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d4
L45:
	cmp.w	#16,d4
	bcc	L47
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#3840,d0
	move.w	d0,d5
	move.w	(a5),d0
	and.w	#3840,d0
	cmp.w	d0,d5
	bcc	L48
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	add.w	#256,(a0)
L48:
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#240,d0
	move.w	d0,d5
	move.w	(a5),d0
	and.w	#240,d0
	cmp.w	d0,d5
	bcc	L49
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	add.w	#16,(a0)
L49:
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#15,d0
	move.w	d0,d5
	move.w	(a5)+,d0
	and.w	#15,d0
	cmp.w	d0,d5
	bcc	L50
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	addq.w	#1,(a0)
L50:
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),(a4)
	addq.w	#1,d4
	bra	L45
L47:
	moveq.l	#0,d4
L51:
	cmp.w	#4,d4
	bcc	L43
	jsr	_wait_sync
	addq.w	#1,d4
	bra	L51
L43:
	addq.w	#1,d3
	bra	L42
L38:
	movem.l	(sp)+,d3-d6/a3-a5
	unlk	a6
	rts
	.text
	.globl	_init_joypad
_init_joypad:
	link	a6,#0
	move.l	a3,-(sp)
	move.l	#10551305,a3
	move.b	#64,(a3)
	addq.l	#2,a3
	move.b	#64,(a3)
	addq.l	#2,a3
	move.b	#64,(a3)
	move.l	(sp)+,a3
	unlk	a6
	rts
	.text
	.globl	_read_joypad1
_read_joypad1:
	link	a6,#0
	movem.l	d3-d4/a3,-(sp)
	move.l	#10551299,a3
	move.b	#64,(a3)
	nop
	nop
	clr.w	d0
	move.b	(a3),d0
	and.w	#63,d0
	move.w	d0,d3
	move.b	#0,(a3)
	nop
	nop
	clr.w	d0
	move.b	(a3),d0
	and.w	#48,d0
	asl.w	#2,d0
	move.w	d0,d4
	move.w	d3,d0
	or.w	d4,d0
	not.w	d0
	movem.l	(sp)+,d3-d4/a3
	unlk	a6
	rts
	.text
	.globl	_read_joypad2
_read_joypad2:
	link	a6,#0
	movem.l	d3-d4/a3,-(sp)
	move.l	#10551301,a3
	move.b	#64,(a3)
	nop
	nop
	clr.w	d0
	move.b	(a3),d0
	and.w	#63,d0
	move.w	d0,d3
	move.b	#0,(a3)
	nop
	nop
	clr.w	d0
	move.b	(a3),d0
	and.w	#48,d0
	asl.w	#2,d0
	move.w	d0,d4
	move.w	d3,d0
	or.w	d4,d0
	not.w	d0
	movem.l	(sp)+,d3-d4/a3
	unlk	a6
	rts
	.text
	.globl	_wait_press
_wait_press:
	link	a6,#-4
	movem.l	d3/d4,-(sp)
	jsr	_init_joypad
	moveq.l	#0,d3
L66:
	tst.w	d3
	bne	L65
	jsr	_read_joypad1
	move.w	d0,d4
	beq	L66
	move.w	d4,d0
	and.w	#255,d0
	cmp.w	#16,d0
	beq	L72
	cmp.w	#32,d0
	beq	L73
	cmp.w	#64,d0
	beq	L71
	cmp.w	#128,d0
	bne	L66
	moveq.l	#1,d3
	bra	L66
L71:
	moveq.l	#1,d3
	bra	L66
L73:
	moveq.l	#1,d3
	bra	L66
L72:
	moveq.l	#1,d3
	bra	L66
L65:
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_play_sample
_play_sample:
	link	a6,#0
	movem.l	d3/d4/a3/a4,-(sp)
	move.l	12(a6),d4
	move.l	8(a6),d3
	move.l	#10555648,a3
	move.w	#256,(a3)
	move.l	#10485817,a4
	move.b	#1,(a4)+
	move.l	d3,d0
	and.l	#255,d0
	move.b	d0,(a4)+
	move.l	d3,d0
	lsr.l	#8,d0
	and.l	#255,d0
	move.b	d0,(a4)+
	move.l	d3,d0
	moveq.l	#16,d1
	lsr.l	d1,d0
	and.l	#255,d0
	move.b	d0,(a4)+
	move.l	d4,d0
	and.l	#255,d0
	move.b	d0,(a4)+
	move.l	d4,d0
	lsr.l	#8,d0
	and.l	#255,d0
	move.b	d0,(a4)+
	move.l	d4,d0
	moveq.l	#16,d1
	lsr.l	d1,d0
	and.l	#255,d0
	move.b	d0,(a4)+
	move.l	#10555648,a3
	move.w	#0,(a3)
	movem.l	(sp)+,d3/d4/a3/a4
	unlk	a6
	rts
	.text
	.globl	_scrollv_A
_scrollv_A:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	#12582912,a3
	move.l	#12582916,a4
	move.l	#1073741840,(a4)
	move.w	8(a6),(a3)
	jsr	_wait_sync
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
	.text
	.globl	_scrollv
_scrollv:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	#12582912,a3
	move.l	#12582916,a4
	move.l	#1073741840,(a4)
	move.w	8(a6),(a3)
	move.w	10(a6),(a3)
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
	.text
	.globl	_scrollh
_scrollh:
	link	a6,#0
	movem.l	a3-a4,-(sp)
	move.l	#12582916,a4
	move.l	#2013265922,(a4)
	move.l	#12582912,a3
	move.w	8(a6),(a3)
	move.w	10(a6),(a3)
	jsr	_wait_sync
	movem.l	(sp)+,a3-a4
	unlk	a6
	rts
	.text
	.globl	_RAZ
_RAZ:
	link	a6,#-2
	move.l	#_pal_black,-(sp)
	clr.w	-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#_pal_black,-(sp)
	move.w	#1,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#_pal_black,-(sp)
	move.w	#2,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#_pal_black,-(sp)
	move.w	#3,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	jsr	_clrscr
	move.w	#1,-(sp)
	jsr	_reset_sprites
	addq.w	#2,sp
	clr.w	-(sp)
	jsr	_scrollv_A
	addq.w	#2,sp
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	jsr	_wait_sync
	unlk	a6
	rts
	.data
	.text
	.globl	_wait_sync
_wait_sync:
	link	a6,#0
	move.l	d3,-(sp)
	move.l	_vtimer,d3
L94:
	cmp.l	_vtimer,d3
	beq	L94
	move.l	(sp)+,d3
	unlk	a6
	rts
