/* Roguelike random map Generator                                */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* partly inspired by Thomas Biskup's QHack source code          */
/* (I didn't actually use his source, but it did give me ideas.) */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "rdctile.h"
#include "rpgmap.h"
#include "randmap.h"

randmap_room randmap_rooms[RANDMAP_ROOM_COUNT];

uint randmap_room_order[RANDMAP_ROOM_COUNT];

void randmap_reorder_rooms()
{
	register uint i, j, k;
	register uint n;

	for(i = 0; i != RANDMAP_ROOM_COUNT; i++){
		randmap_room_order[i] = i;
	}

	for(i = RANDMAP_ROOM_COUNT; i; i--){
		j = random(RANDMAP_ROOM_COUNT);
		k = random(RANDMAP_ROOM_COUNT);

		n = randmap_room_order[j];
		randmap_room_order[j] = randmap_room_order[k];
		randmap_room_order[k] = n;
	}
}

void randmap_link_rooms(rooma, roomb)
register randmap_room *rooma;
register randmap_room *roomb;
{
	register uint x1, y1;
	register uint x2, y2;
	register uint xm, ym;

	x1 = rooma->left + 1 + random(rooma->width  - 2);
	y1 = rooma->top  + 1 + random(rooma->height - 2);
	x2 = roomb->left + 1 + random(roomb->width  - 2);
	y2 = roomb->top  + 1 + random(roomb->height - 2);

/*	if((((x1-x2) & map_w_mask) < ((x2-x1) & map_w_mask)) ||
	   (((y1-y2) & map_h_mask) < ((y2-y1) & map_h_mask))    ){
		xm = x1;
		x1 = x2;
		x2 = xm;

		ym = y1;
		y1 = y2;
		y2 = ym;
	}*/

	xm = (x1+x2) >> 1;
	ym = (y1+y2) >> 1;

	if(random(2)){
		while((x1 != x2) || (y1 != y2)){
			while(x1 != xm){
				if(rpg_map_get_block(x1, y1)){
					rpg_map_set_block(x1, y1, 1);
				}
	
				x1++;
				x1 &= map_w_mask;
			}

			while(y1 != ym){
				if(rpg_map_get_block(x1, y1)){
					rpg_map_set_block(x1, y1, 1);
				}

	
				y1++;
				y1 &= map_h_mask;
			}

			xm = x2;
			ym = y2;
		}
	}else{
		while((x1 != x2) || (y1 != y2)){
			while(x1 != xm){
				if(rpg_map_get_block(x1, y1)){
					rpg_map_set_block(x1, y1, 1);
				}
	
				x1++;
				x1 &= map_w_mask;
			}

			while(y1 != ym){
				if(rpg_map_get_block(x1, y1)){
					rpg_map_set_block(x1, y1, 1);
				}

	
				y1++;
				y1 &= map_h_mask;
			}

			xm = x2;
			ym = y2;
		}
	}
}

void randmap_build()
{
	register uint i, j;
	register randmap_room *room, *room2;
	register uint room_max_w, room_max_h;
	register uint x, y;

	room_max_w = map_w / RANDMAP_ROOM_CNT_X;
	room_max_h = map_h / RANDMAP_ROOM_CNT_Y;

	rpg_map_draw_rectangle(0, 0, map_w-1, map_h-1, 8);

	x = 0;
	y = 0;
	room = randmap_rooms;
	
	for(i = 0; i != RANDMAP_ROOM_CNT_Y; i++){
		x = 0;
		for(j = 0; j != RANDMAP_ROOM_CNT_X; j++){
			room->left = random(room_max_w-RANDMAP_ROOM_MIN_W-2) + 1;
			room->top  = random(room_max_h-RANDMAP_ROOM_MIN_H-2) + 1;

			room->width  = random(room_max_w - room->left - RANDMAP_ROOM_MIN_W) + RANDMAP_ROOM_MIN_W;
			room->height = random(room_max_h - room->top  - RANDMAP_ROOM_MIN_H) + RANDMAP_ROOM_MIN_H;

			room->left += x;
			room->top  += y;

			rpg_map_draw_rectangle(room->left - 1, 
								   room->top  - 1, 
								   room->left + room->width, 
								   room->top  + room->height, 
								   4);

			rpg_map_draw_rectangle(room->left, 
								   room->top, 
								   room->left + room->width  - 1, 
								   room->top  + room->height - 1, 
								   0);

			x += room_max_w;
	
			room++;
		}
		
		y += room_max_h;
	}

	randmap_reorder_rooms();

	room  = randmap_rooms;
	room2 = room+1;
	for(i = RANDMAP_ROOM_COUNT-1; i; i--){
		randmap_link_rooms(room, room2);

		room++;
		room2++;
	}

	room  = randmap_rooms;
	map_x = room->left + (room->width  >> 1);
	map_y = room->top  + (room->height >> 1);
}