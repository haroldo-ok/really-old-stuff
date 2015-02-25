	.bss
	.globl	_gfs_filecount
	.comm	_gfs_filecount,4
	.globl	_gfs_directory
	.comm	_gfs_directory,4
	.data
	.globl	_flashy_pal
_flashy_pal:
	.dc.w	3822
	.dc.w	1092
	.dc.w	2184
	.dc.w	3822
	.dc.w	4
	.dc.w	8
	.dc.w	14
	.dc.w	64
	.dc.w	128
	.dc.w	224
	.dc.w	1024
	.dc.w	2048
	.dc.w	3584
	.dc.w	68
	.dc.w	136
	.dc.w	238
	.text
	.globl	_str_to_fname
_str_to_fname:
	link	a6,#0
	movem.l	d3/d4/d5,-(sp)
	move.l	12(a6),d5
	move.l	8(a6),d4
	moveq.l	#0,d3
L3:
	cmp.w	#8,d3
	beq	L6
	move.l	d5,a0
	cmp.b	#46,(a0)
	beq	L6
	move.l	d5,a0
	move.l	d4,a1
	move.b	(a0),(a1)
	addq.w	#1,d3
	addq.l	#1,d4
	addq.l	#1,d5
	bra	L3
L6:
	cmp.w	#8,d3
	beq	L9
	move.l	d4,a0
	move.b	#32,(a0)
	addq.w	#1,d3
	addq.l	#1,d4
	bra	L6
L9:
	cmp.w	#12,d3
	beq	L12
	move.l	d5,a0
	move.l	d4,a1
	move.b	(a0),(a1)
	addq.w	#1,d3
	addq.l	#1,d4
	addq.l	#1,d5
	bra	L9
L12:
	cmp.w	#12,d3
	beq	L2
	move.l	d4,a0
	move.b	#32,(a0)
	addq.w	#1,d3
	addq.l	#1,d4
	bra	L12
L2:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_init_GFS
_init_GFS:
	link	a6,#0
	move.l	65536,_gfs_filecount
	move.l	#65540,_gfs_directory
	unlk	a6
	rts
	.text
	.globl	_find_GFS_dir_entry
_find_GFS_dir_entry:
	link	a6,#-14
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	8(a6),-(sp)
	pea	-12(a6)
	jsr	_str_to_fname
	addq.w	#8,sp
	moveq.l	#0,d4
	move.w	_gfs_filecount+2,d3
	moveq.l	#0,d7
L21:
	tst.b	d7
	bne	L22
	move.w	d3,d0
	add.w	d4,d0
	lsr.w	#1,d0
	move.w	d0,d5
	cmp.w	d4,d5
	bne	L23
	moveq.l	#1,d7
L23:
	move.w	#12,-(sp)
	pea	-12(a6)
	moveq.l	#22,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	_gfs_directory,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_strncmp
	lea	10(sp),sp
	move.w	d0,d6
	tst.w	d6
	bge	L24
	move.w	d5,d4
	bra	L21
L24:
	tst.w	d6
	ble	L26
	move.w	d5,d3
	bra	L21
L26:
	moveq.l	#1,d7
	bra	L21
L22:
	tst.w	d6
	bne	L28
	moveq.l	#22,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	_gfs_directory,d1
	move.l	d1,d0
L20:
	movem.l	(sp)+,d3/d4/d5/d6/d7
	unlk	a6
	rts
L28:
	moveq.l	#0,d0
	bra	L20
	.text
	.globl	_get_GFS_fileaddr
_get_GFS_fileaddr:
	link	a6,#0
	move.l	12(a6),-(sp)
	jsr	_find_GFS_dir_entry
	move.l	d0,a0
	move.l	14(a0),d0
	add.l	#65536,d0
	move.l	8(a6),a0
	move.l	d0,(a0)
	unlk	a6
	rts
	.text
	.globl	_get_GFS_filesize
_get_GFS_filesize:
	link	a6,#0
	move.l	12(a6),-(sp)
	jsr	_find_GFS_dir_entry
	move.l	d0,a0
	move.l	8(a6),a1
	move.l	18(a0),(a1)
	unlk	a6
	rts
	.data
	.text
	.globl	_get_GFS_file
_get_GFS_file:
	link	a6,#-4
	move.l	16(a6),-(sp)
	jsr	_find_GFS_dir_entry
	move.l	d0,a0
	move.l	d0,-4(a6)
	move.l	14(a0),d0
	add.l	#65536,d0
	move.l	8(a6),a0
	move.l	d0,(a0)
	move.l	-4(a6),a0
	move.l	12(a6),a1
	move.l	18(a0),(a1)
	unlk	a6
	rts
