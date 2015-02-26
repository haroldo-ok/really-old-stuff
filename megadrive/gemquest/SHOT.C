#include "genesis.h"
#include "sprhand.h"
#include "actor.h"
#include "gemq_ai.h"
#include "gemquest.h"
#include "shot.h"

shot_rec shots[SHOT_MAX];
uint	 curr_shot_num;

void shot_reset()
{
	register uint i;
	
	for(i = 0; i != SHOT_MAX; i++) {
		shots[i].tile = 0;
	}
	curr_shot_num = 0;
}

void shot_move()
{
	register uint     i;
	register shot_rec *shot;

	shot = shots;
	for(i = SHOT_MAX; i; i--) {
		if(shot->tile) {
			/* horizontal movement */
			shot->xstep += shot->xspd;
			shot->x     += (char)((shot->xstep) >> 8);
			shot->xstep &= 0xFF;

			/* vertical movement */
			shot->ystep += shot->yspd;
			shot->y     += (char)((shot->ystep) >> 8);
			shot->ystep &= 0xFF;

			/* checks if it left the screen */
			if((shot->x < 16) || (shot->x > (PLAYFIELD_WIDTH -24)) ||
               (shot->y < 16) || (shot->y > (PLAYFIELD_HEIGHT-24))) {
				shot->tile = 0;
			}
		}
		shot++;
	}
}

/* Draws the shots, with smart flicker */
void shot_draw()
{
	register uint     i, spr;
	register shot_rec *shot;
	register int	  x, y;

	if(curr_shot_num >= SHOT_MAX){
		curr_shot_num = 0;
	}
	shot = &shots[curr_shot_num];

	for(i = SHOT_MAX, spr = SHOT_SPR_FIRST; i && (spr != (SHOT_SPR_MAX+1)); i--) {
		if(shot->tile) {
			x = shot->x - sprite_offs_x;
			y = shot->y - sprite_offs_y;
			if((x > -32) && (x < 352) &&
               (y > -32) && (y < 272)    ) {
				def_sprite(spr, x, y, 0x00, shot->tile);
				spr++;
			}
		}

		shot++;
		curr_shot_num++;
		if(curr_shot_num == SHOT_MAX){
			curr_shot_num = 0;
			shot = shots;
		}
	}

	while(spr != (SHOT_SPR_MAX+1)) {
		def_sprite(spr, -32, -32, 0x00, 0);
		spr++;
	}
}

uint shot_shoot(x, y, len, dir, spd, tile, group)
int  x, y;
uint len;
uint dir;
int spd;
uint tile;
uint group;
{
	register uint     i;
	register shot_rec *shot;
	register long	  tmp;

	shot = shots;

	/* Searches for a free slot */
	for(i = SHOT_MAX; i && shot->tile; i--) {
		shot++;
	}
	if(!i) {
		return FALSE;
	}

	/* Shoots it */
	dir >>= 4;

	shot->tile  = tile;
	shot->group = group;

	shot->x =  len*COS(dir);
	shot->x =  ASHR(shot->x, 8);
	shot->x += x;

	shot->y =  len*SIN(dir);
	shot->y =  ASHR(shot->y, 8);
	shot->y += y;

	shot->xstep = 0;
	shot->ystep = 0;
	tmp         = spd*(long)COS(dir);
	shot->xspd  = ASHR(tmp, 8);
	tmp         = spd*(long)SIN(dir);
	shot->yspd  = ASHR(tmp, 8);

	return TRUE;
}

uint shot_at(x1, y1, x2, y2, exclude)
register uint x1, y1;
register uint x2, y2;
register uint exclude;
{
	register uint     i;
	register shot_rec *shot;

	shot = shots;

	x1 -= 4;
	x2 -= 4;
	y1 -= 4;
	y2 -= 4;

	for(i = SHOT_MAX; i; i--) {
		if((shot->tile) && (shot->group != exclude) &&
           (shot->x > x1) && (shot->x < x2) &&
		   (shot->y > y1) && (shot->y < y2)            ) {
			return (shot->group);
		}
		shot++;
	}

	return 0;
}