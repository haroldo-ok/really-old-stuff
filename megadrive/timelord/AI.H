/* GemQuest - AI routines                                        */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _AI_H
#define _AI_H

#define ENEMY_FIRST 1
#define ENEMY_MAX 30
#define ENEMY_COUNT (ENEMY_MAX-ENEMY_FIRST)

#define MAX_SAUCERS 8
#define SAUCER_CHKS 1
#define MAX_CHKS (MAX_SAUCERS*SAUCER_CHKS)

#define ENEMY_TYPE_KABOOM 0
#define ENEMY_TYPE_SAUCER 1
#define ENEMY_TYPE_VORTEX 2
#define ENEMY_TYPE_MISSILE 3
#define ENEMY_TYPE_GUIDED 4
#define ENEMY_TYPE_TRACER 5
#define ENEMY_TYPE_ZIGGER2 6

typedef struct{
	uint life;
	uint type;
	uint counters[4];
	int  accelx;
	int  accely;
} ai_rec;

typedef struct{
	uint life;
	uint tilenum;
	uint palnum;
	uint maxac;
	uint size;
	uint tilecnt;
} enemy_info;

typedef struct{
	int accelx;
	int accely;
	int posx;
	int posy;
	int xspd;
	int xaccel;
	int yspd;
	int yaccel;
} ai_checkpoint;

extern int cos_table[];
#define COS(a) (cos_table[(a) & 0x0F]);
#define SIN(a) (cos_table[((a)+4) & 0x0F]);

#define ASHR(a, b) ((a < 0)?-((-(a)) >> (b)):((a) >> (b)))
#define ABS(a) (((a) < 0)?-(a):(a))

extern ai_rec ai_recs[];
extern uint saucers_cnt;
extern uint saucers_deployed;

void ai_reset();
void ai_handle();
void ai_reset_enemy(ai);
uint ai_spawn_enemy(x, y, type);

#endif /* _AI_H */
