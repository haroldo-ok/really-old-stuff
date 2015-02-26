/* "Actor" routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "rpgmap.h"
#include "sprhand.h"
#include "actor.h"

sprite_rec actor_sprites[MAX_ACTORS];

uint actor_map_x;
uint actor_map_y;

void actor_move(num)
uint num;
{
	register sprite_rec *sprite;
	int oldx, oldy;
	register uint x, y;

	sprite = &actor_sprites[num];

	oldx = sprite->posx;
	oldy = sprite->posy;

	sprite_move(sprite);

/*
	x = (sprite->posx + actor_map_x) & map_coord_x_mask;
	y = (sprite->posy + actor_map_y) & map_coord_y_mask;
*/
	x = sprite->posx;
	y = sprite->posy;

/*
	if((rpg_map_get_block(((x     ) >> 4) & map_w_mask, ((y     ) >> 4) & map_h_mask) > 3) ||
       (rpg_map_get_block(((x + 15) >> 4) & map_w_mask, ((y     ) >> 4) & map_h_mask) > 3) ||
       (rpg_map_get_block(((x     ) >> 4) & map_w_mask, ((y + 15) >> 4) & map_h_mask) > 3) ||
       (rpg_map_get_block(((x + 15) >> 4) & map_w_mask, ((y + 15) >> 4) & map_h_mask) > 3)    ){
		sprite->posx = oldx;
		sprite->posy = oldy;
	}
*/

/*
	if(!num){
		actor_map_x += (sprite->posx-152);
		actor_map_y += (sprite->posy-104);

		actor_map_x &= map_coord_x_mask;
		actor_map_y &= map_coord_y_mask;

		sprite->posx = 152;
		sprite->posy = 104;
	}
*/
}
