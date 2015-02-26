/* GemQuest - AI routines                                        */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _GEMQ_AI_H
#define _GEMQ_AI_H

#define ENEMY_FIRST 1
#define ENEMY_MAX 40
#define ENEMY_COUNT (ENEMY_MAX-ENEMY_FIRST)

#define ENEMY_TYPE_KABOOM 0
#define ENEMY_TYPE_BLADE1 1
#define ENEMY_TYPE_BLADE2 2
#define ENEMY_TYPE_SHOOT1 3
#define ENEMY_TYPE_SHOOT2 4
#define ENEMY_TYPE_ZIGGER1 5
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
} enemy_info;

extern int cos_table[];
#define COS(a) (cos_table[(a) & 0x0F]);
#define SIN(a) (cos_table[((a)+4) & 0x0F]);

#define ASHR(a, b) ((a < 0)?-((-(a)) >> (b)):((a) >> (b)))
#define ABS(a) (((a) < 0)?-(a):(a))

extern ai_rec ai_recs[];

void ai_reset();
void ai_handle();
void ai_reset_enemy(ai);
uint ai_spawn_enemy(x, y, type);

#endif /* _GEMQ_AI_H */
