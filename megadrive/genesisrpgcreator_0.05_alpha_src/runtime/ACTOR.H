/* "Actor" routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _ACTOR_H
#define _ACTOR_H

#define MAX_ACTORS 64

#define ACT_FLAG_INACTIVE 0x0001U

extern walker actor_sprites[MAX_ACTORS];
extern zop_prog_rec actor_progs[MAX_ACTORS];
extern int actor_map_x;
extern int actor_map_y;

void actor_init_all();

uchar actor_walk(num, direction);
void actor_move(num);
void actor_draw(num);

uchar actor_talk(num);

void actor_exec_all();
void actor_move_all();
void actor_draw_all();

#endif /* _ACTOR_H */
