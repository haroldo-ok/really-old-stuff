	.bss
	.globl	_map_ptrs
	.comm	_map_ptrs,512
	.globl	_map_line_ptr
	.comm	_map_line_ptr,4
	.globl	_map_col_ptr
	.comm	_map_col_ptr,4
	.globl	_map_line_num
	.comm	_map_line_num,2
	.globl	_map_col_num
	.comm	_map_col_num,2
	.globl	_map_x
	.comm	_map_x,2
	.globl	_map_y
	.comm	_map_y,2
	.globl	_map_old_x
	.comm	_map_old_x,2
	.globl	_map_old_y
	.comm	_map_old_y,2
	.globl	_map_w
	.comm	_map_w,2
	.globl	_map_h
	.comm	_map_h,2
	.globl	_map_w_mask
	.comm	_map_w_mask,2
	.globl	_map_h_mask
	.comm	_map_h_mask,2
	.globl	_map_coord_x_mask
	.comm	_map_coord_x_mask,2
	.globl	_map_coord_y_mask
	.comm	_map_coord_y_mask,2
	.text
	.globl	_rpg_map_load
_rpg_map_load:
	link	a6,#0
	unlk	a6
	rts
	.text
	.globl	_rpg_map_init_ptrs
_rpg_map_init_ptrs:
	link	a6,#0
	movem.l	d3/d4/d5/d6/a3,-(sp)
	move.w	14(a6),d6
	move.w	12(a6),d5
	move.l	8(a6),d4
	move.l	d4,a3
	moveq.l	#0,d3
L6:
	cmp.w	d6,d3
	beq	L8
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_map_ptrs,d1
	move.l	d1,a0
	move.l	a3,(a0)
	moveq.l	#0,d0
	move.w	d5,d0
	add.l	d0,a3
	addq.w	#1,d3
	bra	L6
L8:
	move.l	d4,_map_line_ptr
	move.l	d4,_map_col_ptr
	move.w	#0,_map_line_num
	move.w	#0,_map_col_num
	move.w	d5,_map_w
	move.w	d6,_map_h
	move.w	d5,d0
	subq.w	#1,d0
	move.w	d0,_map_w_mask
	move.w	d6,d0
	subq.w	#1,d0
	move.w	d0,_map_h_mask
	move.w	_map_w_mask,d0
	lsl.w	#4,d0
	or.w	#15,d0
	move.w	d0,_map_coord_x_mask
	move.w	_map_h_mask,d0
	lsl.w	#4,d0
	or.w	#15,d0
	move.w	d0,_map_coord_y_mask
	movem.l	(sp)+,d3/d4/d5/d6/a3
	unlk	a6
	rts
	.text
	.globl	_rpg_map_select_col
_rpg_map_select_col:
	link	a6,#0
	move.l	d3,-(sp)
	move.w	8(a6),d3
	moveq.l	#0,d0
	move.w	d3,d0
	add.l	_map_line_ptr,d0
	move.l	d0,_map_col_ptr
	move.w	d3,_map_col_num
	move.l	(sp)+,d3
	unlk	a6
	rts
	.text
	.globl	_rpg_map_select_line
_rpg_map_select_line:
	link	a6,#0
	move.l	d3,-(sp)
	move.w	8(a6),d3
	move.w	d3,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_map_ptrs,d1
	move.l	d1,a0
	move.l	(a0),_map_line_ptr
	move.w	d3,_map_line_num
	move.w	_map_col_num,-(sp)
	jsr	_rpg_map_select_col
	addq.w	#2,sp
	move.l	(sp)+,d3
	unlk	a6
	rts
	.text
	.globl	_rpg_map_select_next_col
_rpg_map_select_next_col:
	link	a6,#0
	addq.l	#1,_map_col_ptr
	addq.w	#1,_map_col_num
	unlk	a6
	rts
	.text
	.globl	_rpg_map_draw_rectangle
_rpg_map_draw_rectangle:
	link	a6,#0
	movem.l	d3-d7,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	move.b	17(a6),d5
	cmp.w	12(a6),d3
	bcc	L21
	move.w	12(a6),d0
	sub.w	d3,d0
	addq.w	#1,d0
	move.w	d0,d6
L22:
	move.w	d6,12(a6)
	cmp.w	14(a6),d4
	bcc	L23
	move.w	14(a6),d0
	sub.w	d4,d0
	addq.w	#1,d0
	move.w	d0,d7
L25:
	tst.w	d7
	beq	L20
	move.w	d3,-(sp)
	jsr	_rpg_map_select_col
	move.w	d4,(sp)
	jsr	_rpg_map_select_line
	addq.w	#2,sp
	move.w	12(a6),d6
L28:
	tst.w	d6
	beq	L30
	move.l	_map_col_ptr,a0
	move.b	d5,(a0)
	jsr	_rpg_map_select_next_col
	subq.w	#1,d6
	bra	L28
L30:
	addq.w	#1,d4
	subq.w	#1,d7
	bra	L25
L20:
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts
L23:
	move.w	d4,d0
	sub.w	14(a6),d0
	addq.w	#1,d0
	move.w	d0,d7
	move.w	14(a6),d4
	bra	L25
L21:
	move.w	d3,d0
	sub.w	12(a6),d0
	addq.w	#1,d0
	move.w	d0,d6
	move.w	12(a6),d3
	bra	L22
	.text
	.globl	_rpg_map_get_block
_rpg_map_get_block:
	link	a6,#0
	movem.l	d3-d4,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	move.w	d4,d0
	lsl.w	#2,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_map_ptrs,d1
	move.l	d1,a0
	move.l	(a0),_map_line_ptr
	moveq.l	#0,d0
	move.w	d3,d0
	add.l	d0,_map_line_ptr
	move.l	_map_line_ptr,a0
	clr.w	d0
	move.b	(a0),d0
	movem.l	(sp)+,d3-d4
	unlk	a6
	rts
	.text
	.globl	_rpg_map_set_block
_rpg_map_set_block:
	link	a6,#0
	movem.l	d3-d5,-(sp)
	move.w	8(a6),d3
	move.w	10(a6),d4
	move.b	13(a6),d5
	move.w	d3,-(sp)
	jsr	_rpg_map_select_col
	move.w	d4,(sp)
	jsr	_rpg_map_select_line
	addq.w	#2,sp
	move.l	_map_col_ptr,a0
	move.b	d5,(a0)
	movem.l	(sp)+,d3-d5
	unlk	a6
	rts
	.text
	.globl	_rpg_map_repaint
_rpg_map_repaint:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.w	8(a6),d7
	move.w	d7,d0
	sub.w	#16,d0
	lsr.w	#4,d0
	and.w	_map_w_mask,d0
	move.w	d0,_map_x
	move.w	10(a6),d0
	sub.w	#16,d0
	lsr.w	#4,d0
	and.w	_map_h_mask,d0
	move.w	d0,d6
	move.w	d0,_map_y
	moveq.l	#16,d3
L40:
	tst.w	d3
	beq	L42
	move.w	d6,-(sp)
	jsr	_rpg_map_select_line
	addq.w	#2,sp
	move.w	_map_x,d5
	moveq.l	#22,d4
L43:
	tst.w	d4
	beq	L45
	move.w	d5,-(sp)
	jsr	_rpg_map_select_col
	move.l	_map_col_ptr,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(sp)
	move.w	d6,d0
	and.w	#31,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	and.w	#31,d0
	move.w	d0,-(sp)
	jsr	_put_2x2_block
	addq.w	#6,sp
	addq.w	#1,d5
	and.w	_map_w_mask,d5
	subq.w	#1,d4
	bra	L43
L45:
	addq.w	#1,d6
	and.w	_map_h_mask,d6
	subq.w	#1,d3
	bra	L40
L42:
	move.w	d7,d0
	neg.w	d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	move.w	10(a6),-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	move.w	_map_x,_map_old_x
	move.w	_map_y,_map_old_y
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
	.data
	.text
	.globl	_rpg_map_scroll
_rpg_map_scroll:
	link	a6,#0
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.w	8(a6),d7
	move.w	d7,d0
	sub.w	#16,d0
	lsr.w	#4,d0
	and.w	_map_w_mask,d0
	move.w	d0,_map_x
	move.w	10(a6),d0
	sub.w	#16,d0
	lsr.w	#4,d0
	and.w	_map_h_mask,d0
	move.w	d0,_map_y
	move.w	_map_x,d0
	cmp.w	_map_old_x,d0
	beq	L49
	move.w	_map_y,d6
	move.w	_map_x,d0
	cmp.w	_map_old_x,d0
	bls	L52
	move.w	_map_x,d0
	sub.w	_map_old_x,d0
	cmp.w	#2,d0
	bcs	L51
L52:
	move.w	_map_x,d0
	cmp.w	_map_old_x,d0
	bcc	L50
	move.w	_map_old_x,d0
	sub.w	_map_x,d0
	cmp.w	#1,d0
	bls	L50
L51:
	move.w	_map_x,d0
	add.w	#22,d0
	subq.w	#1,d0
	move.w	d0,d5
L53:
	and.w	_map_w_mask,d5
	and.w	_map_h_mask,d6
	move.w	d5,-(sp)
	jsr	_rpg_map_select_col
	addq.w	#2,sp
	moveq.l	#16,d3
L54:
	tst.w	d3
	beq	L49
	move.w	d6,-(sp)
	jsr	_rpg_map_select_line
	move.l	_map_col_ptr,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(sp)
	move.w	d6,d0
	and.w	#31,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	and.w	#31,d0
	move.w	d0,-(sp)
	jsr	_put_2x2_block
	addq.w	#6,sp
	addq.w	#1,d6
	and.w	_map_h_mask,d6
	subq.w	#1,d3
	bra	L54
L49:
	move.w	_map_y,d0
	cmp.w	_map_old_y,d0
	beq	L57
	move.w	_map_x,d5
	move.w	_map_y,d0
	cmp.w	_map_old_y,d0
	bls	L60
	move.w	_map_y,d0
	sub.w	_map_old_y,d0
	cmp.w	#2,d0
	bcs	L59
L60:
	move.w	_map_y,d0
	cmp.w	_map_old_y,d0
	bcc	L58
	move.w	_map_old_y,d0
	sub.w	_map_y,d0
	cmp.w	#1,d0
	bls	L58
L59:
	move.w	_map_y,d0
	add.w	#16,d0
	subq.w	#1,d0
	move.w	d0,d6
L61:
	and.w	_map_w_mask,d5
	and.w	_map_h_mask,d6
	move.w	d6,-(sp)
	jsr	_rpg_map_select_line
	addq.w	#2,sp
	moveq.l	#22,d3
L62:
	tst.w	d3
	beq	L57
	move.w	d5,-(sp)
	jsr	_rpg_map_select_col
	move.l	_map_col_ptr,a0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(sp)
	move.w	d6,d0
	and.w	#31,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	and.w	#31,d0
	move.w	d0,-(sp)
	jsr	_put_2x2_block
	addq.w	#6,sp
	addq.w	#1,d5
	and.w	_map_w_mask,d5
	subq.w	#1,d3
	bra	L62
L57:
	move.w	d7,d0
	neg.w	d0
	move.w	d0,-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	move.w	10(a6),-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	move.w	_map_x,_map_old_x
	move.w	_map_y,_map_old_y
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
L58:
	move.w	_map_y,d6
	bra	L61
L50:
	move.w	_map_x,d5
	bra	L53
