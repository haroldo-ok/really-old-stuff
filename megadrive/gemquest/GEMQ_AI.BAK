#include "genesis.h"
#include "sprhand.h"
#include "actor.h"
#include "gemquest.h"
#include "shot.h"
#include "gemq_ai.h"

ai_rec ai_recs[ENEMY_COUNT];

enemy_info enminfo[] = {
{16, 768, 2, 0x800},
{1, 832, 0, 0x200},
{1, 832, 2, 0x400},
{1, 896, 0, 0x150},
{1, 896, 2, 0x300},
{1, 960, 0, 0x400},
{1, 960, 2, 0x600}
};

int cos_table[]={
	256,
	237,
	181,
	98,
	0,
	-98,
	-181,
	-237,
	-256,
	-237,
	-181,
	-98,
	0,
	98,
	181,
	237
};

void ai_reset()
{
	register ai_rec     *p;	
	register sprite_rec *spr;
	register uint       i;

	p   = ai_recs;
	spr = &actor_sprites[ENEMY_FIRST];
	for (i = 0; i != ENEMY_COUNT; i++) {
		ai_reset_enemy(p);
		p++;

		spr->posy = -32;
		spr++;
	}
}

void ai_accelerate(ai, dir, speed)
register ai_rec *ai;
register uint	dir;
register int	speed;
{
	dir >>= 4;

	ai->accelx = speed * COS(dir);
	ai->accelx = ASHR(ai->accelx, 8);

	ai->accely = speed * SIN(dir);
	ai->accely = ASHR(ai->accely, 8);
}

void ai_accelerate_towards(ai, spr, x, y, spd)
register ai_rec     *ai;
register sprite_rec *spr;
register int x;
register int y;
register int spd;
{
	/* Note that, in this routine, I traded precision for speed */
	register uint absx, absy;

	x -= spr->posx;
	y -= spr->posy;

	absx = ABS(x);
	absy = ABS(y);

	if(absx < ASHR(absy, 1)) {
		x = 0;
	}
	if(absy < ASHR(absx, 1)) {
		y = 0;
	}

	ai->accelx = 0;
	ai->accely = 0;

	if(x){
		if(x < 0) {
			ai->accelx = -spd;
		} else {
			ai->accelx = spd;
		}
	}

	if(y){
		if(y < 0) {
			ai->accely = -spd;
		} else {
			ai->accely = spd;
		}
	}
}

uint ai_check_shot(ai, spr)
register ai_rec     *ai;
register sprite_rec *spr;
{
	if(shot_at(spr->posx, spr->posy, spr->posx+16, spr->posy+16, 2)) {
		ai->life--;
	}

	if(!ai->life) {
		score += 10 + (((ai->type) * level) >> 1);
		ai_spawn_enemy(spr->posx, spr->posy, ENEMY_TYPE_KABOOM);
		play_GFS_sound("EXPLODE2.SND");
		return TRUE;
	}

	return FALSE;
}

uint ai_check_collision(ai, spr)
register ai_rec     *ai;
register sprite_rec *spr;
{
	if((spr->posx+15 > player->posx+4) && (spr->posx < player->posx+19) &&
       (spr->posy+15 > player->posy+4) && (spr->posy < player->posy+19)) {
		ai->life = 0;
		kill_player();
	}

	if(!ai->life) {
		ai_spawn_enemy(spr->posx, spr->posy, ENEMY_TYPE_KABOOM);
		return TRUE;
	}

	return FALSE;
}

void ai_handle()
{
	register sprite_rec *spr;
	register ai_rec     *ai;
	register uint		i;
	uint				temp;

	ai  = ai_recs;
	spr = &actor_sprites[ENEMY_FIRST];
	for (i = ENEMY_FIRST; i != ENEMY_MAX; i++) {
		if(ai->life){
			switch(ai->type){
				case ENEMY_TYPE_KABOOM:
					ai->life--;
				break;

				case ENEMY_TYPE_BLADE1:
				case ENEMY_TYPE_BLADE2:
					if(!(ai->counters[0])){
						if(ai->type != ENEMY_TYPE_BLADE2) {
							temp = 10;
						} else {
							temp = 3;
						}

						if(random(temp)) {
							ai_accelerate(ai, random(256), 0x30+random(0x20));
						} else {
							ai_accelerate_towards(ai, spr, actor_sprites->posx, actor_sprites->posy, 0x50);
						}

						ai->counters[0] = (7*temp) + random(70);
					} else {
						(ai->counters[0])--;
					}
					ai_check_collision(ai, spr);
					ai_check_shot(ai, spr);
				break;

				case ENEMY_TYPE_SHOOT1:
				case ENEMY_TYPE_SHOOT2:
					if(!(ai->counters[0])){
						if(random(10)) {
							ai_accelerate(ai, random(256), 0x20+random(0x20));
						} else {
							ai_accelerate_towards(ai, spr, actor_sprites->posx, actor_sprites->posy, 0x20);
						}

						ai->counters[0] = 70 + random(70);
					} else {
						(ai->counters[0])--;
					}

					if(!(ai->counters[1])){
						shot_shoot(spr->posx+6, spr->posy+6, 
		               			   8, random(256), 0x400, BUILD_ATTR(1,0,0,0)|242, 2);

						if(ai->type != ENEMY_TYPE_SHOOT2) {
							temp = 40;
						} else {
							temp = 15;
						}
						ai->counters[1] = temp + random(temp);
					} else {
						(ai->counters[1])--;
					}

					ai_check_collision(ai, spr);
					ai_check_shot(ai, spr);
				break;

				case ENEMY_TYPE_ZIGGER1:
				case ENEMY_TYPE_ZIGGER2:
					if(!(ai->counters[0])){
						if(ai->type != ENEMY_TYPE_ZIGGER2) {
							temp = 20;
						} else {
							temp = 10;
						}

						if(random(temp)) {
							ai_accelerate(ai, random(8) << 5, 0x200);
						} else {
							ai_accelerate_towards(ai, spr, actor_sprites->posx, actor_sprites->posy, 0x200);
						}

						if(ai->type != ENEMY_TYPE_ZIGGER2) {
							temp = 70;
						} else {
							temp = 30;
						}
						ai->counters[1] = temp + random(temp);
					} else {
						(ai->counters[0])--;
					}

					ai_check_collision(ai, spr);
					ai_check_shot(ai, spr);
				break;
			}

			/* accelerates */
			spr->xaccel += ai->accelx;
			spr->yaccel += ai->accely;

			/* Checks collision with borders */
			if(spr->posx < 16) {
				spr->posx = 16;
				spr->xaccel = -spr->xaccel;
				ai->accelx  = -ai->accelx;
		 	} else if(spr->posx > (PLAYFIELD_WIDTH-40)) {
				spr->posx = (PLAYFIELD_WIDTH-40);
				spr->xaccel = -spr->xaccel;
				ai->accelx  = -ai->accelx;
			}

			if(spr->posy < 16) {
				spr->posy = 16;
				spr->yaccel = -spr->yaccel;
				ai->accely  = -ai->accely;
			} else if(spr->posy > (PLAYFIELD_HEIGHT-40)) {
				spr->posy = (PLAYFIELD_HEIGHT-40);
				spr->yaccel = -spr->yaccel;
				ai->accely  = -ai->accely;
			}
		} else {
/*			spr->posx = -64;*/
			spr->posy = -64;
		}

		ai++;
		spr++;
	}
}

void ai_reset_enemy(ai)
register ai_rec *ai;
{
	uint i;

	ai->life = 0;
	ai->type = 0;
	
	for(i = 0; i != 4; i++){
		ai->counters[i] = 0;
	}

	ai->accelx = 0;
	ai->accely = 0;
}

uint ai_spawn_enemy(x, y, type)
int x;
int y;
uint type;
{
	register uint       num;
	register sprite_rec *spr;
	register ai_rec     *ai;
	enemy_info *info;

	info = &enminfo[type];

	ai  = ai_recs;
	spr = &actor_sprites[ENEMY_FIRST];
	for(num = ENEMY_FIRST; (num != ENEMY_MAX) && (ai->life); num++){
		ai++;
		spr++;
	}
	if(num == ENEMY_MAX){
		return 0;
	}

	sprite_init(spr, num+1, x, y, 0x500, BUILD_ATTR(info->palnum,0,0,0)|info->tilenum, 4);
	spr->frm_cnt = 16;
	spr->frm_spd = 0xFFL;
	spr->xfric   = 0x08;
	spr->yfric   = 0x08;
	spr->xmaxac  = info->maxac;
	spr->ymaxac  = info->maxac;

	ai->type = type;
	ai->life = info->life;
	switch(type){
		case ENEMY_TYPE_BLADE1:
		
		break;
	}

	return num;
}
