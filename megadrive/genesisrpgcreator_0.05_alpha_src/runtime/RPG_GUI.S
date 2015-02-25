	.text
	.globl	_gui_init
_gui_init:
	link	a6,#-4
	move.l	#L3,-(sp)
	pea	-4(a6)
	jsr	_get_GFS_fileaddr
	addq.w	#8,sp
	move.w	#1,-(sp)
	move.w	#15,-(sp)
	move.w	#256,-(sp)
	move.w	#1,-(sp)
	move.l	-4(a6),d0
	addq.l	#8,d0
	move.l	d0,-(sp)
	jsr	_loadfont
	lea	12(sp),sp
	jsr	_init_text_mode
	move.b	#224,_text_info+4
	move.l	#L4,-(sp)
	pea	-4(a6)
	jsr	_get_GFS_fileaddr
	addq.w	#8,sp
	move.l	-4(a6),-(sp)
	move.w	#8,-(sp)
	move.w	#248,-(sp)
	jsr	_set_bkg_data
	unlk	a6
	rts
	.text
	.globl	_gui_clear
_gui_clear:
	link	a6,#0
	clr.w	-(sp)
	move.w	#49152,-(sp)
	move.w	#28,-(sp)
	move.w	#40,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_fill_bkg_rect
	unlk	a6
	rts
	.text
	.globl	_gui_draw_frame
_gui_draw_frame:
	link	a6,#0
	movem.l	d3-d6,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	move.w	12(a6),d5
	move.w	14(a6),d6
	move.w	#57376,-(sp)
	move.w	#49152,-(sp)
	move.w	d6,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d4,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d3,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.w	#57596,-(sp)
	move.w	#49152,-(sp)
	move.w	#1,-(sp)
	move.w	d5,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d4,-(sp)
	move.w	d3,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.w	#57597,-(sp)
	move.w	#49152,-(sp)
	move.w	#1,-(sp)
	move.w	d5,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d4,d0
	add.w	d6,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d3,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.w	#57598,-(sp)
	move.w	#49152,-(sp)
	move.w	d6,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	move.w	#1,-(sp)
	move.w	d4,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.w	#57599,-(sp)
	move.w	#49152,-(sp)
	move.w	d6,d0
	subq.w	#2,d0
	move.w	d0,-(sp)
	move.w	#1,-(sp)
	move.w	d4,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d3,d0
	add.w	d5,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_fill_bkg_rect
	lea	12(sp),sp
	move.w	#49152,-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	move.w	#57344,-(sp)
	move.w	#248,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
	move.w	#49152,-(sp)
	move.w	d4,-(sp)
	move.w	d3,d0
	add.w	d5,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	#57344,-(sp)
	move.w	#249,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
	move.w	#49152,-(sp)
	move.w	d4,d0
	add.w	d6,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	move.w	#57344,-(sp)
	move.w	#250,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
	move.w	#49152,-(sp)
	move.w	d4,d0
	add.w	d6,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d3,d0
	add.w	d5,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	#57344,-(sp)
	move.w	#251,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
	movem.l	(sp)+,d3-d6
	unlk	a6
	rts
	.text
	.globl	_gui_pager
_gui_pager:
	link	a6,#-2
	movem.l	d3/d4/d5/d6/d7/a3/a4/a5,-(sp)
	move.w	12(a6),d7
	move.w	10(a6),d6
	move.w	8(a6),d5
	move.l	16(a6),a3
	addq.w	#1,d5
	addq.w	#1,d6
	subq.w	#2,d7
	subq.w	#2,14(a6)
	move.w	#112,-(sp)
	jsr	_wait_btn_release
	addq.w	#2,sp
L14:
	tst.b	(a3)
	beq	L13
	move.w	14(a6),d0
	addq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d7,d0
	addq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d6,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_gui_draw_frame
	addq.w	#8,sp
	move.w	d6,d0
	add.w	14(a6),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	add.w	d7,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d6,-(sp)
	move.w	d5,-(sp)
	jsr	_window
	addq.w	#8,sp
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	jsr	_gotoxy
	addq.w	#4,sp
	move.l	a3,a4
	move.w	14(a6),d3
L16:
	tst.b	(a4)
	beq	L17
	tst.w	d3
	beq	L17
	moveq.l	#0,d4
	move.l	a3,a5
L18:
	tst.b	(a4)
	beq	L19
	cmp.b	#10,(a4)
	beq	L19
	cmp.w	d7,d4
	bhi	L19
	cmp.b	#32,(a4)
	beq	L21
	cmp.b	#9,(a4)
	bne	L20
L21:
	move.l	a4,a5
L20:
	addq.l	#1,a4
	addq.w	#1,d4
	bra	L18
L19:
	tst.b	(a4)
	beq	L23
	cmp.b	#10,(a4)
	bne	L22
L23:
	move.l	a4,a5
L22:
	cmp.l	a3,a5
	bne	L25
	move.l	a4,a5
L25:
	cmp.l	a5,a3
	beq	L26
	move.b	(a3),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_putch
	addq.w	#2,sp
	addq.l	#1,a3
	bra	L25
L26:
	move.w	#10,-(sp)
	jsr	_putch
	addq.w	#2,sp
	tst.b	(a5)
	beq	L27
	lea	1(a5),a4
	move.l	a4,a3
L27:
	subq.w	#1,d3
	bra	L16
L17:
	move.w	#0,-2(a6)
L28:
	jsr	_read_joypad1
	move.w	d0,-(sp)
	jsr	_read_joypad2
	or.w	(sp)+,d0
	and.w	#112,d0
	bne	L29
	move.w	-2(a6),d0
	and.w	#8,d0
	beq	L30
	move.w	#49152,-(sp)
	move.w	d6,d0
	add.w	14(a6),d0
	move.w	d0,-(sp)
	move.w	d5,d0
	add.w	d7,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	#57344,-(sp)
	move.w	#31,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
L31:
	jsr	_wait_sync
	addq.w	#1,-2(a6)
	bra	L28
L30:
	move.w	#49152,-(sp)
	move.w	d6,d0
	add.w	14(a6),d0
	move.w	d0,-(sp)
	move.w	d5,d0
	add.w	d7,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	#57344,-(sp)
	move.w	#253,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
	bra	L31
L29:
	move.w	#112,-(sp)
	jsr	_wait_btn_release
	addq.w	#2,sp
	bra	L14
L13:
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3/a4/a5
	unlk	a6
	rts
	.data
L4:	.dc.b	$49,$4e,$54,$45,$52,$46,$43,$2e,$54,$49,$4c
	.dc.b	0
L3:	.dc.b	$46,$4f,$4e,$54,$2e,$43,$48,$52
	.dc.b	0
	.text
	.globl	_gui_menu
_gui_menu:
	link	a6,#-14
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.w	10(a6),d4
	addq.w	#1,8(a6)
	addq.w	#1,d4
	subq.w	#2,12(a6)
	subq.w	#2,14(a6)
	subq.w	#2,16(a6)
	subq.w	#2,18(a6)
	moveq.l	#0,d3
	moveq.l	#0,d6
L35:
	move.w	d6,d0
	cmp.w	24(a6),d0
	beq	L37
	move.w	d6,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	20(a6),d1
	move.l	d1,a0
	move.l	(a0),-(sp)
	jsr	_strlen
	addq.w	#4,sp
	addq.w	#1,d0
	move.w	d0,-12(a6)
	cmp.w	d3,d0
	bls	L36
	move.w	-12(a6),d3
L36:
	addq.w	#1,d6
	bra	L35
L37:
	move.w	24(a6),d5
	move.w	d3,d0
	cmp.w	12(a6),d0
	bcc	L39
	move.w	12(a6),d3
L39:
	move.w	d3,d0
	cmp.w	14(a6),d0
	bls	L40
	move.w	14(a6),d3
L40:
	move.w	d5,d0
	cmp.w	16(a6),d0
	bcc	L41
	move.w	16(a6),d5
L41:
	move.w	d5,d0
	cmp.w	18(a6),d0
	bls	L42
	move.w	18(a6),d5
L42:
	tst.w	26(a6)
	beq	L43
	move.w	d4,d0
	add.w	16(a6),d0
	sub.w	d5,d0
	move.w	d0,d4
L43:
	move.w	#115,-(sp)
	jsr	_wait_btn_release
	addq.w	#2,sp
	moveq.l	#0,d7
	move.w	#0,-8(a6)
L44:
	move.w	-8(a6),d0
	and.w	#112,d0
	bne	L45
	move.w	d5,d0
	addq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d3,d0
	addq.w	#2,d0
	move.w	d0,-(sp)
	move.w	d4,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	8(a6),d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	jsr	_gui_draw_frame
	addq.w	#8,sp
	move.w	d4,d0
	add.w	d5,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
	move.w	8(a6),d0
	add.w	d3,d0
	subq.w	#1,d0
	move.w	d0,-(sp)
	move.w	d4,-(sp)
	move.w	8(a6),-(sp)
	jsr	_window
	addq.w	#8,sp
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	jsr	_gotoxy
	addq.w	#4,sp
	moveq.l	#0,d6
L46:
	move.w	d6,d0
	cmp.w	24(a6),d0
	beq	L48
	move.w	#32,-(sp)
	jsr	_putch
	addq.w	#2,sp
	move.w	d6,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	20(a6),d1
	move.l	d1,a0
	move.l	(a0),-(sp)
	jsr	_cputs
	addq.w	#4,sp
	move.w	#10,-(sp)
	jsr	_putch
	addq.w	#2,sp
	addq.w	#1,d6
	bra	L46
L48:
	move.w	#115,-(sp)
	jsr	_wait_btn_release
	addq.w	#2,sp
	move.w	#0,-6(a6)
	move.w	#0,-8(a6)
L49:
	move.w	-8(a6),d0
	and.w	#115,d0
	bne	L50
	move.w	-6(a6),d0
	and.w	#8,d0
	beq	L51
	move.w	#49152,-(sp)
	move.w	d4,d0
	add.w	d7,d0
	move.w	d0,-(sp)
	move.w	8(a6),-(sp)
	move.w	#57344,-(sp)
	move.w	#16,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
L52:
	jsr	_wait_sync
	addq.w	#1,-6(a6)
	jsr	_read_joypad1
	move.w	d0,-(sp)
	jsr	_read_joypad2
	or.w	(sp)+,d0
	move.w	d0,-8(a6)
	bra	L49
L51:
	move.w	#49152,-(sp)
	move.w	d4,d0
	add.w	d7,d0
	move.w	d0,-(sp)
	move.w	8(a6),-(sp)
	move.w	#57344,-(sp)
	move.w	#32,-(sp)
	jsr	_put_tile
	lea	10(sp),sp
	bra	L52
L50:
	move.w	-8(a6),d0
	and.w	#1,d0
	beq	L53
	tst.w	d7
	beq	L53
	subq.w	#1,d7
L53:
	move.w	-8(a6),d0
	and.w	#2,d0
	beq	L44
	move.w	24(a6),d0
	subq.w	#1,d0
	move.w	d7,d1
	cmp.w	d0,d1
	beq	L44
	addq.w	#1,d7
	bra	L44
L45:
	move.w	#115,-(sp)
	jsr	_wait_btn_release
	addq.w	#2,sp
	move.w	d7,d0
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
