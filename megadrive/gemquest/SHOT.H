/* Shot handling routines                                        */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _SHOT_H
#define _SHOT_H

#define SHOT_MAX 120
#define SHOT_SPR_FIRST 41
#define SHOT_SPR_MAX 80
#define SHOT_SPR_CNT (SHOT_SPR_MAX-SHOT_SPR_FIRST+1)

typedef struct{
	uint tile;
	uint group;
	int x, y;
	int xstep, ystep;
	int xspd, yspd;
} shot_rec;

void shot_reset();
void shot_move();
void shot_draw();
uint shot_shoot(x, y, len, dir, spd, tile, group);
uint shot_at(x1, y1, x2, y2, exclude);

#endif /* _SHOT_H */
