/*
	GemQuest
	by Haroldo de Oliveira pinheiro
*/

#include "genesis.h"
#include "utils.h"
#include "psgsound.h"
#include "conio.h"
#include "rdc.h"
#include "utils.h"
#include "sprhand.h"
#include "actor.h"
#include "rpgmap.h"
#include "randmap.h"
#include "rdctile.h"
#include "gemq_ai.h"
#include "shot.h"
#include "bkgs.h"
#include "gemquest.h"

uint bkg_pal[]={
0x000,
0x400,
0x800,
0xE00,
0x004,
0x008,
0x00E,
0x040,
0x080,
0x0E0,
0xE88,
0xEAA,
0x222,
0x666,
0xAAA,
0xEEE
};

uint alt_pal[]={
0x000,
0x044,
0x088,
0x0EE,
0x440,
0x880,
0xEE0,
0x404,
0x808,
0xE0E,
0x8EE,
0xAEE,
0x022,
0x466,
0x8AA,
0xCEE
};

uint player_pal[]={
0x000,
0x200,
0x400,
0x600,
0x800,
0xA00,
0xC00,
0xE00,
0x000,
0x222,
0x444,
0x666,
0x888,
0xAAA,
0xCCC,
0xEEE
};

uint enemy_order[]={
	ENEMY_TYPE_BLADE1,
	ENEMY_TYPE_SHOOT1,
	ENEMY_TYPE_BLADE2,
	ENEMY_TYPE_ZIGGER1,
	ENEMY_TYPE_SHOOT2,
	ENEMY_TYPE_ZIGGER2
};

void play_level();
void choose_enemies();
void generate_map();
void handle_player(player, joy);
void spawn_enemy();

uint shot_dly;
uint tgt_angle, cur_angle;
sprite_rec *player;
uint gem_count;
uint lives;
uint level;
uint player_dead;
uint chosen_enemies[5];
ulong score;

void main()
{
    register uint i,j,joy;
	uint x, y;
	ulong tmp;
	uint countdown;

    /* Initialize Genesis GFX registers */
    init_GFX();
	RAZ();

    /* Wait until GFX reg are initialized */
    wait_sync();

	/* Inicializa o Sega Genesis File System */
	init_GFS();

	init_joypad();

	get_GFS_fileaddr(&tmp, "FONT.CHR");
	loadfont((uchar *)tmp,0,256,15,0);
	init_text_mode();


	player = actor_sprites;

	while(TRUE){
		clrscr();
		scrollv(0, 0);
		scrollh(0, 0);
		sprite_prepare();
		show_sprite(1,80);

		load_bkgnd_dly(0, 140);
		load_bkgnd_dly(1, 140);
		load_bkgnd_dly(2, 140);

		lives = 3;
		level = 1;
		score = 0;
		while(lives) {
			play_level();
		}
	
		if(!lives) {
			clrscr();
			scrollv(0, 0);
			scrollh(0, 0);
			sprite_prepare();
			show_sprite(1,80);

			load_bkgnd(3);			
			play_GFS_sound("GAMEOVER.SND");
			wait_delay(140);
		}
	}
}

void play_level()
{
	uint i, j;
	uint joy;
	uint countdown;
	uint spawn_where;

	clrscr();

	tileset_load_RDC("PLAYER.RDC", 256, 144);
	tileset_load_RDC("SHOTS.RDC",  240, 16);

	tileset_load_RDC("TILESET1.RDC", 512, 256);
	tileset_base_tile = 512;
	tileset_field_addr = BPLAN;

	tileset_load_RDC("EXPLO.RDC",  768, 64);
	tileset_load_RDC("BLADE.RDC",  832, 64);
	tileset_load_RDC("GUNNER.RDC", 896, 64);
	tileset_load_RDC("ZIGGER.RDC", 960, 64);

    set_colors(0, bkg_pal);
    set_colors(1, player_pal);
    set_colors(2, alt_pal);

	choose_enemies();
	generate_map();

	/* Main game loop */
	while(lives && gem_count){
		sprite_init(&actor_sprites[0], 1, 384, 384, 0xA00, BUILD_ATTR(1,0,0,0)|256, 9);
		actor_sprites[0].frm_cnt = 1;
		actor_sprites[0].frm_spd = 0x2FL;
		actor_sprites[0].xfric   = 0x08;
		actor_sprites[0].yfric   = 0x08;
		actor_sprites[0].xmaxac  = 0x600;
		actor_sprites[0].ymaxac  = 0x600;

		ai_reset();
		shot_reset();
		shot_dly = 0;

		actor_map_x = (actor_sprites[0].posx-148);
		actor_map_y = (actor_sprites[0].posy-100);

		tgt_angle = 0;
		cur_angle = 0;

		rpg_map_repaint(actor_map_x, actor_map_y);

		countdown   = 0;
		spawn_where = 0;

		player_dead = FALSE;
		while(gem_count && !player_dead){
			joy = read_joypad1();

			if(!countdown) {
				if(spawn_where) {
					spawn_enemy(16);
				} else {
					spawn_enemy((PLAYFIELD_WIDTH-2)*16);
				}

				countdown = level*20;
				if(countdown > 250) {
					countdown = 50;
				} else {
					countdown = 300 - countdown;
				}

				spawn_where = random(2);
			} else if(countdown == 30) {
				play_GFS_sound("TELEPORT.SND");			
			}
			countdown--;

			handle_player(&actor_sprites[0], joy);
			ai_handle();
			shot_move();

			for(i = 1; i != MAX_ACTORS; i++) {
				sprite_move(&actor_sprites[i]);
			}

			for(i = 0; i != MAX_ACTORS; i++) {
				sprite_draw(&actor_sprites[i]);
			}

			shot_draw();

			wait_sync();

			rpg_map_scroll(actor_map_x, actor_map_y);

			show_sprite(1,80);
			sprite_prepare();

			gotoxy(1, 28);
			cputs("Level: ");
			write_uint(level, 3);
			cputs("  Lives: ");
			write_uint(lives, 3);
			cputs("  Score: ");
			write_ulong(score, 8);
		}

		if(player_dead){
			for(j = 30; j; j--){
				for(i = 1; i != MAX_ACTORS; i++) {
					sprite_move(&actor_sprites[i]);
					sprite_draw(&actor_sprites[i]);
				}

				ai_handle();

				wait_sync();
				show_sprite(1,80);
				sprite_prepare();
			}
			lives--;
		}
	}

	if(lives) {
		score += 100 + level*50;
		level++;
	}
}

void choose_enemies()
{
	register uint i;
	register uint max;
	
	max = ((level+4) / 3);
	if(max > 6) {
		max = 6;
	}
	for(i = 0; i != 5; i++) {
		if(!((level+4) % 3)) {
			chosen_enemies[i] = enemy_order[max-1];
		} else {
			chosen_enemies[i] = enemy_order[random(max)];
		}
	}
}

void generate_map()
{
	register uint i, j;
	uint tile;

	rpg_map_init_ptrs(huge_buffer+16384, 128, 128);

	/* Starry background */
	for(i = 0; i != 48; i++) {
		for(j = 0; j != 48; j++) {
			if(!random(5)) {
				rpg_map_set_block(i, j, random(4));
			} else {
				rpg_map_set_block(i, j, 0);
			}
		}
	}

	/* Left and right walls */
	for(i = 1; i != 47; i++) {
		if(!random(3)) {
			j = random(4);
		} else {
			j = 0;
		}
		rpg_map_set_block(0,  i, j + 4);
		rpg_map_set_block(47, i, j + 12);
	}

	/* Top and bottom walls */
	for(i = 0; i != 23; i++) {
		if(!random(3)) {
			j = random(4);
		} else {
			j = 0;
		}
		j += 8;

		rpg_map_set_block(23-i, 0, j);
		rpg_map_set_block(24+i, 0, j);

		if(!random(3)) {
			j = random(4);
		} else {
			j = 0;
		}
		j += 16;

		rpg_map_set_block(23-i, 47, j);
		rpg_map_set_block(24+i, 47, j);
	}

	/* Corners */
	rpg_map_set_block( 0,  0, 20);
	rpg_map_set_block(47,  0, 21);
	rpg_map_set_block( 0, 47, 22);
	rpg_map_set_block(47, 47, 23);

	/* Enemy generators */
	rpg_map_set_block( 0, 23, 26);
	rpg_map_set_block(47, 23, 27);

	/* Exit door */
	rpg_map_set_block(22, 0, 28);
	rpg_map_set_block(23, 0, 30);
	rpg_map_set_block(24, 0, 30);
	rpg_map_set_block(25, 0, 29);

	/* Mines */
	for(i = 15+(level*3); i; i--) {
		rpg_map_set_block(random(46)+1, random(46)+1, 37);
	}

	/* Gems */
	for(i = 7+level; i; i--) {
		rpg_map_set_block(random(46)+1, random(46)+1, 36);
	}

	gem_count = 0;
	for(i = 0; i != 48; i++) {
		for(j = 0; j != 48; j++) {
			tile = rpg_map_get_block(i, j);
			if(tile == 36){
				gem_count++;
			}
		}
	}
}

uint check_gem_mine(player, x, y)
register sprite_rec *player;
register uint x;
register uint y;
{
	register uint tile;

	x >>= 4;
	y >>= 4;
	tile = rpg_map_get_block(x, y);

	switch(tile) {
		case 36:
			gem_count--;
			score += 10 + (level << 1);
			rpg_map_set_block(x, y, 0);
			rpg_map_repaint(actor_map_x, actor_map_y);
			set_vol(2,0x0F);
			start_sound(2,Ding1);
		return FALSE;

		case 37:
			rpg_map_set_block(x, y, 0);
			rpg_map_repaint(actor_map_x, actor_map_y);
			kill_player();
		return TRUE;
	}

	return FALSE;
}

void handle_player(player, joy)
register sprite_rec *player;
register uint joy;
{
	/* Acceleration */
	if(joy & JOY_LEFT){
		player->xaccel -= 0x028;
		tgt_angle = ANGLE_WEST;
	} else if(joy & JOY_RIGHT){
		player->xaccel += 0x028;
		tgt_angle = ANGLE_EAST;
	}

	if(joy & JOY_UP){
		player->yaccel -= 0x028;

		if(joy & JOY_LEFT){
			tgt_angle = ANGLE_NORTHWEST;
		} else if(joy & JOY_RIGHT){
			tgt_angle = ANGLE_NORTHEAST;
		} else {
			tgt_angle = ANGLE_NORTH;
		}
	} else if(joy & JOY_DOWN){
		player->yaccel += 0x028;
		if(joy & JOY_LEFT){
			tgt_angle = ANGLE_SOUTHWEST;
		} else if(joy & JOY_RIGHT){
			tgt_angle = ANGLE_SOUTHEAST;
		} else {
			tgt_angle = ANGLE_SOUTH;
		}
	}

	/* Spins, trying to approximate the target angle */
	if(cur_angle != tgt_angle) {
		if(((cur_angle - tgt_angle) & 0xFF) < ANGLE_SOUTH) {
			cur_angle -= 8;
		} else {
			cur_angle += 8;
		}
		cur_angle &= 0xFF;
	}

	/* Handles shooting */
	if(joy & (BUTTON_A|BUTTON_C)) {
		if(!shot_dly) {
			shot_shoot(player->posx+8, player->posy+8, 
		               12, cur_angle+64, 0x640, BUILD_ATTR(2,0,0,0)|240, 1);
			set_vol(1,0x0F);
			start_sound(1,Shot1);
			shot_dly = 5;
		}
	}

	if(shot_dly) {
		if(shot_dly != 1) {
			shot_dly--;
		} else {
			if(!(joy & (BUTTON_A|BUTTON_C))) {
				shot_dly = 0;
			}
		}
	}

	player->stance = (cur_angle >> 4)*player->tilcnt*actor_sprites->frm_cnt;

	sprite_move(player);

	/* Checks collision with borders */
	if(player->posx < 16) {
		player->posx = 16;
		player->xaccel = -player->xaccel;
 	} else if(player->posx > (PLAYFIELD_WIDTH-40)) {
		player->posx = (PLAYFIELD_WIDTH-40);
		player->xaccel = -player->xaccel;
	}

	if(player->posy < 16) {
		player->posy = 16;
		player->yaccel = -player->yaccel;
	} else if(player->posy > (PLAYFIELD_HEIGHT-40)) {
		player->posy = (PLAYFIELD_HEIGHT-40);
		player->yaccel = -player->yaccel;
	}

	/* Checks collision with gems/mines */
	check_gem_mine(player, player->posx+4,  player->posy+4);
	check_gem_mine(player, player->posx+20, player->posy+4);
	check_gem_mine(player, player->posx+4,  player->posy+20);
	check_gem_mine(player, player->posx+20, player->posy+20);

	/* Checks collision with shots */
	if(shot_at(player->posx+4, player->posy+4, player->posx+20, player->posy+20, 1)) {
		kill_player();
	}

	/* Scrolls the background */
	actor_map_x = (player->posx-148);
	actor_map_y = (player->posy-100);

	if((int)actor_map_x < 0) {
		actor_map_x = 0;
	}
	if((int)actor_map_x > (PLAYFIELD_WIDTH-320)) {
		actor_map_x = (PLAYFIELD_WIDTH-320);
	}
	if((int)actor_map_y < 0) {
		actor_map_y = 0;
	}
	if((int)actor_map_y > (PLAYFIELD_HEIGHT-224)) {
		actor_map_y = (PLAYFIELD_HEIGHT-224);
	}

	actor_map_x &= map_coord_x_mask;
	actor_map_y &= map_coord_y_mask;

	sprite_offs_x = actor_map_x;
	sprite_offs_y = actor_map_y;
}

void kill_player()
{
	register uint i, j;
	register uint ai_num;

	for (i = 16; i; i--){
		ai_num = ai_spawn_enemy(player->posx+4, player->posy+4, ENEMY_TYPE_KABOOM);
		if(ai_num){
			for(j = 3; j; j--){
				ai_accelerate(&ai_recs[ai_num-ENEMY_FIRST], i << 4, j << 9);
			}
		}
	}
	
	play_GFS_sound("BOOM5.SND");

	player_dead = TRUE;
}

void spawn_enemy(x)
uint x;
{
/*	ai_spawn_enemy(x, (PLAYFIELD_HEIGHT >> 1), ENEMY_TYPE_BLADE1+random(4));*/
/*	ai_spawn_enemy(x, (PLAYFIELD_HEIGHT >> 1), ENEMY_TYPE_ZIGGER1);*/
	ai_spawn_enemy(x, (PLAYFIELD_HEIGHT >> 1), chosen_enemies[random(5)]);
}
