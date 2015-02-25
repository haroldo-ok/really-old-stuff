/* Walking handler for RPGs                                      */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "utils.h"
#include "rpgmap.h"
#include "rpgwalk.h"

extern uint actor_map_x;
extern uint actor_map_y;

uint wlk_sprnum;

void init_walker(wlk,basetile)
walker *wlk;
uint basetile;
{
	wlk->pos_x = 0;
	wlk->pos_y = 0;

	wlk->blk_x = 0;
	wlk->blk_y = 0;

	wlk->step_x = 0;
	wlk->step_y = 1;

	wlk->stepcnt = 0;

	wlk->walkdelay = 0;
	wlk->walkdlyctrl = 0;

	wlk->facing = RWK_FC_DOWN;

	wlk->sprnum = 1;
	wlk->palnum = 1;

	wlk->basetile = basetile;
	wlk->baseframe = basetile;	
	wlk->frame = 0;

	wlk->frmctrl = 7;
	wlk->frmdly  = 7;

	wlk->flags = 0;
}

void handle_walker(wlk)
walker *wlk;
{
	if(wlk->stepcnt){
		if(!wlk->walkdlyctrl){
			wlk->pos_x += wlk->step_x;
			wlk->pos_y += wlk->step_y;

			wlk->stepcnt--;
			wlk->walkdlyctrl = wlk->walkdelay;
		}else{
			wlk->walkdlyctrl--;
		}
	}else{
		wlk->blk_x = (wlk->pos_x+8) >> 4;
		wlk->blk_y = (wlk->pos_y+8) >> 4;
	}

	if(wlk->stepcnt){
		if(!wlk->frmctrl){
			wlk->frame++;
			if(wlk->frame == 4){
				wlk->frame = 0;
			}

			wlk->frmctrl = wlk->frmdly;
		}else{
			wlk->frmctrl--;
		}
	}else{
/*		wlk->frame = 0;*/
	}
}

uint frame_step_mapping[]={
0x0000,
0x0008,
0x0000,
0x0010
};

uint frame_dir_mapping[]={
0x0048,
0x0000,
0x0018,
0x0030
};

void draw_walker(wlk)
register walker *wlk;
{
	register int x, y;

/*	x = (wlk->pos_x - actor_map_x) & map_coord_x_mask;
	y = ((wlk->pos_y - actor_map_y) & map_coord_y_mask) - 16;*/
	x = (wlk->pos_x - actor_map_x);
	y = (wlk->pos_y - actor_map_y) - 16;

	if((wlk_sprnum < 80) && 
       (x > -32) && (y > -32) &&
       (x < 320) && (y < 240)){ /* only draw the sprites if they are visible and there aren't too many sprites */
		def_sprite(wlk_sprnum,x,y,0x0700,
				   BUILD_ATTR(wlk->palnum,0,0,0)|(wlk->baseframe+frame_step_mapping[wlk->frame]));
		wlk_sprnum++;
	}
}

void walker_checkbaseframe(wlk)
walker *wlk;
{
	wlk->baseframe = wlk->basetile + frame_dir_mapping[wlk->facing];
}

void walker_walkto(wlk,direction,blockcnt)
walker *wlk;
uint direction;
uint blockcnt;
{
	switch(direction){
		case RWK_FC_UP:
			wlk->facing = direction;

			wlk->step_x = 0;
			wlk->step_y = -1;

			wlk->blk_y--;

			wlk->stepcnt = 16*blockcnt;

			walker_checkbaseframe(wlk);
		break;
		case RWK_FC_DOWN:
			wlk->facing = direction;

			wlk->step_x = 0;
			wlk->step_y = 1;

			wlk->blk_y++;

			wlk->stepcnt = 16*blockcnt;

			walker_checkbaseframe(wlk);
		break;
		case RWK_FC_LEFT:
			wlk->facing = direction;

			wlk->step_x = -1;
			wlk->step_y = 0;

			wlk->blk_x--;

			wlk->stepcnt = 16*blockcnt;

			walker_checkbaseframe(wlk);
		break;
		case RWK_FC_RIGHT:
			wlk->facing = direction;

			wlk->step_x = 1;
			wlk->step_y = 0;

			wlk->blk_x++;

			wlk->stepcnt = 16*blockcnt;

			walker_checkbaseframe(wlk);
		break;
	}
}