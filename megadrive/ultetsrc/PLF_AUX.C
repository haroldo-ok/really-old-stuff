
/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas auxiliares do playfield				 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "ultrdat.h"
#include "language.h"

extern uint extWIDTH;

extern char pieces[][4][4];

void prepare_gameover(plf)
playfield *plf;
{
	register uint i, j;

	for(i = 0; i != plf->height; i++){
		for(j = 0; j != plf->width; j++){
			if(plf->playfield[i][j]){
				plf->playfield[i][j] = _BLK_EXPLOSION;
			}
		}
	}
	plf->game_over = (uint)plf->height + _BLK_EXPLOSION_END - _BLK_EXPLOSION + _GAMEOVER_DELAY + 1;
}

extern uint Explode1[];

void detonate_bomb(X,Y,plf)
int X;
int Y;
playfield *plf;
{
	register int i,j;

	for(i = -1; i != 2; i++){
		if((Y+i >= 0)&&(Y+i < plf->height)){
			for(j = -1; j != 2; j++){
				if((X+j >= 0)&&(X+j < plf->width)){
					plf->playfield[Y+i][X+j] = _BLK_EXPLOSION;
					plf->score += 10;
				}
			}
		}
	}
	start_sound(1,Explode1);
}

void check_plf_sprites(plf,ypos,cnt)
playfield *plf;
uint *ypos;
uint cnt;
{
	register uint i;

	if(cnt > 1){
		plf->spr_count = cnt;
		for(i = 0; i != cnt; i++){
			plf->spr_pos_spd[i][0] = ypos[i]; /* Posi‡Æo Y */
			plf->spr_pos_spd[i][1] = (plf->left*8)+((plf->width-6)*4); /* Posi‡Æo X */
			plf->spr_pos_spd[i][2] = (i*3)+1; /* Velocidade */
		}
	}
	switch(cnt){
		case 0:
		break;
		case 1:
		break;
		case 2:
			for(i = 0; i != 2; i++){
				if(curr_language){
					plf->spr_pos_spd[i][3] = 0;
				}else{
					plf->spr_pos_spd[i][1] += 4;
					plf->spr_pos_spd[i][3] = 6;
				}
			}
		break;
		case 3:
			for(i = 0; i != 3; i++){
				if(curr_language){
					plf->spr_pos_spd[i][3] = 12;
				}else{
					plf->spr_pos_spd[i][3] = 18;
				}
			}
		break;
		case 4:
			for(i = 0; i != 4; i++){
				plf->spr_pos_spd[i][3] = 24;
			}
		break;
	}
}

uint check_for_lines(plf)
playfield *plf;
{
	register uint i,j,k,cnt;
	uint y_temp[4];
	
	cnt = 0;
	for(i = 0; i != plf->height; i++){
		k = TRUE;
		for(j = 0; j != plf->width; j++){
			k = k && (plf->playfield[i][j] != 0) && (plf->playfield[i][j] != _BLK_SOLID);
		}
		if(k){
			/* Detona bombas e destr¢i blocos */
			for(j = 0; j != plf->width; j++){
				switch(plf->playfield[i][j]){
					case _BLK_BOMB:
						detonate_bomb(j,i,plf);
					break;
					default:
						plf->playfield[i][j] = _BLK_EXPLOSION;
						plf->score += 5;
					break;
				}
			}
			/* Prepara os sprites */
			y_temp[cnt] = (plf->top+i)*8;
			/* Incrementa a contagem de linhas */
			cnt++;
		}
	}
	check_plf_sprites(plf,y_temp,cnt);
	plf->update_plf_frame = TRUE;
	return cnt;
}

void clear_lines(plf)
playfield *plf;
{
	register uint i, j, k;
	register int lin2clr;

	/* Anima‡äes */
	lin2clr = 1;
	for(i = 0; i != plf->height; i++){
		for(j = 0; j != plf->width; j++){
			k = plf->playfield[i][j];
			if((k >=  _BLK_EXPLOSION) && (k < _BLK_EXPLOSION_END)){
				/* ExplosÆo */
				k++;
				if(k == _BLK_EXPLOSION_END){
					k = 0;
				}
				plf->playfield[i][j] = k;
				lin2clr = 0;
			}
		}
	}

	/* Limpeza de linhas */
	if(lin2clr&&!(plf->dlyctrl & 0x03)){
		/* Primeiro, busca a linha a ser limpa */
		lin2clr = -1;
		for(i = plf->height-1; (i != 1)&&(lin2clr == -1); i--){
			k = TRUE;
			for(j = 0; j != plf->width; j++){
				k = k && !(plf->playfield[i][j]);
			}
			if(k)
				lin2clr = i;
		}
		/* Agora, faz a limpeza efetiva */
		if(lin2clr != -1){
			for(i = lin2clr; i != 0; i--){
				for(j = 0; j != plf->width; j++){
					plf->playfield[i][j] = plf->playfield[i-1][j];
				}
			}
			for(j = 0; j != plf->width; j++){
				plf->playfield[i][j] = 0;
			}
			plf->cleared_lines--; 
		}else{
			plf->cleared_lines = 0; 
		}
	}
	/* Checa GameOver */
	if(plf->game_over > 1){
		plf->game_over--;
	}

	plf->update_full_playfield = TRUE;
}

