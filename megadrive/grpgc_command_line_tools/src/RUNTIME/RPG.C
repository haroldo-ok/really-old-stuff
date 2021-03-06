/*
	Sega Genesis RPG Engine
	by Haroldo de Oliveira pinheiro
*/

#include "genesis.h"
#include "utils.h"
#include "psgsound.h"
#include "conio.h"
#include "rdc.h"
#include "utils.h"
#include "interr.h"
#include "rpgwalk.h"
#include "zopint.h"
#include "actor.h"
#include "rpgmap.h"
#include "randmap.h"
#include "rdctile.h"
#include "rpg_gui.h"
#include "rpg.h"

uint dungeon_pal[]={
0x000,
0x222,
0x666,
0xAAA,
0xEEE,
0x002,
0x006,
0x00A,
0x00E,
0x002,
0x026,
0x06A,
0x0AE,
0x268,
0x0AC,
0x0AE
};

uint interface_pal[]={
0x000,
0xA00,
0x0A0,
0xAA0,
0x00A,
0xA0A,
0x0AA,
0xAAA,
0x666,
0xE66,
0x6E6,
0xEE6,
0x66E,
0xE6E,
0x6EE,
0xEEE
};

uint player_pal[]={
0x220,
0x000,
0x888,
0x444,
0x48C,
0x048,
0x004,
0x0A0,
0x060,
0x840,
0xAA2,
0x0AC,
0x40C,
0x00A,
0x400,
0xCCC
};

void main()
{
	/* Inicializa o Sega Genesis File System */
	init_GFS();

	/* Loop principal */
	init_game();
	while(TRUE){
		init_level();
		game_loop();

		/*** DEBUG ***/
/*		write_uint(map_exit_found->x, 6);
		write_uint(map_exit_found->y, 6);
		write_uint(map_exit_found->width, 6);
		write_uint(map_exit_found->height, 6);
		cputs("\n");*/
	}
}

void init_game() {
    register uint i;

    /* Initialize Genesis GFX registers */
    init_GFX();
	RAZ();

    /* Wait until GFX reg are initialized */
    wait_sync();

	init_joypad();

	gui_init();

	for(i = 0; i != 4; i++){
    	set_colors(i, interface_pal);
	}

	zop_vm_init();
	actor_init_all();
}

void init_level() {
	walker *player;
	int old_plyx, old_plyy;

	player = &actor_sprites[0];
	old_plyx = player->blk_x;
	old_plyy = player->blk_y;

	zop_vm_reset();
	actor_init_all();

	if (map_exit_found != NULL) {
		rpg_map_exit(map_exit_found, old_plyx, old_plyy);
	} else {
		rpg_map_load("MAIN.MAP");

		map_x = 2;
		map_y = 2;
	}

	init_walker(&actor_sprites[0],(uint)FIRST_TILE_SPR);

	player = &actor_sprites[0];
	player->pos_x  = (map_x << 4);
	player->pos_y  = (map_y << 4);
	player->sprnum = 1;

	actor_map_x = (map_x << 4) - 160;
	actor_map_y = (map_y << 4) - 112;

	actor_move(0);
	rpg_map_repaint(actor_map_x, actor_map_y);
}

void game_loop() {
    register uint i,j,joy;
	walker *player;

	player = &actor_sprites[0];
	while (TRUE) {
		joy = read_joypad1();

		if(!player->stepcnt){
			if(joy&JOY_UP){
				actor_walk(0, RWK_FC_UP);
			}else if(joy&JOY_DOWN){
				actor_walk(0, RWK_FC_DOWN);
			}else if(joy&JOY_LEFT){
				actor_walk(0, RWK_FC_LEFT);
			}else if(joy&JOY_RIGHT){
				actor_walk(0, RWK_FC_RIGHT);
			}else{
				actor_sprites[0].frame = 0;
			}

			if(joy&BUTTON_C){
				actor_talk(0);
			}
		}

		actor_move_all();
		actor_exec_all();
		actor_draw_all();

		wait_sync();

		rpg_map_scroll(actor_map_x, actor_map_y);

		show_sprite(1,80);
		for(i = 1; i != 80; i++){
			def_sprite(i, -16, -16, 0, 0);
		}

		if (map_exit_found != NULL) {
			return;
		}

/*		gotoxy(1, 1);
		cputs("X: ");
		write_uint(actor_map_x, 5);
		cputs("  Y: ");
		write_uint(actor_map_y, 5);
		cputs("\nMapX: ");
		write_uint(map_x, 5);
		cputs("  MapY: ");
		write_uint(map_y, 5);*/

/*		gotoxy(1, 1);
		cputs("\nPlyX: ");
		write_uint(player->pos_x, 5);
		cputs("  PlyY: ");
		write_uint(player->pos_y, 5);
		cputs("\nBlkX: ");
		write_uint(player->blk_x, 5);
		cputs("  BlkY: ");
		write_uint(player->blk_y, 5);*/
	}
}