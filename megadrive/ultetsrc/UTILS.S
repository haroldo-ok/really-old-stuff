	.bss
	.globl	_randomnum
	.comm	_randomnum,4
	.text
	.globl	_nextlongrand
_nextlongrand:
	link	a6,#-8
	movem.l	d3/d4,-(sp)
	addq.l	#1,_randomnum
	move.l	#16807,-(sp)
	move.l	_randomnum,d0
	and.l	#-1,d0
	move.l	d0,-(sp)
	jsr	lmul
	addq.w	#8,sp
	move.l	d0,d3
	move.l	#2147483647,-(sp)
	move.l	_randomnum,d0
	moveq.l	#16,d1
	lsr.l	d1,d0
	move.l	d0,-(sp)
	jsr	lmul
	addq.w	#8,sp
	move.l	d0,d4
	and.l	#32767,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	add.l	d0,d3
	cmp.l	#2147483647,d3
	bls	L3
	and.l	#2147483647,d3
	addq.l	#1,d3
L3:
	move.l	d4,d0
	moveq.l	#15,d1
	lsr.l	d1,d0
	add.l	d0,d3
	cmp.l	#2147483647,d3
	bls	L4
	and.l	#2147483647,d3
	addq.l	#1,d3
L4:
	move.l	d3,d0
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_random
_random:
	link	a6,#0
	jsr	_nextlongrand
	move.l	d0,_randomnum
	moveq.l	#0,d0
	move.w	_randomnum+2,d0
	divu	8(a6),d0
	swap	d0
	unlk	a6
	rts
	.text
	.globl	_put_tile
_put_tile:
	link	a6,#0
	movem.l	d3/a3-a4,-(sp)
	move.w	14(a6),d0
	mulu	_extWIDTH,d0
	add.w	12(a6),d0
	lsl.w	#1,d0
	add.w	16(a6),d0
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
	move.w	8(a6),d0
	or.w	10(a6),d0
	move.w	d0,(a4)
	movem.l	(sp)+,d3/a3-a4
	unlk	a6
	rts
	.text
	.globl	_char2hex
_char2hex:
	link	a6,#0
	cmp.b	#57,9(a6)
	bgt	L14
	move.b	9(a6),d0
	ext.w	d0
	sub.w	#48,d0
L13:
	unlk	a6
	rts
L14:
	move.b	9(a6),d0
	ext.w	d0
	sub.w	#65,d0
	add.w	#10,d0
	bra	L13
	.text
	.globl	_get_str_char
_get_str_char:
	link	a6,#0
	movem.l	d3/d4,-(sp)
	move.l	8(a6),d4
	move.l	d4,a0
	move.l	(a0),a0
	move.b	(a0),d0
	ext.w	d0
	cmp.w	#126,d0
	beq	L21
	move.l	d4,a0
	move.l	(a0),a0
	move.b	(a0),d3
	ext.w	d3
	move.l	d4,a0
	addq.l	#1,(a0)
L19:
	move.w	d3,d0
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
L21:
	move.l	d4,a0
	addq.l	#1,(a0)
	move.l	d4,a0
	move.l	(a0),a0
	tst.b	(a0)
	beq	L22
	move.l	d4,a0
	move.l	(a0),a0
	move.b	(a0),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_char2hex
	addq.w	#2,sp
	ext.w	d0
	move.w	d0,d3
	move.l	d4,a0
	addq.l	#1,(a0)
	move.l	d4,a0
	move.l	(a0),a0
	tst.b	(a0)
	beq	L19
	move.l	d4,a0
	move.l	(a0),a0
	move.b	(a0),d0
	ext.w	d0
	move.w	d0,-(sp)
	jsr	_char2hex
	addq.w	#2,sp
	ext.w	d0
	move.w	d3,d1
	lsl.w	#4,d1
	or.w	d0,d1
	move.w	d1,d3
	move.l	d4,a0
	addq.l	#1,(a0)
	bra	L19
L22:
	moveq.l	#126,d3
	bra	L19
	.text
	.globl	_strlen2
_strlen2:
	link	a6,#0
	move.l	d3,-(sp)
	moveq.l	#0,d3
L29:
	pea	8(a6)
	jsr	_get_str_char
	addq.w	#4,sp
	tst.w	d0
	beq	L30
	addq.w	#1,d3
	bra	L29
L30:
	move.w	d3,d0
	move.l	(sp)+,d3
	unlk	a6
	rts
	.text
	.globl	_out_text
_out_text:
	link	a6,#0
	movem.l	d3-d5/a3-a4,-(sp)
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
L34:
	move.l	16(a6),a0
	tst.b	(a0)
	beq	L33
	pea	16(a6)
	jsr	_get_str_char
	addq.w	#4,sp
	move.w	d0,d5
	cmp.w	#9,d5
	bne	L36
	move.w	d4,(a4)
	move.w	d4,(a4)
	move.w	d4,(a4)
	move.w	d4,(a4)
	bra	L34
L36:
	move.w	d5,d0
	or.w	d4,d0
	move.w	d0,(a4)
	bra	L34
L33:
	movem.l	(sp)+,d3-d5/a3-a4
	unlk	a6
	rts
	.text
	.globl	_out_uint
_out_uint:
	link	a6,#-6
	movem.l	d3/d4/d5/a3,-(sp)
	move.w	18(a6),d5
	move.w	16(a6),d4
	cmp.w	#5,d4
	bls	L41
	moveq.l	#5,d4
L41:
	moveq.l	#0,d3
L42:
	cmp.w	#6,d3
	beq	L44
	moveq.l	#0,d0
	move.w	d3,d0
	move.b	#32,-6(a6,d0.l)
	addq.w	#1,d3
	bra	L42
L44:
	move.b	#0,-1(a6)
	move.b	#48,-2(a6)
	lea	-1(a6),a3
L45:
	subq.l	#1,a3
	moveq.l	#0,d0
	move.w	d5,d0
	divu	#10,d0
	swap	d0
	add.w	#48,d0
	move.b	d0,(a3)
	tst.w	d4
	beq	L48
	subq.w	#1,d4
L48:
	moveq.l	#0,d0
	move.w	d5,d0
	divu	#10,d0
	move.w	d0,d5
	bne	L45
L49:
	tst.w	d4
	beq	L50
	subq.l	#1,a3
	subq.w	#1,d4
	bra	L49
L50:
	move.l	a3,-(sp)
	move.w	14(a6),-(sp)
	move.w	12(a6),-(sp)
	move.w	10(a6),-(sp)
	move.w	8(a6),-(sp)
	jsr	_out_text
	lea	12(sp),sp
	movem.l	(sp)+,d3/d4/d5/a3
	unlk	a6
	rts
	.text
	.globl	_out_ulong
_out_ulong:
	link	a6,#-10
	movem.l	d3/d4/d5/a3,-(sp)
	move.l	18(a6),d5
	move.w	16(a6),d4
	cmp.w	#9,d4
	bls	L54
	moveq.l	#9,d4
L54:
	moveq.l	#0,d3
L55:
	cmp.w	#10,d3
	beq	L57
	moveq.l	#0,d0
	move.w	d3,d0
	move.b	#32,-10(a6,d0.l)
	addq.w	#1,d3
	bra	L55
L57:
	move.b	#0,-1(a6)
	move.b	#48,-2(a6)
	lea	-1(a6),a3
L58:
	subq.l	#1,a3
	move.l	#10,-(sp)
	move.l	d5,-(sp)
	jsr	lremu
	addq.w	#8,sp
	add.l	#48,d0
	move.b	d0,(a3)
	tst.w	d4
	beq	L61
	subq.w	#1,d4
L61:
	move.l	#10,-(sp)
	move.l	d5,-(sp)
	jsr	ldivu
	addq.w	#8,sp
	move.l	d0,d5
	bne	L58
L62:
	tst.w	d4
	beq	L63
	subq.l	#1,a3
	subq.w	#1,d4
	bra	L62
L63:
	move.l	a3,-(sp)
	move.w	14(a6),-(sp)
	move.w	12(a6),-(sp)
	move.w	10(a6),-(sp)
	move.w	8(a6),-(sp)
	jsr	_out_text
	lea	12(sp),sp
	movem.l	(sp)+,d3/d4/d5/a3
	unlk	a6
	rts
	.text
	.globl	_set_bkg_data
_set_bkg_data:
	link	a6,#0
	movem.l	d3/d4/d5,-(sp)
	move.l	12(a6),d5
	move.w	10(a6),d4
	move.w	8(a6),d0
	lsl.w	#5,d0
	move.w	d0,d3
L67:
	tst.w	d4
	beq	L66
	cmp.w	#32,d4
	bls	L70
	move.w	#1024,-(sp)
	move.w	d3,-(sp)
	move.l	d5,-(sp)
	jsr	_dma_vram_copy
	addq.w	#8,sp
	sub.w	#32,d4
L71:
	add.l	#1024,d5
	add.w	#1024,d3
	bra	L67
L70:
	move.w	d4,d0
	lsl.w	#5,d0
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	move.l	d5,-(sp)
	jsr	_dma_vram_copy
	addq.w	#8,sp
	moveq.l	#0,d4
	bra	L71
L66:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_set_bkg_tiles
_set_bkg_tiles:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7/a3/a4,-(sp)
	move.l	16(a6),d7
	move.w	10(a6),d6
	moveq.l	#0,d4
L75:
	cmp.w	14(a6),d4
	beq	L74
	move.w	d6,d0
	mulu	_extWIDTH,d0
	add.w	8(a6),d0
	lsl.w	#1,d0
	add.w	20(a6),d0
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
	moveq.l	#0,d5
L78:
	cmp.w	12(a6),d5
	beq	L80
	move.l	d7,a0
	move.w	(a0),d0
	add.w	22(a6),d0
	move.w	d0,(a4)
	addq.l	#2,d7
	addq.w	#1,d5
	bra	L78
L80:
	addq.w	#1,d6
	addq.w	#1,d4
	bra	L75
L74:
	movem.l	(sp)+,d3/d4/d5/d6/d7/a3/a4
	unlk	a6
	rts
	.text
	.globl	_fill_bkg_rect
_fill_bkg_rect:
	link	a6,#0
	movem.l	d3/d4/d5/d6/a3/a4,-(sp)
	move.w	10(a6),d6
	moveq.l	#0,d4
L84:
	cmp.w	14(a6),d4
	beq	L83
	move.w	d6,d0
	mulu	_extWIDTH,d0
	add.w	8(a6),d0
	lsl.w	#1,d0
	add.w	16(a6),d0
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
	moveq.l	#0,d5
L87:
	cmp.w	12(a6),d5
	beq	L89
	move.w	18(a6),(a4)
	addq.w	#1,d5
	bra	L87
L89:
	addq.w	#1,d6
	addq.w	#1,d4
	bra	L84
L83:
	movem.l	(sp)+,d3/d4/d5/d6/a3/a4
	unlk	a6
	rts
	.data
	.text
	.globl	_fade_from_to
_fade_from_to:
	link	a6,#-32
	movem.l	d3-d6/a3-a5,-(sp)
	move.w	16(a6),d0
	lsl.w	#5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d6
	moveq.l	#0,d3
L93:
	cmp.w	#16,d3
	bcc	L95
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	8(a6),d1
	move.l	d1,a0
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	(a0),-32(a6,d1.l)
	addq.w	#1,d3
	bra	L93
L95:
	moveq.l	#0,d3
L96:
	cmp.w	#16,d3
	bcc	L92
	move.l	12(a6),a5
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
L99:
	cmp.w	#16,d4
	bcc	L101
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
	bcc	L102
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	add.w	#256,(a0)
L103:
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
	bcc	L105
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	add.w	#16,(a0)
L106:
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),d0
	and.w	#15,d0
	move.w	d0,d5
	move.w	(a5),d0
	and.w	#15,d0
	cmp.w	d0,d5
	bcc	L108
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	addq.w	#1,(a0)
L109:
	addq.l	#2,a5
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.w	-32(a6,d1.l),(a4)
	addq.w	#1,d4
	bra	L99
L108:
	move.w	(a5),d0
	and.w	#15,d0
	cmp.w	d0,d5
	bls	L109
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	subq.w	#1,(a0)
	bra	L109
L105:
	move.w	(a5),d0
	and.w	#240,d0
	cmp.w	d0,d5
	bls	L106
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	sub.w	#16,(a0)
	bra	L106
L102:
	move.w	(a5),d0
	and.w	#3840,d0
	cmp.w	d0,d5
	bls	L103
	move.w	d4,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	lea	-32(a6,d1.l),a0
	sub.w	#256,(a0)
	bra	L103
L101:
	moveq.l	#0,d4
L111:
	cmp.w	#4,d4
	bcc	L97
	jsr	_wait_sync
	addq.w	#1,d4
	bra	L111
L97:
	addq.w	#1,d3
	bra	L96
L92:
	movem.l	(sp)+,d3-d6/a3-a5
	unlk	a6
	rts
