#include "genesis.h"
#include "sprhand.h"
#include "actor.h"
#include "timelord.h"
#include "psgsound.h"
#include "shot.h"
#include "ai.h"

uint ai_sync;

ai_rec ai_recs[ENEMY_COUNT];

ai_checkpoint saucer_checkpoints[MAX_CHKS];
uint saucers_cnt;
uint saucers_deployed;
uint saucers_shoot;

enemy_info enminfo[] = {
{16, 400, 2, 0x800, 0x500, 4},
{1, 512, 2, 0x400, 0x500, 4},
{1, 768, 3, 0x400, 0xF00, 16},
{1, 576, 2, 0x400, 0x500, 4},
{1, 640, 2, 0x200, 0x500, 4},
{1, 704, 1, 0x400, 0x500, 4},
{1, 960, 2, 0x600, 0x500, 4}
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

uint snd_saucer1[] = {
   SET_VOLX+8,
   SET_TONEX+400,
   SET_TONEX+300,
   SET_TONEX+200,
   SET_TONEX+100,
   SET_TONEX+200,
   SET_TONEX+300,
   DELAY+70,
   SET_VOLX+0,
   END_SOUND
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

	saucers_cnt      = MAX_SAUCERS;
	saucers_deployed = FALSE;
	saucers_shoot    = 16;

	ai_sync = 0;
}

void ai_accelerate(ai, dir, speed)
register ai_rec *ai;
register uint	dir;
register int	speed;
{
	long tmp;

	dir >>= 4;

	tmp        = (long)speed * COS(dir);
	ai->accelx = ASHR(tmp, 8);

	tmp        = (long)speed * SIN(dir);
	ai->accely = ASHR(tmp, 8);
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

uint get_bearing(x, y)
register int x;
register int y;
{
	register int dir;
	register int absx, absy;

	absx = ABS(x);
	absy = ABS(y);

	dir = 0;

	if (absx >= (absy+(absy >> 1))) {
		if (x < 0) {
			dir = 4;
		} else {
			dir = 0;
		}
	} else if (absy >= (absx+(absx >> 1))) {
		if (y < 0) {
			dir = 2;
		} else {
			dir = 6;
		}
	} else {
		if (y < 0) {
			if (x < 0) {
				dir = 3;
			} else {
				dir = 1;
			}
		} else {
			if (x < 0) {
				dir = 5;
			} else {
				dir = 7;
			}
		}
	}

	return dir;
}

void ai_checkpoint_mark(num, ai, spr) 
register uint          num;
register ai_rec        *ai;
register sprite_rec    *spr;
{
	register ai_checkpoint *chk = (saucer_checkpoints+num);

	chk->accelx = ai->accelx;
	chk->accely = ai->accely;
	chk->posx   = spr->posx;
	chk->posy   = spr->posy;
	chk->xspd   = spr->xspd;
	chk->xaccel = spr->xaccel;
	chk->yspd   = spr->yspd;
	chk->yaccel = spr->yaccel;	
}

void ai_checkpoint_retrieve(num, ai, spr) 
register uint          num;
register ai_rec        *ai;
register sprite_rec    *spr;
{
	register ai_checkpoint *chk = (saucer_checkpoints+num);

	ai->accelx  = chk->accelx;
	ai->accely  = chk->accely;
	spr->posx   = chk->posx;
	spr->posy   = chk->posy;
	spr->xspd   = chk->xspd;
	spr->xaccel = chk->xaccel;
	spr->yspd   = chk->yspd;
	spr->yaccel = chk->yaccel;	
}
				
void ai_saucer_new_leader()
{
	register ai_rec     *ai, *chosen_ai;
	register uint		i, min;

	min       = 1000;
	chosen_ai = NULL;

	ai = ai_recs;
	for (i = ENEMY_FIRST; i != ENEMY_MAX; i++) {
		if(ai->life) {
			if ((ai->type == ENEMY_TYPE_SAUCER) &&
                (ai->counters[3] < min)) {
				min       = ai->counters[3];
				chosen_ai = ai;
			}
		}
		ai++;
	}

	if (chosen_ai != NULL) {
		chosen_ai->counters[3] = 0;
	}
}

void ai_handle()
{
	register sprite_rec *spr;
	register ai_rec     *ai;
	register uint		i;
	uint				temp;
	uint				maxy;
	uint                checkborders;

	ai  = ai_recs;
	spr = &actor_sprites[ENEMY_FIRST];
	for (i = ENEMY_FIRST; i != ENEMY_MAX; i++) {
		if(ai->life){
			maxy = 224-16;
			checkborders = FALSE;

			switch(ai->type){
				case ENEMY_TYPE_KABOOM:
					ai->life--;
					checkborders = TRUE;
				break;

				case ENEMY_TYPE_SAUCER:
					if (!ai->counters[3]) {
						if(!(ai_sync&0x07)){
							start_sound(2, snd_saucer1);
						}
					}
					if (!(ai_sync & 0x03)) {
						if (!ai->counters[3]) {
							if (!random(5))	{
								ai_accelerate(ai, random(256), 0x0F0 + (level << 5));
								ai->accelx += ASHR(ai->accelx, 1); /* Boosts horizontal movement */
							}
							ai_checkpoint_mark(ai->counters[0], ai, spr);
							if (saucers_deployed && saucers_shoot) {
								saucers_shoot--;
							}
						} else {
							ai_checkpoint_retrieve(ai->counters[0], ai, spr);
						} 

						if ((!ai->counters[2]) &&
							((ai->counters[3] != (MAX_SAUCERS-1))) &&                            
							(ai->counters[0] == SAUCER_CHKS)) {
							ai->counters[2] = ai->counters[3] + 1;

							temp = ai_spawn_enemy(spr->posx, spr->posy, ai->type);							
							ai_checkpoint_retrieve(ai->counters[0]-SAUCER_CHKS, 
                                                   ai_recs + (temp-ENEMY_FIRST),
												   actor_sprites + temp);
							ai_recs[temp-ENEMY_FIRST].counters[3] = ai->counters[2];
							if (ai->counters[2] == (MAX_SAUCERS-1)) {
								saucers_deployed = TRUE;
							}
						}

						if ((!saucers_shoot) && (!random(saucers_cnt))) {
							temp = (level >> 1) + 1;
							if (temp > 3) {
								temp = 3;
							}
							ai_spawn_enemy(spr->posx, spr->posy+8, ENEMY_TYPE_MISSILE+random(temp));
							if (level < 15) {
								saucers_shoot = 20 - level;
							} else {
								saucers_shoot = 5;
							}
						}

						ai->counters[0]++;
						if (ai->counters[0] == MAX_CHKS) {
							ai->counters[0] = 0;
						}
					}

/*					spr->stance = get_bearing(ai->accelx, ai->accely) << 5;*/

					ai_check_collision(ai, spr);
					if (ai_check_shot(ai, spr)) {
						saucers_cnt--;
						ai_saucer_new_leader();
					}

					checkborders = TRUE;
					maxy = 140;
				break;

				case ENEMY_TYPE_MISSILE:
					if (spr->posy > 224) {
						ai->life = 0;
					}
					ai_check_collision(ai, spr);
					ai_check_shot(ai, spr);
					
					spr->xaccel = 0x00;		
					spr->yaccel = 0x1FF;		
				break;

				case ENEMY_TYPE_GUIDED:
					if (spr->posy > 224) {
						ai->life = 0;
					}
					ai_check_collision(ai, spr);
					ai_check_shot(ai, spr);
					
					if (spr->posx < player->posx) {
						ai->accelx = 0x00F;
					} else {
						ai->accelx = -0x00F;
					}

					spr->yaccel = 0x100;		
				break;

				case ENEMY_TYPE_TRACER:
					if (spr->posy > 200) {
						if (spr->posx < player->posx) {
							ai->accelx = 0x00F;
						} else {
							ai->accelx = -0x00F;
						}

						if (!(ai->counters[0])) {
							ai->life = 0;
						} else {
							ai->counters[0]--;
						}

						spr->yaccel = 0x00;		
					} else {
						spr->yaccel = 0x100;		
					}
					ai_check_collision(ai, spr);
					ai_check_shot(ai, spr);				
				break;
			}

			/* accelerates */
			spr->xaccel += ai->accelx;
			spr->yaccel += ai->accely;

			/* Checks collision with borders */
			if (checkborders) {
				if(spr->posx < 0) {
					spr->posx = 0;
					spr->xaccel = -spr->xaccel;
					ai->accelx  = -ai->accelx;
			 	} else if(spr->posx > (320-16)) {
					spr->posx = (320-16);
					spr->xaccel = -spr->xaccel;
					ai->accelx  = -ai->accelx;
				}

				if(spr->posy < 0) {
					spr->posy = 0;
					spr->yaccel = -spr->yaccel;
					ai->accely  = -ai->accely;
				} else if(spr->posy > maxy) {
					spr->posy = maxy;
					spr->yaccel = -spr->yaccel;
					ai->accely  = -ai->accely;
				}
			}
		} else {
/*			spr->posx = -64;*/
			spr->posy = -64;
		}

		ai++;
		spr++;
	}

	ai_sync++;
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

	sprite_init(spr, num+1, x, y, info->size, BUILD_ATTR(info->palnum,0,0,0)|info->tilenum, info->tilecnt);
	spr->frm_cnt = 16;
	spr->frm_spd = 0xFFL;
	spr->xfric   = 0x08;
	spr->yfric   = 0x08;
	spr->xmaxac  = info->maxac;
	spr->ymaxac  = info->maxac;

	ai->type   = type;
	ai->life   = info->life;
	ai->accelx = 0;
	ai->accely = 0;
	switch(type){
		case ENEMY_TYPE_SAUCER:
			spr->xmaxac += level << 7;
			spr->ymaxac += level << 7;
		break;

		case ENEMY_TYPE_MISSILE:
			spr->yfric  = 0x00;
			spr->xaccel = 0x00;		
			spr->yaccel = 0x1FF;		
		break;

		case ENEMY_TYPE_GUIDED:
			spr->yfric  = 0x00;
			spr->xaccel = 0x00;		
			spr->yaccel = 0x100;		
		break;

		case ENEMY_TYPE_TRACER:
			spr->yfric  = 0x00;
			spr->xaccel = 0x00;		
			spr->yaccel = 0x1FF;		
			ai->counters[0] = 80;
		break;
	}

	return num;
}
