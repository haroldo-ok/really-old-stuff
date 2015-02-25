
/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas de desenho do playfield				 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"
#include "psgsound.h"
#include "language.h"

extern uint extWIDTH;

#ifdef NEVER
void old_draw_playfield(plf)
playfield *plf;
{
	register uint i, j, k;

	/* Desenha background */
	for(i = 0; i != plf->height; i++){
		for(j = 0; j != plf->width; j++){
			k = plf->playfield[i][j];
			if(k){
				k = (k-1) | 0x0100;
			}
			put_tile(k, BUILD_ATTR(1,0,0,0), plf->left+j, plf->top+i, APLAN);
		}
	}

	/* Desenha pe‡a */
	if(plf->pc_y != 0x7000){
		for(i = 0; i != 4; i++){
			if((int)plf->pcs_y+(int)i >= (int)plf->top){
				for(j = 0; j != 4; j++){
					k = plf->piece[i][j];
					if(k){
						k = (k-1) | 0x0100;
						put_tile(k, BUILD_ATTR(1,0,0,0), 
								 plf->left+plf->pcs_x+j,
								 plf->top+plf->pcs_y+i, 
								 APLAN);
					}
				}
			}
		}
	}
}
#endif

void draw_playfield(plf)
playfield *plf;
{
	register uint i, j, k;
    register ulong *pl;
    register uint *pw;
    register ulong l;
	uint x1,x2,y1,y2;

	if(plf->update_full_playfield){
		/* Calcula o endere‡o inicial do playfield */
	    l = APLAN + (  2 * (plf->left + ( extWIDTH*(plf->top) ) ) ); 
		/* Desenha background */
		for(i = 0; i != plf->height; i++){
		    pl = (ulong *) GFXCNTL;
	    	*pl = GFX_WRITE_ADDR(l);
		    pw = (uint *) GFXDATA;
			/* Desenha a linha */
			for(j = 0; j != plf->width; j++){
				k = plf->playfield[i][j];
				if(k){
					k = (k-1) | 0x0100;
					*pw = k | BUILD_ATTR(1,0,0,0);
				}else{
					*pw = 0x0000;
				}
			}
			l += extWIDTH+extWIDTH; /* Endere‡o da pr¢xima linha */
		}
		/* Verifica Game Over */
		if(plf->game_over&&(plf->game_over <= _GAMEOVER_DELAY)){
			i = (plf->width - strlen2(__GAME_OVER_STR(0))) >> 1;
			j = plf->top + (plf->height >> 1) - 1;
			out_text(plf->left+i,
					 j,1,APLAN,__GAME_OVER_STR(0));
			i = (plf->width - strlen2(__GAME_OVER_STR(1))) >> 1;
			j++;
			out_text(plf->left+i,
					 j,1,APLAN,__GAME_OVER_STR(1));
		}
	}else{
		if(plf->pc_y != 0x7000){
			/* Calcula o trecho que precisa ser atualizado */
			x1 = plf->pcs_x-1;
			x2 = plf->pcs_x+5;
			if((int)x1 < 0) x1 = 0;
			if((int)x2 > plf->width) x2 = plf->width;

			y1 = plf->pcs_y-2;
			y2 = plf->pcs_y+5;
			if((int)y1 < 0) y1 = 0;
			if((int)y2 > plf->height) y2 = plf->height;

			/* Calcula o endere‡o inicial do playfield */
		    l = APLAN + (  2 * ((plf->left+x1) + ( extWIDTH*(plf->top+y1) ) ) ); 
			/* Desenha somente a parte que precisa ser atualizada */
			for(i = y1; i != y2; i++){
			    pl = (ulong *) GFXCNTL;
		    	*pl = GFX_WRITE_ADDR(l);
			    pw = (uint *) GFXDATA;
				/* Desenha a linha */
				for(j = x1; j != x2; j++){
					k = plf->playfield[i][j];
					if(k){
						k = (k-1) | 0x0100;
						*pw = k | BUILD_ATTR(1,0,0,0);
					}else{
						*pw = 0x0000;
					}
				}
				l += extWIDTH+extWIDTH; /* Endere‡o da pr¢xima linha */
			}
		}
	}

	/* Desenha pe‡a */
	if(plf->pc_y != 0x7000){
		for(i = 0; i != 4; i++){
			if((int)plf->pcs_y+(int)i > 0){
				for(j = 0; j != 4; j++){
					k = plf->piece[i][j];
					if(k){
						k = (k-1) | 0x0100;
						put_tile(k, BUILD_ATTR(1,0,0,0), 
								 plf->left+plf->pcs_x+j,
								 plf->top+plf->pcs_y+i, 
								 APLAN);
					}
				}
			}
		}
	}

	/* Desenha sprites ("DOUBLE/TRIPLE/TETRIS") */
	k = ((plf->left < 20) ? 0:8); /* Sprite inicial */
	if(plf->spr_count){
		for(i = 0; i != plf->spr_count; i++){
			def_sprite( k+1+(i*2),
						plf->spr_pos_spd[i][1],plf->spr_pos_spd[i][0],
						0x800,0x2000|((256+32)+plf->spr_pos_spd[i][3]));
			def_sprite( k+2+(i*2),
						plf->spr_pos_spd[i][1]+24,plf->spr_pos_spd[i][0],
						0x800,0x2000|((256+32+3)+plf->spr_pos_spd[i][3]));

			plf->spr_pos_spd[i][0] -= (plf->spr_pos_spd[i][2] >> 3);
			plf->spr_pos_spd[i][2] += (plf->spr_pos_spd[i][2] / 5) + 1;
			if(plf->spr_pos_spd[i][2] > 256){
				plf->spr_count--;
				break;
			}
		}
		for( ; i != 4; i++){
			def_sprite(k+1+(i*2),0,-32,0,0);
			def_sprite(k+2+(i*2),0,-32,0,0);
		}
		show_sprite(k+1,k+8);
	}
}

