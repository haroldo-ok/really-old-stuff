/* "Actor" routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _ACTOR_H
#define _ACTOR_H

#define MAX_ACTORS 40

extern sprite_rec actor_sprites[MAX_ACTORS];
extern uint actor_map_x;
extern uint actor_map_y;

void actor_move(num);

#endif /* _ACTOR_H */
