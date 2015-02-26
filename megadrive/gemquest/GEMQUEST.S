	.data
	.globl	_bkg_pal
_bkg_pal:
	.dc.w	0
	.dc.w	1024
	.dc.w	2048
	.dc.w	3584
	.dc.w	4
	.dc.w	8
	.dc.w	14
	.dc.w	64
	.dc.w	128
	.dc.w	224
	.dc.w	3720
	.dc.w	3754
	.dc.w	546
	.dc.w	1638
	.dc.w	2730
	.dc.w	3822
	.globl	_alt_pal
_alt_pal:
	.dc.w	0
	.dc.w	68
	.dc.w	136
	.dc.w	238
	.dc.w	1088
	.dc.w	2176
	.dc.w	3808
	.dc.w	1028
	.dc.w	2056
	.dc.w	3598
	.dc.w	2286
	.dc.w	2798
	.dc.w	34
	.dc.w	1126
	.dc.w	2218
	.dc.w	3310
	.globl	_player_pal
_player_pal:
	.dc.w	0
	.dc.w	512
	.dc.w	1024
	.dc.w	1536
	.dc.w	2048
	.dc.w	2560
	.dc.w	3072
	.dc.w	3584
	.dc.w	0
	.dc.w	546
	.dc.w	1092
	.dc.w	1638
	.dc.w	2184
	.dc.w	2730
	.dc.w	3276
	.dc.w	3822
	.globl	_enemy_order
_enemy_order:
	.dc.w	1
	.dc.w	3
	.dc.w	2
	.dc.w	5
	.dc.w	4
	.dc.w	6
	.bss
	.globl	_shot_dly
	.comm	_shot_dly,2
	.globl	_tgt_angle
	.comm	_tgt_angle,2
	.globl	_cur_angle
	.comm	_cur_angle,2
	.globl	_player
	.comm	_player,4
	.globl	_gem_count
	.comm	_gem_count,2
	.globl	_lives
	.comm	_lives,2
	.globl	_level
	.comm	_level,2
	.globl	_player_dead
	.comm	_player_dead,2
	.globl	_chosen_enemies
	.comm	_chosen_enemies,10
	.globl	_score
	.comm	_score,4
	.text
	.globl	_main
_main:
	link	a6,#-10
	movem.l	d3-d5,-(sp)
	jsr	_init_GFX
	jsr	_RAZ
	jsr	_wait_sync
	jsr	_init_GFS
	jsr	_init_joypad
	move.l	#L3,-(sp)
	pea	-8(a6)
	jsr	_get_GFS_fileaddr
	addq.w	#8,sp
	clr.w	-(sp)
	move.w	#15,-(sp)
	move.w	#256,-(sp)
	clr.w	-(sp)
	move.l	-8(a6),-(sp)
	jsr	_loadfont
	lea	12(sp),sp
	jsr	_init_text_mode
	move.l	#_actor_sprites,_player
L4:
	jsr	_clrscr
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	jsr	_sprite_prepare
	move.w	#80,-(sp)
	move.w	#1,-(sp)
	jsr	_show_sprite
	addq.w	#4,sp
	move.w	#140,-(sp)
	clr.w	-(sp)
	jsr	_load_bkgnd_dly
	addq.w	#4,sp
	move.w	#140,-(sp)
	move.w	#1,-(sp)
	jsr	_load_bkgnd_dly
	addq.w	#4,sp
	move.w	#140,-(sp)
	move.w	#2,-(sp)
	jsr	_load_bkgnd_dly
	addq.w	#4,sp
	move.w	#3,_lives
	move.w	#1,_level
	move.l	#0,_score
L6:
	tst.w	_lives
	beq	L7
	jsr	_play_level
	bra	L6
L7:
	tst.w	_lives
	bne	L4
	jsr	_clrscr
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_scrollv
	addq.w	#4,sp
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_scrollh
	addq.w	#4,sp
	jsr	_sprite_prepare
	move.w	#80,-(sp)
	move.w	#1,-(sp)
	jsr	_show_sprite
	addq.w	#4,sp
	move.w	#3,-(sp)
	jsr	_load_bkgnd
	addq.w	#2,sp
	move.l	#L9,-(sp)
	jsr	_play_GFS_sound
	addq.w	#4,sp
	move.w	#140,-(sp)
	jsr	_wait_delay
	addq.w	#2,sp
	bra	L4
	.text
	.globl	_play_level
_play_level:
	link	a6,#-10
	movem.l	d3/d4/d5/d6,-(sp)
	jsr	_clrscr
	move.w	#144,-(sp)
	move.w	#256,-(sp)
	move.l	#L13,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.w	#16,-(sp)
	move.w	#240,-(sp)
	move.l	#L14,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.w	#256,-(sp)
	move.w	#512,-(sp)
	move.l	#L15,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.w	#512,_tileset_base_tile
	move.w	#57344,_tileset_field_addr
	move.w	#64,-(sp)
	move.w	#768,-(sp)
	move.l	#L16,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.w	#64,-(sp)
	move.w	#832,-(sp)
	move.l	#L17,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.w	#64,-(sp)
	move.w	#896,-(sp)
	move.l	#L18,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.w	#64,-(sp)
	move.w	#960,-(sp)
	move.l	#L19,-(sp)
	jsr	_tileset_load_RDC
	addq.w	#8,sp
	move.l	#_bkg_pal,-(sp)
	clr.w	-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#_player_pal,-(sp)
	move.w	#1,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	move.l	#_alt_pal,-(sp)
	move.w	#2,-(sp)
	jsr	_set_colors
	addq.w	#6,sp
	jsr	_choose_enemies
	jsr	_generate_map
L20:
	tst.w	_lives
	beq	L21
	tst.w	_gem_count
	beq	L21
	move.w	#9,-(sp)
	move.w	#8448,-(sp)
	move.w	#2560,-(sp)
	move.w	#384,-(sp)
	move.w	#384,-(sp)
	move.w	#1,-(sp)
	move.l	#_actor_sprites,-(sp)
	jsr	_sprite_init
	lea	16(sp),sp
	move.w	#1,_actor_sprites+20
	move.w	#47,_actor_sprites+18
	move.w	#8,_actor_sprites+26
	move.w	#8,_actor_sprites+36
	move.w	#1536,_actor_sprites+30
	move.w	#1536,_actor_sprites+40
	jsr	_ai_reset
	jsr	_shot_reset
	move.w	#0,_shot_dly
	move.w	_actor_sprites+2,d0
	sub.w	#148,d0
	move.w	d0,_actor_map_x
	move.w	_actor_sprites+4,d0
	sub.w	#100,d0
	move.w	d0,_actor_map_y
	move.w	#0,_tgt_angle
	move.w	#0,_cur_angle
	move.w	_actor_map_y,-(sp)
	move.w	_actor_map_x,-(sp)
	jsr	_rpg_map_repaint
	addq.w	#4,sp
	moveq.l	#0,d3
	moveq.l	#0,d5
	move.w	#0,_player_dead
L22:
	tst.w	_gem_count
	beq	L23
	tst.w	_player_dead
	bne	L23
	jsr	_read_joypad1
	move.w	d0,d6
	tst.w	d3
	bne	L24
	tst.w	d5
	beq	L25
	move.w	#16,-(sp)
	jsr	_spawn_enemy
	addq.w	#2,sp
L26:
	moveq.l	#20,d0
	mulu	_level,d0
	move.w	d0,d3
	cmp.w	#250,d3
	bls	L27
	moveq.l	#50,d3
L28:
	move.w	#2,-(sp)
	jsr	_random
	addq.w	#2,sp
	move.w	d0,d5
L29:
	subq.w	#1,d3
	move.w	d6,-(sp)
	move.l	#_actor_sprites,-(sp)
	jsr	_handle_player
	addq.w	#6,sp
	jsr	_ai_handle
	jsr	_shot_move
	move.w	#1,-2(a6)
L32:
	cmp.w	#40,-2(a6)
	beq	L34
	moveq.l	#42,d0
	mulu	-2(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_sprite_move
	addq.w	#4,sp
	addq.w	#1,-2(a6)
	bra	L32
L34:
	move.w	#0,-2(a6)
L35:
	cmp.w	#40,-2(a6)
	beq	L37
	moveq.l	#42,d0
	mulu	-2(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_sprite_draw
	addq.w	#4,sp
	addq.w	#1,-2(a6)
	bra	L35
L37:
	jsr	_shot_draw
	jsr	_wait_sync
	move.w	_actor_map_y,-(sp)
	move.w	_actor_map_x,-(sp)
	jsr	_rpg_map_scroll
	addq.w	#4,sp
	move.w	#80,-(sp)
	move.w	#1,-(sp)
	jsr	_show_sprite
	addq.w	#4,sp
	jsr	_sprite_prepare
	move.w	#28,-(sp)
	move.w	#1,-(sp)
	jsr	_gotoxy
	move.l	#L38,(sp)
	jsr	_cputs
	addq.w	#4,sp
	move.w	#3,-(sp)
	move.w	_level,-(sp)
	jsr	_write_uint
	move.l	#L39,(sp)
	jsr	_cputs
	addq.w	#4,sp
	move.w	#3,-(sp)
	move.w	_lives,-(sp)
	jsr	_write_uint
	move.l	#L40,(sp)
	jsr	_cputs
	addq.w	#4,sp
	move.w	#8,-(sp)
	move.l	_score,-(sp)
	jsr	_write_ulong
	addq.w	#6,sp
	bra	L22
L27:
	move.w	#300,d0
	sub.w	d3,d0
	move.w	d0,d3
	bra	L28
L25:
	move.w	#12256,-(sp)
	jsr	_spawn_enemy
	addq.w	#2,sp
	bra	L26
L24:
	cmp.w	#30,d3
	bne	L29
	move.l	#L31,-(sp)
	jsr	_play_GFS_sound
	addq.w	#4,sp
	bra	L29
L23:
	tst.w	_player_dead
	beq	L20
	moveq.l	#30,d4
L42:
	tst.w	d4
	beq	L44
	move.w	#1,-2(a6)
L45:
	cmp.w	#40,-2(a6)
	beq	L47
	moveq.l	#42,d0
	mulu	-2(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_sprite_move
	addq.w	#4,sp
	moveq.l	#42,d0
	mulu	-2(a6),d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_actor_sprites,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_sprite_draw
	addq.w	#4,sp
	addq.w	#1,-2(a6)
	bra	L45
L47:
	jsr	_ai_handle
	jsr	_wait_sync
	move.w	#80,-(sp)
	move.w	#1,-(sp)
	jsr	_show_sprite
	addq.w	#4,sp
	jsr	_sprite_prepare
	subq.w	#1,d4
	bra	L42
L44:
	subq.w	#1,_lives
	bra	L20
L21:
	tst.w	_lives
	beq	L12
	moveq.l	#50,d0
	mulu	_level,d0
	add.w	#100,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,_score
	addq.w	#1,_level
L12:
	movem.l	(sp)+,d3/d4/d5/d6
	unlk	a6
	rts
	.text
	.globl	_choose_enemies
_choose_enemies:
	link	a6,#0
	movem.l	d3-d4,-(sp)
	move.w	_level,d0
	addq.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	divu	#3,d1
	move.w	d1,d4
	cmp.w	#6,d4
	bls	L52
	moveq.l	#6,d4
L52:
	moveq.l	#0,d3
L53:
	cmp.w	#5,d3
	beq	L51
	move.w	_level,d0
	addq.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	divu	#3,d1
	swap	d1
	tst.w	d1
	bne	L56
	move.w	d4,d0
	subq.w	#1,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_enemy_order,d1
	move.l	d1,a0
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_chosen_enemies,d1
	move.l	d1,a1
	move.w	(a0),(a1)
L54:
	addq.w	#1,d3
	bra	L53
L56:
	move.w	d4,-(sp)
	jsr	_random
	addq.w	#2,sp
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_enemy_order,d1
	move.l	d1,a0
	move.w	d3,d0
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_chosen_enemies,d1
	move.l	d1,a1
	move.w	(a0),(a1)
	bra	L54
L51:
	movem.l	(sp)+,d3-d4
	unlk	a6
	rts
	.text
	.globl	_generate_map
_generate_map:
	link	a6,#-2
	movem.l	d3/d4/d5,-(sp)
	move.w	#128,-(sp)
	move.w	#128,-(sp)
	move.l	#_huge_buffer+16384,-(sp)
	jsr	_rpg_map_init_ptrs
	addq.w	#8,sp
	moveq.l	#0,d3
L61:
	cmp.w	#48,d3
	beq	L63
	moveq.l	#0,d4
L64:
	cmp.w	#48,d4
	beq	L62
	move.w	#5,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	bne	L67
	move.w	#4,-(sp)
	jsr	_random
	move.w	d0,(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
L65:
	addq.w	#1,d4
	bra	L64
L67:
	clr.w	-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	bra	L65
L62:
	addq.w	#1,d3
	bra	L61
L63:
	moveq.l	#1,d3
L69:
	cmp.w	#47,d3
	beq	L71
	move.w	#3,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	bne	L72
	move.w	#4,-(sp)
	jsr	_random
	addq.w	#2,sp
	move.w	d0,d4
L73:
	move.w	d4,d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	clr.w	-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	d4,d0
	add.w	#12,d0
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	move.w	#47,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	addq.w	#1,d3
	bra	L69
L72:
	moveq.l	#0,d4
	bra	L73
L71:
	moveq.l	#0,d3
L74:
	cmp.w	#23,d3
	beq	L76
	move.w	#3,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	bne	L77
	move.w	#4,-(sp)
	jsr	_random
	addq.w	#2,sp
	move.w	d0,d4
L78:
	addq.w	#8,d4
	move.w	d4,-(sp)
	clr.w	-(sp)
	moveq.l	#23,d0
	sub.w	d3,d0
	move.w	d0,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	d4,-(sp)
	clr.w	-(sp)
	move.w	d3,d0
	add.w	#24,d0
	move.w	d0,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#3,-(sp)
	jsr	_random
	addq.w	#2,sp
	tst.w	d0
	bne	L79
	move.w	#4,-(sp)
	jsr	_random
	addq.w	#2,sp
	move.w	d0,d4
L80:
	add.w	#16,d4
	move.w	d4,-(sp)
	move.w	#47,-(sp)
	moveq.l	#23,d0
	sub.w	d3,d0
	move.w	d0,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	d4,-(sp)
	move.w	#47,-(sp)
	move.w	d3,d0
	add.w	#24,d0
	move.w	d0,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	addq.w	#1,d3
	bra	L74
L79:
	moveq.l	#0,d4
	bra	L80
L77:
	moveq.l	#0,d4
	bra	L78
L76:
	move.w	#20,-(sp)
	clr.w	-(sp)
	clr.w	-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#21,-(sp)
	clr.w	-(sp)
	move.w	#47,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#22,-(sp)
	move.w	#47,-(sp)
	clr.w	-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#23,-(sp)
	move.w	#47,-(sp)
	move.w	#47,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#26,-(sp)
	move.w	#23,-(sp)
	clr.w	-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#27,-(sp)
	move.w	#23,-(sp)
	move.w	#47,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#28,-(sp)
	clr.w	-(sp)
	move.w	#22,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#30,-(sp)
	clr.w	-(sp)
	move.w	#23,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#30,-(sp)
	clr.w	-(sp)
	move.w	#24,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	#29,-(sp)
	clr.w	-(sp)
	move.w	#25,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	moveq.l	#3,d0
	mulu	_level,d0
	add.w	#15,d0
	move.w	d0,d3
L81:
	tst.w	d3
	beq	L83
	move.w	#37,-(sp)
	move.w	#46,-(sp)
	jsr	_random
	addq.w	#1,d0
	move.w	d0,(sp)
	move.w	#46,-(sp)
	jsr	_random
	addq.w	#1,d0
	move.w	d0,(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	subq.w	#1,d3
	bra	L81
L83:
	move.w	_level,d0
	addq.w	#7,d0
	move.w	d0,d3
L84:
	tst.w	d3
	beq	L86
	move.w	#36,-(sp)
	move.w	#46,-(sp)
	jsr	_random
	addq.w	#1,d0
	move.w	d0,(sp)
	move.w	#46,-(sp)
	jsr	_random
	addq.w	#1,d0
	move.w	d0,(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	subq.w	#1,d3
	bra	L84
L86:
	move.w	#0,_gem_count
	moveq.l	#0,d3
L87:
	cmp.w	#48,d3
	beq	L60
	moveq.l	#0,d4
L90:
	cmp.w	#48,d4
	beq	L88
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	clr.w	d1
	move.b	d0,d1
	move.w	d1,d5
	cmp.w	#36,d5
	bne	L91
	addq.w	#1,_gem_count
L91:
	addq.w	#1,d4
	bra	L90
L88:
	addq.w	#1,d3
	bra	L87
L60:
	movem.l	(sp)+,d3/d4/d5
	unlk	a6
	rts
	.text
	.globl	_check_gem_mine
_check_gem_mine:
	link	a6,#0
	movem.l	d3-d5/a3,-(sp)
	move.l	8(a6),a3
	move.w	12(a6),d3
	move.w	14(a6),d4
	lsr.w	#4,d3
	lsr.w	#4,d4
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_get_block
	addq.w	#4,sp
	clr.w	d1
	move.b	d0,d1
	move.w	d1,d5
	move.w	d1,d0
	cmp.w	#36,d0
	beq	L99
	cmp.w	#37,d0
	beq	L100
	clr.w	d0
L96:
	movem.l	(sp)+,d3-d5/a3
	unlk	a6
	rts
L100:
	clr.w	-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	_actor_map_y,-(sp)
	move.w	_actor_map_x,-(sp)
	jsr	_rpg_map_repaint
	addq.w	#4,sp
	jsr	_kill_player
	moveq.l	#1,d0
	bra	L96
L99:
	subq.w	#1,_gem_count
	move.w	_level,d0
	lsl.w	#1,d0
	add.w	#10,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	d1,_score
	clr.w	-(sp)
	move.w	d4,-(sp)
	move.w	d3,-(sp)
	jsr	_rpg_map_set_block
	addq.w	#6,sp
	move.w	_actor_map_y,-(sp)
	move.w	_actor_map_x,-(sp)
	jsr	_rpg_map_repaint
	addq.w	#4,sp
	move.w	#15,-(sp)
	move.w	#2,-(sp)
	jsr	_set_vol
	move.l	#_Ding1,(sp)
	move.w	#2,-(sp)
	jsr	_start_sound
	addq.w	#6,sp
	clr.w	d0
	bra	L96
	.text
	.globl	_handle_player
_handle_player:
	link	a6,#0
	movem.l	d3/a3,-(sp)
	move.l	8(a6),a3
	move.w	12(a6),d3
	move.w	d3,d0
	and.w	#4,d0
	beq	L105
	sub.w	#40,24(a3)
	move.w	#64,_tgt_angle
L106:
	move.w	d3,d0
	and.w	#1,d0
	beq	L108
	sub.w	#40,34(a3)
	move.w	d3,d0
	and.w	#4,d0
	beq	L109
	move.w	#32,_tgt_angle
L113:
	move.w	_cur_angle,d0
	cmp.w	_tgt_angle,d0
	beq	L119
	move.w	_cur_angle,d0
	sub.w	_tgt_angle,d0
	and.w	#255,d0
	cmp.w	#128,d0
	bcc	L120
	subq.w	#8,_cur_angle
L121:
	and.w	#255,_cur_angle
L119:
	move.w	d3,d0
	and.w	#96,d0
	beq	L122
	tst.w	_shot_dly
	bne	L122
	move.w	#1,-(sp)
	move.w	#16624,-(sp)
	move.w	#1600,-(sp)
	move.w	_cur_angle,d0
	add.w	#64,d0
	move.w	d0,-(sp)
	move.w	#12,-(sp)
	move.w	4(a3),d0
	addq.w	#8,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	addq.w	#8,d0
	move.w	d0,-(sp)
	jsr	_shot_shoot
	lea	14(sp),sp
	move.w	#15,-(sp)
	move.w	#1,-(sp)
	jsr	_set_vol
	move.l	#_Shot1,(sp)
	move.w	#1,-(sp)
	jsr	_start_sound
	addq.w	#6,sp
	move.w	#5,_shot_dly
L122:
	tst.w	_shot_dly
	beq	L124
	cmp.w	#1,_shot_dly
	beq	L125
	subq.w	#1,_shot_dly
L124:
	move.w	_cur_angle,d0
	lsr.w	#4,d0
	mulu	10(a3),d0
	mulu	_actor_sprites+20,d0
	move.w	d0,12(a3)
	move.l	a3,-(sp)
	jsr	_sprite_move
	addq.w	#4,sp
	cmp.w	#16,2(a3)
	bge	L128
	move.w	#16,2(a3)
	move.w	24(a3),d0
	neg.w	d0
	move.w	d0,24(a3)
L129:
	cmp.w	#16,4(a3)
	bge	L131
	move.w	#16,4(a3)
	move.w	34(a3),d0
	neg.w	d0
	move.w	d0,34(a3)
L132:
	move.w	4(a3),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.l	a3,-(sp)
	jsr	_check_gem_mine
	addq.w	#8,sp
	move.w	4(a3),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	add.w	#20,d0
	move.w	d0,-(sp)
	move.l	a3,-(sp)
	jsr	_check_gem_mine
	addq.w	#8,sp
	move.w	4(a3),d0
	add.w	#20,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.l	a3,-(sp)
	jsr	_check_gem_mine
	addq.w	#8,sp
	move.w	4(a3),d0
	add.w	#20,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	add.w	#20,d0
	move.w	d0,-(sp)
	move.l	a3,-(sp)
	jsr	_check_gem_mine
	addq.w	#8,sp
	move.w	#1,-(sp)
	move.w	4(a3),d0
	add.w	#20,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	add.w	#20,d0
	move.w	d0,-(sp)
	move.w	4(a3),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.w	2(a3),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	jsr	_shot_at
	lea	10(sp),sp
	tst.w	d0
	beq	L134
	jsr	_kill_player
L134:
	move.w	2(a3),d0
	sub.w	#148,d0
	move.w	d0,_actor_map_x
	move.w	4(a3),d0
	sub.w	#100,d0
	move.w	d0,_actor_map_y
	tst.w	_actor_map_x
	bge	L135
	move.w	#0,_actor_map_x
L135:
	cmp.w	#448,_actor_map_x
	ble	L136
	move.w	#448,_actor_map_x
L136:
	tst.w	_actor_map_y
	bge	L137
	move.w	#0,_actor_map_y
L137:
	cmp.w	#544,_actor_map_y
	ble	L138
	move.w	#544,_actor_map_y
L138:
	move.w	_map_coord_x_mask,d0
	and.w	d0,_actor_map_x
	move.w	_map_coord_y_mask,d0
	and.w	d0,_actor_map_y
	move.w	_actor_map_x,_sprite_offs_x
	move.w	_actor_map_y,_sprite_offs_y
	movem.l	(sp)+,d3/a3
	unlk	a6
	rts
L131:
	cmp.w	#728,4(a3)
	ble	L132
	move.w	#728,4(a3)
	move.w	34(a3),d0
	neg.w	d0
	move.w	d0,34(a3)
	bra	L132
L128:
	cmp.w	#728,2(a3)
	ble	L129
	move.w	#728,2(a3)
	move.w	24(a3),d0
	neg.w	d0
	move.w	d0,24(a3)
	bra	L129
L125:
	move.w	d3,d0
	and.w	#96,d0
	bne	L124
	move.w	#0,_shot_dly
	bra	L124
L120:
	addq.w	#8,_cur_angle
	bra	L121
L109:
	move.w	d3,d0
	and.w	#8,d0
	beq	L111
	move.w	#224,_tgt_angle
	bra	L113
L111:
	move.w	#0,_tgt_angle
	bra	L113
L108:
	move.w	d3,d0
	and.w	#2,d0
	beq	L113
	add.w	#40,34(a3)
	move.w	d3,d0
	and.w	#4,d0
	beq	L115
	move.w	#96,_tgt_angle
	bra	L113
L115:
	move.w	d3,d0
	and.w	#8,d0
	beq	L117
	move.w	#160,_tgt_angle
	bra	L113
L117:
	move.w	#128,_tgt_angle
	bra	L113
L105:
	move.w	d3,d0
	and.w	#8,d0
	beq	L106
	add.w	#40,24(a3)
	move.w	#192,_tgt_angle
	bra	L106
	.text
	.globl	_kill_player
_kill_player:
	link	a6,#0
	movem.l	d3-d5,-(sp)
	moveq.l	#16,d3
L142:
	tst.w	d3
	beq	L144
	clr.w	-(sp)
	move.l	_player,a0
	move.w	4(a0),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	move.l	_player,a0
	move.w	2(a0),d0
	addq.w	#4,d0
	move.w	d0,-(sp)
	jsr	_ai_spawn_enemy
	addq.w	#6,sp
	move.w	d0,d5
	beq	L143
	moveq.l	#3,d4
L146:
	tst.w	d4
	beq	L143
	move.w	d4,d0
	moveq.l	#9,d1
	lsl.w	d1,d0
	move.w	d0,-(sp)
	move.w	d3,d0
	lsl.w	#4,d0
	move.w	d0,-(sp)
	move.w	d5,d0
	subq.w	#1,d0
	lsl.w	#4,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_ai_recs,d1
	move.l	d1,a0
	pea	(a0)
	jsr	_ai_accelerate
	addq.w	#8,sp
	subq.w	#1,d4
	bra	L146
L143:
	subq.w	#1,d3
	bra	L142
L144:
	move.l	#L149,-(sp)
	jsr	_play_GFS_sound
	addq.w	#4,sp
	move.w	#1,_player_dead
	movem.l	(sp)+,d3-d5
	unlk	a6
	rts
	.data
L149:	.dc.b	$42,$4f,$4f,$4d,$35,$2e,$53,$4e,$44
	.dc.b	0
L40:	.dc.b	$20,$20,$53,$63,$6f,$72,$65,$3a,$20
	.dc.b	0
L39:	.dc.b	$20,$20,$4c,$69,$76,$65,$73,$3a,$20
	.dc.b	0
L38:	.dc.b	$4c,$65,$76,$65,$6c,$3a,$20
	.dc.b	0
L31:	.dc.b	$54,$45,$4c,$45,$50,$4f,$52,$54,$2e,$53,$4e
	.dc.b	$44
	.dc.b	0
L19:	.dc.b	$5a,$49,$47,$47,$45,$52,$2e,$52,$44,$43
	.dc.b	0
L18:	.dc.b	$47,$55,$4e,$4e,$45,$52,$2e,$52,$44,$43
	.dc.b	0
L17:	.dc.b	$42,$4c,$41,$44,$45,$2e,$52,$44,$43
	.dc.b	0
L16:	.dc.b	$45,$58,$50,$4c,$4f,$2e,$52,$44,$43
	.dc.b	0
L15:	.dc.b	$54,$49,$4c,$45,$53,$45,$54,$31,$2e,$52,$44
	.dc.b	$43
	.dc.b	0
L14:	.dc.b	$53,$48,$4f,$54,$53,$2e,$52,$44,$43
	.dc.b	0
L13:	.dc.b	$50,$4c,$41,$59,$45,$52,$2e,$52,$44,$43
	.dc.b	0
L9:	.dc.b	$47,$41,$4d,$45,$4f,$56,$45,$52,$2e,$53,$4e
	.dc.b	$44
	.dc.b	0
L3:	.dc.b	$46,$4f,$4e,$54,$2e,$43,$48,$52
	.dc.b	0
	.text
	.globl	_spawn_enemy
_spawn_enemy:
	link	a6,#0
	move.w	#5,-(sp)
	jsr	_random
	lsl.w	#1,d0
	moveq.l	#0,d1
	move.w	d0,d1
	add.l	#_chosen_enemies,d1
	move.l	d1,a0
	move.w	(a0),(sp)
	move.w	#384,-(sp)
	move.w	8(a6),-(sp)
	jsr	_ai_spawn_enemy
	unlk	a6
	rts
