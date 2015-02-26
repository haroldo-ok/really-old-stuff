/* Sega Genesis moving sprite handler                            */
/* by Haroldo O. Pinheiro                                        */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#ifndef _INC_SPRHAND_

typedef struct{
	uint number;
	int  posx;
	int  posy;
	uint size;
	uint from;

	uint tilcnt;

	uint stance;
	int  frame;
	int  frm_ctrl;
	int  frm_spd;
	uint frm_cnt;

	int xspd;
	int xaccel;
	int xfric;
	int xgrav;
	int xmaxac;
	int yspd;
	int yaccel;
	int yfric;
	int ygrav;
	int ymaxac;
} sprite_rec;

extern unsigned char huge_buffer[];
extern int sprite_offs_x;
extern int sprite_offs_y;

void sprite_init(sprite, number, posx, posy, size, from, tcnt);
void sprite_move(sprite);
void sprite_draw(sprite);
void sprite_prepare();

void tileset_load_RDC(fname, basetile, tilecnt);

#define _INC_SPRHAND_

#endif
