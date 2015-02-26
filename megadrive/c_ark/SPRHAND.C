
#include "genesis.h"
#include "sprhand.h"

unsigned char huge_buffer[0x8C00]; /* 35k */

void sprite_init(sprite, number, posx, posy, size, from, tcnt)
sprite_rec *sprite;
uint number;
int  posx;
int  posy;
uint size;
uint from;
uint tcnt;
{
	sprite->number = number;
	sprite->posx   = posx;
	sprite->posy   = posy;
	sprite->size   = size;
	sprite->from   = from;
	sprite->tilcnt = tcnt;

	sprite->stance   = 0;
	sprite->frame    = 0;
	sprite->frm_ctrl = 0;
	sprite->frm_spd  = 0;
	sprite->frm_cnt  = 1;

	sprite->xspd   = 0;
	sprite->xaccel = 0;
	sprite->xfric  = 0;
	sprite->xgrav  = 0;
	sprite->xmaxac = 0;
	sprite->yspd   = 0;
	sprite->yaccel = 0;
	sprite->yfric  = 0;
	sprite->ygrav  = 0;
	sprite->ymaxac = 0;
}

void sprite_move(sprite)
register sprite_rec *sprite;
{
	register int n;

	/* animation */
	sprite->frm_ctrl += sprite->frm_spd;
	n = sprite->frame - (char)((sprite->frm_ctrl) >> 8);
	if(sprite->frm_cnt){
		while(n < 0){
			n += sprite->frm_cnt;
    	}
		while(n >= sprite->frm_cnt){
			n -= sprite->frm_cnt;
    	}
	}
	sprite->frame = n;
	sprite->frm_ctrl &= 0xFF;

	/* "gravity" */
	sprite->xaccel += sprite->xgrav;
	sprite->yaccel += sprite->ygrav;

	/* speed limiting */
	if(sprite->xmaxac && sprite->xaccel){
		n = sprite->xaccel;
		if(n > sprite->xmaxac){
			n = sprite->xmaxac;
		}else if(n < -sprite->xmaxac){
			n = -sprite->xmaxac;
		}
		sprite->xaccel = n;
	}
	if(sprite->ymaxac && sprite->yaccel){
		n = sprite->yaccel;
		if(n > sprite->ymaxac){
			n = sprite->ymaxac;
		}else if(n < -sprite->ymaxac){
			n = -sprite->ymaxac;
		}
		sprite->yaccel = n;
	}

	/* "friction" */
	if(sprite->xfric && sprite->xaccel){
		n = sprite->xaccel;
		if(n < 0){
			n += sprite->xfric;
			if(n > 0){
				n = 0;
			}
		}else if (n > 0){
			n -= sprite->xfric;
			if(n < 0){
				n = 0;
			}
		}
		sprite->xaccel = n;
	}
	if(sprite->yfric && sprite->yaccel){
		n = sprite->yaccel;
		if(n < 0){
			n += sprite->yfric;
			if(n > 0){
				n = 0;
			}
		}else if (n > 0){
			n -= sprite->yfric;
			if(n < 0){
				n = 0;
			}
		}
		sprite->yaccel = n;
	}

	/* horizontal movement */
	sprite->xspd += sprite->xaccel;
	sprite->posx += (char)((sprite->xspd) >> 8);
	sprite->xspd &= 0xFF;

	/* vertical movement */
	sprite->yspd += sprite->yaccel;
	sprite->posy += (char)((sprite->yspd) >> 8);
	sprite->yspd &= 0xFF;
}

void sprite_draw(sprite)
register sprite_rec *sprite;
{
	def_sprite(sprite->number, 
               sprite->posx,
			   sprite->posy,
			   sprite->size,
			   sprite->from+sprite->stance+(sprite->frame*sprite->tilcnt));
}

void sprite_prepare()
{
	register uint i;

	for(i = 1; i != 80; i++){	
		def_sprite(i, -16, -16, 0, 0);
	}
}

void tileset_load_RDC(fname, basetile, tilecnt)
char *fname;
uint basetile;
uint tilecnt;
{
    ulong faddr, fsize;
	
	get_GFS_file(&faddr, &fsize, fname);
	RDC_Decompress(faddr, huge_buffer);
	set_bkg_data(basetile,tilecnt,huge_buffer);
}
