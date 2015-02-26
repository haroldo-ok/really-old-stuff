	.bss
	.globl	_huge_buffer
	.comm	_huge_buffer,35840
	.globl	_tileset_base_tile
	.comm	_tileset_base_tile,2
	.globl	_tileset_field_addr
	.comm	_tileset_field_addr,2
	.text
	.globl	_tileset_load_RDC
_tileset_load_RDC:
	link	a6,#-8
	move.l	8(a6),-(sp)
	pea	-8(a6)
	pea	-4(a6)
	jsr	_get_GFS_file
	lea	12(sp),sp
	move.l	#_huge_buffer,-(sp)
	move.l	-4(a6),-(sp)
	jsr	_RDC_Decompress
	addq.w	#8,sp
	move.l	#_huge_buffer,-(sp)
	move.w	14(a6),-(sp)
	move.w	12(a6),-(sp)
	jsr	_set_bkg_data
	unlk	a6
	rts
	.data
	.text
	.globl	_put_2x2_block
_put_2x2_block:
	link	a6,#0
	movem.l	d3-d4/a3-a4,-(sp)
	move.w	12(a6),d3
	move.w	d3,d0
	lsl.w	#2,d0
	add.w	_tileset_base_tile,d0
	move.w	d0,d3
	move.w	8(a6),d0
	lsl.w	#1,d0
	move.w	10(a6),d1
	lsl.w	#1,d1
	lsl.w	#6,d1
	add.w	d1,d0
	lsl.w	#1,d0
	add.w	_tileset_field_addr,d0
	moveq.l	#0,d1
	move.w	d0,d1
	move.l	d1,d4
	move.l	#12582916,a3
	move.l	d4,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d4,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	move.l	#12582912,a4
	move.w	d3,(a4)
	addq.w	#2,d3
	move.w	d3,(a4)
	move.w	_extWIDTH,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,d4
	move.l	d4,d0
	and.l	#16383,d0
	add.l	#16384,d0
	moveq.l	#16,d1
	lsl.l	d1,d0
	move.l	d4,d1
	moveq.l	#14,d2
	lsr.l	d2,d1
	add.l	d1,d0
	move.l	d0,(a3)
	subq.w	#1,d3
	move.w	d3,(a4)
	addq.w	#2,d3
	move.w	d3,(a4)
	movem.l	(sp)+,d3-d4/a3-a4
	unlk	a6
	rts
