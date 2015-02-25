
/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas auxiliares do playfield (parte 2)	 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "ultrdat.h"
#include "language.h"

extern uint extWIDTH;

extern char pieces[][4][4];

void update_pcs(plf)
playfield *plf;
{
	plf->pcs_x = plf->pc_x;
	plf->pcs_y = plf->pc_y;

	if(plf->pcs_x+plf->piece_w[0] < 0){
		plf->pcs_x = -plf->piece_w[0];
	}else if(plf->pcs_x+plf->piece_w[1] > plf->width-1){
		plf->pcs_x = plf->width - plf->piece_w[1]-1;
	}
}

void update_piece_w(plf)
playfield *plf;
{
	register uint i,j;

	plf->piece_w[0] = 3;
	plf->piece_w[1] = 0;
	plf->piece_t = 3;
	plf->piece_b = 0;
	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			if(plf->piece[i][j]){
				if(j < plf->piece_w[0]){
					plf->piece_w[0] = j;
				}
				if(j > plf->piece_w[1]){
					plf->piece_w[1] = j;
				}
				if(i < plf->piece_t){
					plf->piece_t = i;
				}
				if(i > plf->piece_b){
					plf->piece_b = i;
				}
			}
		}
	}
	update_pcs(plf);
}

char check_piece_pos(plf)
playfield *plf;
{
	register uint i,j,k,l;

	plf->pcs_y = plf->pc_y;
	for(i = 0; i != 4; i++){
		if((plf->pcs_y+i) & 0x8000){
			/* se der em uma coordenada negativa, ignore */
		}else{
			for(j = 0; j != 4; j++){
				l = plf->piece[i][j];
				if(l){
					if(plf->pcs_y+i > plf->height-1){
						return FALSE; /* Pe‡a passou da parte de baixo */
					}else{
						k = plf->playfield[plf->pcs_y+i][plf->pcs_x+j];
						if(k){
							return FALSE; /* Vaga ocupada... */
						}
					}
				}
			}
		}
	}

	return TRUE;
}

void rotate_piece_rev(plf)
playfield *plf;
{
	register uint i,j;
	char aux[4][4];

	/* Copia para a matriz auxiliar */
	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			aux[i][j] = plf->piece[i][j];
		}
	}
	/* Faz a rota‡Æo propriamente dita */
	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			plf->piece[i][j] = aux[3-j][i];
		}
	}
/*	update_piece_w(plf); */
}

void rotate_piece(plf)
playfield *plf;
{
	register uint i,j;
	char aux[4][4];

	/* Copia para a matriz auxiliar */
	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			aux[i][j] = plf->piece[i][j];
		}
	}
	/* Faz a rota‡Æo propriamente dita */
	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			plf->piece[i][j] = aux[j][3-i];
		}
	}
	update_piece_w(plf);
	if(!check_piece_pos(plf)){
		rotate_piece_rev(plf);
		update_piece_w(plf);
	}
}

void lower_piece(plf)
playfield *plf;
{
	register uint i,j,k;

	plf->pc_y++;
	if(!check_piece_pos(plf)){ /* Encostou no chÆo? */
		plf->pc_y--;
		plf->pcs_y = plf->pc_y;
		/* "Fixa" a pe‡a no playfield */
		for(i = 0; i != 4; i++){
			if(!(plf->pcs_y+i & 0x8000)){
				for(j = 0; j != 4; j++){
					k = plf->piece[i][j];
					if(k){
						plf->playfield[plf->pcs_y+i][plf->pcs_x+j] = k;
					}
				}
			}
		}
		if((int)plf->pc_y+(int)plf->piece_t < 0){
			prepare_gameover(plf);
		}
		plf->pc_y = 0x7000;
		plf->cleared_lines = check_for_lines(plf);
		plf->update_full_playfield = TRUE;
	}
}

void move_piece_lr(plf,dir)
playfield *plf;
char dir;
{
	plf->pc_x+=dir;
	update_pcs(plf);
	if(!check_piece_pos(plf)){
		plf->pc_x-=dir;
		update_pcs(plf);
	}
}

void add_plf_lines(plf,count)
playfield *plf;
uint count;
{
	register uint i,j;

	for( ; count; count--){
		for(i = 0; i != (plf->height-1); i++){
			for(j = 0; j != plf->width; j++){
				plf->playfield[i][j] = plf->playfield[i+1][j];
			}
		}
		i = 0;
		while((i == 0) || (i == plf->width-1)){ /* adiciona o lixo embaixo */
			i = 0;
			for(j = 0; j != plf->width; j++){
				if(random(2)){
					plf->playfield[plf->height-1][j] = 1;
					i++;
				}else{
					plf->playfield[plf->height-1][j] = 0;
				}
			}
		}
	}
    plf->update_full_playfield = TRUE;
}
