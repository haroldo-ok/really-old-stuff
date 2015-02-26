	.bss
	.globl	_randomnum
	.comm	_randomnum,4
	.text
	.globl	_nextlongrand
_nextlongrand:
	link	a6,#-8
	movem.l	d3/d4,-(sp)
	add.l	#17,_randomnum
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
	.globl	_char2hex
_char2hex:
	link	a6,#0
	cmp.b	#57,9(a6)
	bgt	L11
	move.b	9(a6),d0
	ext.w	d0
	sub.w	#48,d0
L10:
	unlk	a6
	rts
L11:
	move.b	9(a6),d0
	ext.w	d0
	sub.w	#65,d0
	add.w	#10,d0
	bra	L10
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
	beq	L18
	move.l	d4,a0
	move.l	(a0),a0
	move.b	(a0),d3
	ext.w	d3
	move.l	d4,a0
	addq.l	#1,(a0)
L16:
	move.w	d3,d0
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
L18:
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
	move.w	d0,d3
	move.l	d4,a0
	addq.l	#1,(a0)
	move.l	d4,a0
	move.l	(a0),a0
	tst.b	(a0)
	beq	L16
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
	bra	L16
L19:
	moveq.l	#126,d3
	bra	L16
	.text
	.globl	_strlen2
_strlen2:
	link	a6,#0
	move.l	d3,-(sp)
	moveq.l	#0,d3
L26:
	pea	8(a6)
	jsr	_get_str_char
	addq.w	#4,sp
	tst.w	d0
	beq	L27
	addq.w	#1,d3
	bra	L26
L27:
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
L31:
	move.l	16(a6),a0
	tst.b	(a0)
	beq	L30
	pea	16(a6)
	jsr	_get_str_char
	addq.w	#4,sp
	move.w	d0,d5
	cmp.w	#9,d5
	bne	L33
	move.w	d4,(a4)
	move.w	d4,(a4)
	move.w	d4,(a4)
	move.w	d4,(a4)
	bra	L31
L33:
	move.w	d5,d0
	or.w	d4,d0
	move.w	d0,(a4)
	bra	L31
L30:
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
	bls	L38
	moveq.l	#5,d4
L38:
	moveq.l	#0,d3
L39:
	cmp.w	#6,d3
	beq	L41
	moveq.l	#0,d0
	move.w	d3,d0
	move.b	#32,-6(a6,d0.l)
	addq.w	#1,d3
	bra	L39
L41:
	move.b	#0,-1(a6)
	move.b	#48,-2(a6)
	lea	-1(a6),a3
L42:
	subq.l	#1,a3
	moveq.l	#0,d0
	move.w	d5,d0
	divu	#10,d0
	swap	d0
	add.w	#48,d0
	move.b	d0,(a3)
	tst.w	d4
	beq	L45
	subq.w	#1,d4
L45:
	moveq.l	#0,d0
	move.w	d5,d0
	divu	#10,d0
	move.w	d0,d5
	bne	L42
L46:
	tst.w	d4
	beq	L47
	subq.l	#1,a3
	subq.w	#1,d4
	bra	L46
L47:
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
	bls	L51
	moveq.l	#9,d4
L51:
	moveq.l	#0,d3
L52:
	cmp.w	#10,d3
	beq	L54
	moveq.l	#0,d0
	move.w	d3,d0
	move.b	#32,-10(a6,d0.l)
	addq.w	#1,d3
	bra	L52
L54:
	move.b	#0,-1(a6)
	move.b	#48,-2(a6)
	lea	-1(a6),a3
L55:
	subq.l	#1,a3
	move.l	#10,-(sp)
	move.l	d5,-(sp)
	jsr	lremu
	addq.w	#8,sp
	add.l	#48,d0
	move.b	d0,(a3)
	tst.w	d4
	beq	L58
	subq.w	#1,d4
L58:
	move.l	#10,-(sp)
	move.l	d5,-(sp)
	jsr	ldivu
	addq.w	#8,sp
	move.l	d0,d5
	bne	L55
L59:
	tst.w	d4
	beq	L60
	subq.l	#1,a3
	subq.w	#1,d4
	bra	L59
L60:
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
	.data
	.text
	.globl	_play_GFS_sound
_play_GFS_sound:
	link	a6,#-8
	move.l	8(a6),-(sp)
	pea	-8(a6)
	pea	-4(a6)
	jsr	_get_GFS_file
	lea	12(sp),sp
	move.l	-8(a6),-(sp)
	move.l	-4(a6),-(sp)
	jsr	_play_sample
	unlk	a6
	rts
