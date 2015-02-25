/* "Actor" routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "rpgmap.h"
#include "rdctile.h"
#include "rpgwalk.h"
#include "zopint.h"
#include "rgiqsort.h"
#include "actor.h"

walker actor_sprites[MAX_ACTORS];
zop_prog_rec actor_progs[MAX_ACTORS];

int actor_map_x;
int actor_map_y;

void actor_init_all()
{
	register uint i;
	register walker *wlk;
	register zop_prog_rec *prog;

	wlk = actor_sprites;
	prog = actor_progs;
	for(i = 0; i != MAX_ACTORS; i++){
		wlk->flags = ACT_FLAG_INACTIVE;
		prog->pc = NULL;
		wlk++;
		prog++;
	}
}

uchar check_border(x, y) 
register int x;
register int y;
{
	if (!(map_flags & MAP_FLAG_BORDER_WRAP)) {
		if (x < 0) {
			return FALSE;
		}
		if (x >= map_w) {
			return FALSE;
		}
		if (y < 0) {
			return FALSE;
		}
		if (y >= map_h) {
			return FALSE;
		}
	}

	return TRUE;
}

void clip_movement(x, y) 
register int *x;
register int *y;
{
	if (!(map_flags & MAP_FLAG_BORDER_WRAP)) {
		if (*x < 0) {
			*x = 0;
		}
		if (*x > (map_w << 4)-320) {
			*x = (map_w << 4)-320;
		}
		if (*y < 0) {
			*y = 0;
		}
		if (*y > (map_h << 4)-224) {
			*y = (map_h << 4)-224;
		}
	}
}

uchar actor_walk(num, direction)
uint num;
register uint direction;
{
	register walker *walk, *walk2;
	register uint x, y;
	register uint tile, attr, mask;
	register uint i;

	walk = &actor_sprites[num];
	x    = walk->blk_x;
	y    = walk->blk_y;

	mask = 0;

	switch(direction){
		case RWK_FC_UP:
			mask |= TILESET_ATR_BLOCK_UP;
			y--;
		break;

		case RWK_FC_DOWN:
			mask |= TILESET_ATR_BLOCK_DOWN;
			y++;
		break;

		case RWK_FC_LEFT:
			mask |= TILESET_ATR_BLOCK_LEFT;
			x--;
		break;

		case RWK_FC_RIGHT:
			mask |= TILESET_ATR_BLOCK_RIGHT;
			x++;
		break;
	}

	if (!check_border(x, y)) {
		walk->facing = direction;
		walker_checkbaseframe(walk);
		zop_signal_event(&actor_progs[num], ZOP_EVT_THUD);
		return FALSE;
	}

	x &= map_w_mask;
	y &= map_h_mask;

	/* Checks collision with background */
	tile = rpg_map_get_block(x, y);
	attr = tileset_attrs[tile];

	if(attr & mask){
		walk->facing = direction;
		walker_checkbaseframe(walk);
		zop_signal_event(&actor_progs[num], ZOP_EVT_THUD);
		return FALSE;
	}

	/* Checks collision with other actors */
	walk2 = actor_sprites;
	for(i = 0; i != MAX_ACTORS; i++){
		if((i != num) && !(walk2->flags & ACT_FLAG_INACTIVE)){
			if((walk2->blk_x == x) && (walk2->blk_y == y)){
				walk->facing = direction;
				walker_checkbaseframe(walk);
				if(!num){ /* if it's actor 0 (player) then calls the touch event */
					zop_signal_event(&actor_progs[i], ZOP_EVT_TOUCH);
				}
				return FALSE;
			}
		}

		walk2++;
	}

	/* If there's nothing blocking our actor, start walking */
	walker_walkto(walk,direction,1);
	return TRUE;
}

uchar actor_talk(num)
uint num;
{
	register walker *walk, *walk2;
	register uint x, y;
	register uint i;

	walk = &actor_sprites[num];
	x    = walk->blk_x;
	y    = walk->blk_y;

	/* Finds which coordinate we should look for an interlocutor */
	switch(walk->facing){
		case RWK_FC_UP:
			y--;
		break;
		case RWK_FC_DOWN:
			y++;
		break;
		case RWK_FC_LEFT:
			x--;
		break;
		case RWK_FC_RIGHT:
			x++;
		break;
	}

	x &= map_w_mask;
	y &= map_h_mask;

	/* See if there's an actor in the specified direction */
	walk2 = actor_sprites;
	for(i = 0; i != MAX_ACTORS; i++){
		if((i != num) && !(walk2->flags & ACT_FLAG_INACTIVE)){
			if((walk2->blk_x == x) && (walk2->blk_y == y)){
				zop_signal_event(&actor_progs[i], ZOP_EVT_TALK);
				return TRUE;
			}
		}

		walk2++;
	}

	return FALSE;
}

void actor_move(num)
uint num;
{
	register walker *walk;
	register uint x, y;
	register uint prevstep;

	walk = &actor_sprites[num];

	prevstep = walk->stepcnt;

	handle_walker(walk);

	if(!num){
		actor_map_x = (walk->pos_x-152);
		actor_map_y = (walk->pos_y-104);
		clip_movement(&actor_map_x, &actor_map_y);

		if (prevstep && !(walk->stepcnt)) {
			rpg_map_search_exit(walk->blk_x, walk->blk_y);
		}
	}

	walk->pos_x &= map_coord_x_mask;
	walk->pos_y &= map_coord_y_mask;
	walk->blk_x &= map_w_mask;
	walk->blk_y &= map_h_mask;
}

void actor_draw(num)
uint num;
{
	register walker *walk;

	walk = &actor_sprites[num];
	draw_walker(walk);
}

void actor_exec_all()
{
	register uint i;
	register walker *wlk;
	register zop_prog_rec *prog;

	wlk = actor_sprites;
	prog = actor_progs;
	for(i = 0; i != MAX_ACTORS; i++){
		if(!(wlk->flags & ACT_FLAG_INACTIVE)){
			zop_exec_frame(prog);
		}
		prog++;
		wlk++;
	}
}

void actor_move_all()
{
	register uint i;
	register walker *wlk;

	wlk = actor_sprites;
	for(i = 0; i != MAX_ACTORS; i++){
		if(!(wlk->flags & ACT_FLAG_INACTIVE)){
			actor_move(i);
		}
		wlk++;
	}
}

void actor_draw_all()
{
	register uint i, n;
	register int y;
	register walker *wlk;
	uchar zorder[MAX_ACTORS], *p;
	int zcoords[MAX_ACTORS], *z;

/*	wlk = actor_sprites;
	wlk_sprnum = 1;
	for(i = 0; i != MAX_ACTORS; i++){
		if(!(wlk->flags & ACT_FLAG_INACTIVE)){
			actor_draw(i);
		}
		wlk++;
	}*/ /* Old routine, with no Z sorting */

	p   = zorder;
	z   = zcoords;
	wlk = actor_sprites;
	n   = 0;
	for(i = 0; i != MAX_ACTORS; i++){
		y = (wlk->pos_y - actor_map_y) - 16;	

		if((y > -32) && (y < 240) &&
		   !(wlk->flags & ACT_FLAG_INACTIVE)){ /* only draw the sprites if they are visible and active */
			*p = i;
			p++;

			*z = -y;
			z++;

			n++;
		}

		wlk++;
	}

	quicksort_zorder(zorder, zcoords, n);

	wlk_sprnum = 1;
	p = zorder;
	for(i = 0; i != n; i++){
		actor_draw(*p);
		p++;
	}
}
