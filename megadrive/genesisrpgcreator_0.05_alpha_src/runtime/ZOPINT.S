	.bss
	.globl	_zop_instr_per_frame
	.comm	_zop_instr_per_frame,2
	.globl	_zop_flags
	.comm	_zop_flags,256
	.globl	_zop_text_buf
	.comm	_zop_text_buf,1024
	.globl	_zop_text_ptr
	.comm	_zop_text_ptr,4
	.globl	_zop_menu_text_buf
	.comm	_zop_menu_text_buf,512
	.globl	_zop_menu_text_ptr
	.comm	_zop_menu_text_ptr,4
	.globl	_zop_menu_ptrs
	.comm	_zop_menu_ptrs,64
	.globl	_zop_menu_dests
	.comm	_zop_menu_dests,32
	.globl	_zop_menu_cnt
	.comm	_zop_menu_cnt,2
	.globl	_zop_debug_mode
	.comm	_zop_debug_mode,2
	.text
	.globl	_zop_vm_init
_zop_vm_init:
	link	a6,#0
	move.w	#50,_zop_instr_per_frame
	move.b	#0,_zop_text_buf
	move.l	#_zop_text_buf,_zop_text_ptr
	move.w	#0,_zop_menu_cnt
	jsr	_zop_clear_flags
	move.w	#0,_zop_debug_mode
	unlk	a6
	rts
	.text
	.globl	_zop_load_prog
_zop_load_prog:
	link	a6,#-12
	movem.l	d3/d4,-(sp)
	move.l	8(a6),d3
	move.l	12(a6),-(sp)
	pea	-8(a6)
	pea	-4(a6)
	jsr	_get_GFS_file
	lea	12(sp),sp
	move.l	-4(a6),d4
	addq.l	#4,d4
	move.l	d4,a0
	move.b	(a0),d0
	ext.w	d0
	move.l	d3,a0
	move.w	d0,(a0)
	addq.l	#1,d4
	move.l	d3,a0
	move.w	(a0),d0
	lsl.w	#8,d0
	move.l	d4,a0
	move.b	(a0),d1
	ext.w	d1
	or.w	d1,d0
	move.l	d3,a0
	move.w	d0,(a0)
	addq.l	#1,d4
	move.l	d3,a0
	move.l	d4,2(a0)
	move.l	d3,a0
	move.w	(a0),d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,d4
	move.l	d3,a0
	move.l	#0,6(a0)
	move.l	d3,a0
	move.l	d4,10(a0)
	move.l	d3,a0
	move.l	d3,a1
	move.l	10(a0),14(a1)
	move.l	d3,a0
	move.w	16(a6),18(a0)
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
	.text
	.globl	_zop_exec_instruction
_zop_exec_instruction:
	link	a6,#-2
	movem.l	d3-d6/a3,-(sp)
	move.l	8(a6),a3
	move.l	14(a3),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,d4
	and.w	#252,d0
	move.w	d0,d3
	and.w	#3,d4
	addq.l	#1,14(a3)
	move.w	d3,d0
	cmp.w	#126,d0
	bge	L66
	cmp.w	#56,d0
	bge	L67
	tst.w	d0
	beq	L11
	cmp.w	#32,d0
	beq	L16
	cmp.w	#36,d0
	beq	L16
L65:
	move.l	#0,14(a3)
	moveq.l	#1,d0
L8:
	movem.l	(sp)+,d3-d6/a3
	unlk	a6
	rts
L16:
	move.w	d4,d0
	beq	L19
	cmp.w	#1,d0
	beq	L20
	cmp.w	#2,d0
	beq	L21
	cmp.w	#3,d0
	beq	L22
L17:
	cmp.w	#36,d3
	beq	L24
	move.w	d5,-(sp)
	move.w	18(a3),-(sp)
	jsr	_actor_walk
	addq.w	#4,sp
	tst.b	d0
	bne	L26
	subq.l	#1,14(a3)
L26:
	moveq.l	#1,d0
	bra	L8
L24:
	move.w	d5,-(sp)
	move.w	18(a3),-(sp)
	jsr	_actor_walk
	addq.w	#4,sp
	bra	L26
L22:
	moveq.l	#2,d5
	bra	L17
L21:
	moveq.l	#3,d5
	bra	L17
L20:
	moveq.l	#1,d5
	bra	L17
L19:
	moveq.l	#0,d5
	bra	L17
L11:
	move.w	d4,d0
	cmp.w	#1,d0
	beq	L14
L9:
	clr.w	d0
	bra	L8
L14:
	moveq.l	#1,d0
	bra	L8
L67:
	cmp.w	#64,d0
	beq	L27
	cmp.w	#68,d0
	beq	L36
	cmp.w	#96,d0
	beq	L47
	cmp.w	#100,d0
	beq	L47
	cmp.w	#104,d0
	beq	L47
	cmp.w	#108,d0
	beq	L47
	cmp.w	#112,d0
	bne	L65
L47:
	move.l	14(a3),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d4,d1
	lsl.w	#8,d1
	or.w	d0,d1
	move.w	d1,d5
	addq.l	#1,14(a3)
	move.w	d3,d0
	cmp.w	#96,d0
	beq	L50
	cmp.w	#100,d0
	beq	L51
	cmp.w	#104,d0
	beq	L52
	cmp.w	#108,d0
	beq	L53
	cmp.w	#112,d0
	bne	L9
	jsr	_zop_get_flag0
	clr.w	d1
	move.b	d0,d1
	tst.w	d1
	seq	d1
	and.w	#1,d1
	move.w	d1,-(sp)
	jsr	_zop_set_flag0
	addq.w	#2,sp
	bra	L9
L53:
	jsr	_zop_get_flag0
	clr.w	d1
	move.b	d0,d1
	move.w	d1,-(sp)
	move.w	d5,-(sp)
	jsr	_zop_set_flag
	addq.w	#4,sp
	bra	L9
L52:
	move.w	d5,-(sp)
	jsr	_zop_get_flag
	clr.w	d1
	move.b	d0,d1
	move.w	d1,(sp)
	jsr	_zop_set_flag0
	addq.w	#2,sp
	bra	L9
L51:
	move.w	#2,-(sp)
	move.w	d5,-(sp)
	jsr	_zop_set_flag
	addq.w	#4,sp
	bra	L9
L50:
	move.w	#1,-(sp)
	move.w	d5,-(sp)
	jsr	_zop_set_flag
	addq.w	#4,sp
	bra	L9
L36:
	move.w	d4,d0
	beq	L39
	cmp.w	#1,d0
	beq	L40
	cmp.w	#2,d0
	beq	L44
	cmp.w	#3,d0
	bne	L9
	move.w	#1,-(sp)
	move.l	a3,-(sp)
	jsr	_zop_display_menu
	addq.w	#6,sp
	bra	L9
L44:
	clr.w	-(sp)
	move.l	a3,-(sp)
	jsr	_zop_display_menu
	addq.w	#6,sp
	bra	L9
L40:
	move.l	14(a3),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,d5
	addq.l	#1,14(a3)
	move.l	14(a3),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d5,d1
	lsl.w	#8,d1
	add.w	d0,d1
	move.w	d1,d5
	addq.l	#1,14(a3)
	tst.w	_zop_menu_cnt
	bne	L41
	move.l	#_zop_menu_text_buf,_zop_menu_text_ptr
L41:
	move.w	_zop_menu_cnt,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_zop_menu_ptrs,d1
	move.l	d1,a0
	move.l	_zop_menu_text_ptr,(a0)
	move.w	_zop_menu_cnt,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_zop_menu_dests,d1
	move.l	d1,a0
	move.w	d5,(a0)
L42:
	move.l	14(a3),a0
	tst.b	(a0)
	beq	L43
	move.l	14(a3),a0
	move.l	_zop_menu_text_ptr,a1
	move.b	(a0),(a1)
	addq.l	#1,14(a3)
	addq.l	#1,_zop_menu_text_ptr
	bra	L42
L43:
	move.l	_zop_menu_text_ptr,a0
	move.b	#0,(a0)
	addq.l	#1,_zop_menu_text_ptr
	addq.l	#1,14(a3)
	addq.w	#1,_zop_menu_cnt
	bra	L9
L39:
	move.w	#0,_zop_menu_cnt
	bra	L9
L27:
	move.w	d4,d0
	beq	L30
	cmp.w	#1,d0
	beq	L31
	cmp.w	#2,d0
	beq	L33
	cmp.w	#3,d0
	bne	L9
	move.w	#1,-(sp)
	jsr	_zop_display_text
	addq.w	#2,sp
	bra	L9
L33:
	clr.w	-(sp)
	jsr	_zop_display_text
	addq.w	#2,sp
	bra	L9
L31:
	pea	14(a3)
	jsr	_zop_add_text_inc
	move.l	#L32,(sp)
	jsr	_zop_add_text
	addq.w	#4,sp
	addq.l	#1,14(a3)
	bra	L9
L30:
	move.b	#0,_zop_text_buf
	move.l	#_zop_text_buf,_zop_text_ptr
	bra	L9
L66:
	cmp.w	#128,d0
	beq	L56
	cmp.w	#252,d0
	beq	L9
	bra	L65
L56:
	move.l	14(a3),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,d5
	addq.l	#1,14(a3)
	move.l	14(a3),a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d5,d1
	lsl.w	#8,d1
	add.w	d0,d1
	move.w	d1,d5
	addq.l	#1,14(a3)
	move.w	d4,d0
	beq	L59
	cmp.w	#1,d0
	beq	L60
	cmp.w	#2,d0
	beq	L61
L57:
	tst.w	d6
	beq	L9
	moveq.l	#0,d0
	move.w	d5,d0
	add.l	10(a3),d0
	move.l	d0,14(a3)
	bra	L9
L61:
	jsr	_zop_get_flag0
	tst.b	d0
	seq	d0
	and.w	#1,d0
	move.w	d0,d6
	bra	L57
L60:
	jsr	_zop_get_flag0
	clr.w	d1
	move.b	d0,d1
	move.w	d1,d6
	bra	L57
L59:
	moveq.l	#1,d6
	bra	L57
	.text
	.globl	_zop_exec_frame
_zop_exec_frame:
	link	a6,#-2
	movem.l	d3/d4,-(sp)
	move.l	8(a6),d3
	move.w	_zop_instr_per_frame,d4
	move.l	d3,a0
	tst.l	14(a0)
	bne	L71
L70:
	movem.l	(sp)+,d3/d4
	unlk	a6
	rts
L71:
	move.l	d3,a0
	moveq.l	#34,d0
	mulu	18(a0),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a0
	tst.w	12(a0)
	bne	L70
	move.l	d3,a0
	tst.l	6(a0)
	beq	L74
	move.l	d3,a0
	move.l	d3,a1
	move.l	6(a0),14(a1)
	move.l	d3,a0
	move.l	#0,6(a0)
	move.w	#1,_zop_debug_mode
L74:
	tst.w	d4
	beq	L70
	subq.w	#1,d4
	move.l	d3,-(sp)
	jsr	_zop_exec_instruction
	addq.w	#4,sp
	tst.b	d0
	beq	L74
	tst.b	_zop_text_buf
	beq	L77
	move.w	#1,-(sp)
	jsr	_zop_display_text
	move.w	#1,(sp)
	move.l	d3,-(sp)
	jsr	_zop_display_menu
	addq.w	#6,sp
	jsr	_gui_clear
L77:
	moveq.l	#0,d4
	bra	L74
	.text
	.globl	_zop_signal_event
_zop_signal_event:
	link	a6,#0
	movem.l	d3-d4/a3-a4,-(sp)
	move.l	8(a6),a3
	move.w	12(a6),d3
	tst.l	14(a3)
	beq	L80
	tst.l	6(a3)
	beq	L81
L80:
	movem.l	(sp)+,d3-d4/a3-a4
	unlk	a6
	rts
L81:
	move.l	2(a3),a4
	move.w	(a3),d4
L83:
	tst.w	d4
	beq	L85
	move.w	(a4),d0
	cmp.w	d3,d0
	beq	L85
	addq.l	#4,a4
	subq.w	#1,d4
	bra	L83
L85:
	tst.w	d4
	beq	L80
	moveq.l	#0,d0
	move.w	2(a4),d0
	add.l	10(a3),d0
	move.l	d0,6(a3)
	bra	L80
	.text
	.globl	_zop_clear_flags
_zop_clear_flags:
	link	a6,#0
	movem.l	d3/a3,-(sp)
	move.l	#_zop_flags,a3
	moveq.l	#0,d3
L90:
	cmp.w	#256,d3
	beq	L89
	move.b	#0,(a3)
	addq.l	#1,a3
	addq.w	#1,d3
	bra	L90
L89:
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
	.text
	.globl	_zop_set_flag
_zop_set_flag:
	link	a6,#0
	movem.l	d3-d5/a3,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	move.w	d3,d0
	and.w	#7,d0
	moveq.l	#1,d1
	asl.w	d0,d1
	move.w	d1,d5
	move.w	d3,d0
	lsr.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_zop_flags,d1
	move.l	d1,a3
	move.w	#255,d0
	sub.w	d5,d0
	and.b	d0,(a3)
	tst.w	d4
	beq	L95
	or.b	d5,(a3)
L95:
	movem.l	(sp)+,d3-d5/a3
	unlk	a6
	rts
	.text
	.globl	_zop_get_flag
_zop_get_flag:
	link	a6,#0
	movem.l	d3-d4/a3,-(sp)
	move.w	8(a6),d3
	move.w	d3,d0
	and.w	#7,d0
	moveq.l	#1,d1
	asl.w	d0,d1
	move.w	d1,d4
	move.w	d3,d0
	lsr.w	#3,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_zop_flags,d1
	move.l	d1,a3
	clr.w	d0
	move.b	(a3),d0
	and.w	d4,d0
	tst.w	d0
	sne	d1
	and.w	#1,d1
	move.w	d1,d0
	movem.l	(sp)+,d3-d4/a3
	unlk	a6
	rts
	.text
	.globl	_zop_set_flag0
_zop_set_flag0:
	link	a6,#0
	and.b	#254,_zop_flags
	move.b	9(a6),d0
	or.b	d0,_zop_flags
	unlk	a6
	rts
	.text
	.globl	_zop_get_flag0
_zop_get_flag0:
	link	a6,#0
	clr.w	d0
	move.b	_zop_flags,d0
	and.w	#1,d0
	unlk	a6
	rts
	.text
	.globl	_zop_add_text
_zop_add_text:
	link	a6,#0
	move.l	a3,-(sp)
	move.l	8(a6),a3
L109:
	tst.b	(a3)
	beq	L110
	move.l	_zop_text_ptr,a0
	move.b	(a3),(a0)
	addq.l	#1,_zop_text_ptr
	addq.l	#1,a3
	bra	L109
L110:
	move.l	_zop_text_ptr,a0
	move.b	#0,(a0)
	move.l	(sp)+,a3
	unlk	a6
	rts
	.text
	.globl	_zop_add_text_inc
_zop_add_text_inc:
	link	a6,#0
	move.l	a3,-(sp)
	move.l	8(a6),a3
L114:
	move.l	(a3),a0
	tst.b	(a0)
	beq	L115
	move.l	(a3),a0
	move.l	_zop_text_ptr,a1
	move.b	(a0),(a1)
	addq.l	#1,_zop_text_ptr
	addq.l	#1,(a3)
	bra	L114
L115:
	move.l	_zop_text_ptr,a0
	move.b	#0,(a0)
	move.l	(sp)+,a3
	unlk	a6
	rts
	.text
	.globl	_zop_display_text
_zop_display_text:
	link	a6,#0
	move.l	#_zop_text_buf,-(sp)
	move.w	#7,-(sp)
	move.w	#40,-(sp)
	move.w	#21,-(sp)
	clr.w	-(sp)
	jsr	_gui_pager
	tst.w	8(a6)
	beq	L118
	move.b	#0,_zop_text_buf
	move.l	#_zop_text_buf,_zop_text_ptr
L118:
	unlk	a6
	rts
	.data
L32:	.dc.b	$a
	.dc.b	0
	.text
	.globl	_zop_display_menu
_zop_display_menu:
	link	a6,#-2
	tst.w	_zop_menu_cnt
	bne	L123
L122:
	unlk	a6
	rts
L123:
	move.w	#1,-(sp)
	move.w	_zop_menu_cnt,-(sp)
	move.l	#_zop_menu_ptrs,-(sp)
	move.w	#18,-(sp)
	move.w	#3,-(sp)
	move.w	#38,-(sp)
	move.w	#5,-(sp)
	move.w	#19,-(sp)
	clr.w	-(sp)
	jsr	_gui_menu
	move.w	d0,-2(a6)
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_zop_menu_dests,d1
	move.l	d1,a0
	moveq.l	#0,d0
	move.w	(a0),d0
	move.l	8(a6),a0
	add.l	10(a0),d0
	move.l	8(a6),a0
	move.l	d0,14(a0)
	tst.w	12(a6)
	beq	L122
	move.w	#0,_zop_menu_cnt
	bra	L122
