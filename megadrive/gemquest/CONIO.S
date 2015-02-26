	.bss
	.globl	_text_info
	.comm	_text_info,12
	.text
	.globl	_gotoxy
_gotoxy:
	link	a6,#0
	cmp.w	#1,8(a6)
	bcs	L2
	clr.w	d0
	move.b	_text_info+2,d0
	clr.w	d1
	move.b	_text_info,d1
	sub.w	d1,d0
	addq.w	#1,d0
	move.w	8(a6),d1
	cmp.w	d0,d1
	bhi	L2
	cmp.w	#1,10(a6)
	bcs	L2
	clr.w	d0
	move.b	_text_info+1,d0
	clr.w	d1
	move.b	_text_info+3,d1
	sub.w	d1,d0
	addq.w	#1,d0
	move.w	10(a6),d1
	cmp.w	d0,d1
	bls	L3
L2:
	unlk	a6
	rts
L3:
	move.b	9(a6),_text_info+9
	move.b	11(a6),_text_info+10
	bra	L2
	.text
	.globl	_wherex
_wherex:
	link	a6,#0
	clr.w	d0
	move.b	_text_info+9,d0
	unlk	a6
	rts
	.text
	.globl	_wherey
_wherey:
	link	a6,#0
	clr.w	d0
	move.b	_text_info+10,d0
	unlk	a6
	rts
	.text
	.globl	_clrscr
_clrscr:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.l	#12582916,a3
	move.l	#1073741827,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d3
L14:
	move.w	_extWIDTH,d0
	lsl.w	#6,d0
	cmp.w	d0,d3
	bcc	L16
	move.w	#0,(a4)
	addq.w	#1,d3
	bra	L14
L16:
	move.l	#12582916,a3
	move.l	#1610612739,(a3)
	move.l	#12582912,a4
	moveq.l	#0,d3
L17:
	move.w	_extWIDTH,d0
	lsl.w	#6,d0
	cmp.w	d0,d3
	bcc	L19
	move.w	#0,(a4)
	addq.w	#1,d3
	bra	L17
L19:
	move.w	#1,-(sp)
	move.w	#1,-(sp)
	jsr	_gotoxy
	addq.w	#4,sp
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_putch
_putch:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7/a3/a4,-(sp)
	move.w	8(a6),d7
	clr.w	d0
	move.b	_text_info+9,d0
	clr.w	d1
	move.b	_text_info,d1
	add.w	d1,d0
	subq.w	#1,d0
	move.w	d0,d5
	clr.w	d0
	move.b	_text_info+10,d0
	clr.w	d1
	move.b	_text_info+1,d1
	add.w	d1,d0
	subq.w	#1,d0
	move.w	d0,d6
	mulu	_extWIDTH,d0
	add.w	d5,d0
	lsl.w	#1,d0
	add.w	#49152,d0
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
	clr.w	d0
	move.b	_text_info+4,d0
	asl.w	#8,d0
	ext.l	d0
	move.l	d0,d4
	move.w	d7,d0
	cmp.w	#8,d0
	beq	L26
	cmp.w	#9,d0
	beq	L28
	cmp.w	#10,d0
	beq	L25
	moveq.l	#0,d0
	move.w	d7,d0
	add.l	d4,d0
	move.w	d0,(a4)
	clr.w	d0
	move.b	_text_info+2,d0
	clr.w	d1
	move.b	_text_info,d1
	sub.w	d1,d0
	addq.w	#1,d0
	move.b	_text_info+9,d1
	addq.b	#1,_text_info+9
	clr.w	d2
	move.b	d1,d2
	cmp.w	d0,d2
	ble	L23
	move.b	#1,_text_info+9
	addq.b	#1,_text_info+10
L23:
	move.w	d7,d0
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3/a4
	unlk	a6
	rts
L25:
	move.b	#1,_text_info+9
	addq.b	#1,_text_info+10
	bra	L23
L28:
	addq.b	#8,_text_info+9
	clr.w	d0
	move.b	_text_info+2,d0
	clr.w	d1
	move.b	_text_info,d1
	sub.w	d1,d0
	addq.w	#1,d0
	clr.w	d1
	move.b	_text_info+9,d1
	cmp.w	d0,d1
	ble	L23
	clr.w	d0
	move.b	_text_info+2,d0
	clr.w	d1
	move.b	_text_info,d1
	sub.w	d1,d0
	addq.w	#1,d0
	sub.b	d0,_text_info+9
	bra	L23
L26:
	cmp.b	#1,_text_info+9
	beq	L23
	subq.b	#1,_text_info+9
	bra	L23
	.text
	.globl	_init_text_mode
_init_text_mode:
	link	a6,#0
	move.b	#0,_text_info
	move.b	#0,_text_info+1
	move.w	_extWIDTH,d0
	subq.w	#1,d0
	move.b	d0,_text_info+2
	move.b	#63,_text_info+3
	move.b	_extWIDTH+1,_text_info+8
	move.b	#64,_text_info+7
	jsr	_clrscr
	unlk	a6
	rts
	.text
	.globl	_cputs
_cputs:
	link	a6,#0
	movem.l	d3/d4,-(sp)
	move.l	8(a6),d4
	moveq.l	#0,d3
L38:
	move.l	d4,a0
	tst.b	(a0)
	beq	L39
	move.l	d4,a0
	move.b	(a0),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_putch
	addq.w	#2,sp
	addq.l	#1,d4
	addq.w	#1,d3
	bra	L38
L39:
	move.w	d3,d0
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_window
_window:
	link	a6,#0
	move.b	9(a6),_text_info
	move.b	11(a6),_text_info+1
	move.b	13(a6),_text_info+2
	move.b	15(a6),_text_info+3
	unlk	a6
	rts
	.text
	.globl	_out_text_XY
_out_text_XY:
	link	a6,#0
	movem.l	d3/d4/d5/d6/a3/a4,-(sp)
	move.l	16(a6),d6
	move.w	12(a6),d0
	moveq.l	#13,d1
	lsl.w	d1,d0
	move.w	d0,d4
	move.w	10(a6),d0
	mulu	_extWIDTH,d0
	add.w	8(a6),d0
	lsl.w	#1,d0
	add.w	14(a6),d0
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
L46:
	move.l	d6,a0
	tst.b	(a0)
	beq	L45
	move.l	d6,a0
	move.b	(a0),d0
	ext.w	d0
	or.w	d4,d0
	move.w	d0,(a4)
	addq.l	#1,d6
	bra	L46
L45:
	movem.l	(sp)+,d3/d4/d5/d6/a3/a4
	unlk	a6
	rts
	.text
	.globl	_write_uint
_write_uint:
	link	a6,#-6
	movem.l	d3/d4/a3,-(sp)
	move.w	8(a6),d4
	move.w	10(a6),d3
	cmp.w	#5,d3
	ble	L51
	moveq.l	#5,d3
L51:
	tst.w	d4
	beq	L52
	move.b	#0,-1(a6)
	lea	-1(a6),a3
L53:
	tst.w	d4
	beq	L55
	subq.l	#1,a3
	subq.w	#1,d3
	moveq.l	#0,d0
	move.w	d4,d0
	divu	#10,d0
	swap	d0
	add.w	#48,d0
	move.b	d0,(a3)
	moveq.l	#0,d0
	move.w	d4,d0
	divu	#10,d0
	move.w	d0,d4
	bra	L53
L55:
	tst.w	d3
	ble	L56
L57:
	tst.w	d3
	beq	L56
	subq.l	#1,a3
	subq.w	#1,d3
	move.b	#32,(a3)
	bra	L57
L56:
	move.l	a3,-(sp)
	jsr	_cputs
	addq.w	#4,sp
	movem.l	(sp)+,d3/d4/a3
	unlk	a6
	rts
L52:
	subq.l	#1,a3
	subq.w	#1,d3
	move.b	#48,(a3)
	bra	L55
	.data
	.text
	.globl	_write_ulong
_write_ulong:
	link	a6,#-12
	movem.l	d3/d4/a3,-(sp)
	move.l	8(a6),d4
	move.w	12(a6),d3
	cmp.w	#10,d3
	ble	L62
	moveq.l	#10,d3
L62:
	tst.l	d4
	beq	L63
	move.b	#0,-1(a6)
	lea	-1(a6),a3
L64:
	tst.l	d4
	beq	L66
	subq.l	#1,a3
	subq.w	#1,d3
	move.l	#10,-(sp)
	move.l	d4,-(sp)
	jsr	lremu
	addq.w	#8,sp
	add.l	#48,d0
	move.b	d0,(a3)
	move.l	#10,-(sp)
	move.l	d4,-(sp)
	jsr	ldivu
	addq.w	#8,sp
	move.l	d0,d4
	bra	L64
L66:
	tst.w	d3
	ble	L67
L68:
	tst.w	d3
	beq	L67
	subq.l	#1,a3
	subq.w	#1,d3
	move.b	#32,(a3)
	bra	L68
L67:
	move.l	a3,-(sp)
	jsr	_cputs
	addq.w	#4,sp
	movem.l	(sp)+,d3/d4/a3
	unlk	a6
	rts
L63:
	subq.l	#1,a3
	subq.w	#1,d3
	move.b	#48,(a3)
	bra	L66
