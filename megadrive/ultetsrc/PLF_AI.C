/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas de inteligˆncia artificial			 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "ultrdat.h"

void rotate_piece_nocheck(plf)
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
}


uint count_holes(plf)
playfield *plf;
{
	register uint i,j,k,l,cnt;

	cnt = 0;
	for(i = 0; i != 3; i++){
		if((plf->pc_y+i) & 0x8000){
			/* se der em uma coordenada negativa, ignore */
		}else{
			for(j = 0; j != 4; j++){
				if(plf->piece[i][j]){
					k = plf->playfield[plf->pc_y+i+1][plf->pcs_x+j];
					k = (k != 0) || (plf->piece[i+1][j]);
					if(!k){ /* se encontrar um espa‡o nÆo preenchido... */
						for( l = plf->pc_y+i+1;
							(l != plf->height) && (!plf->playfield[l][plf->pcs_x+j]);
							 l++){ /* estima o tamanho do buraco */
							cnt++;
						}
					}
				}
			}
		}
	}
	return cnt;
}

uint simulate_drop(plf)
playfield *plf;
{
	register uint i,j,k;
	uint pc_y, eval;
	
	pc_y = plf->pc_y;
	while(check_piece_pos(plf))
		plf->pc_y++;
	plf->pc_y--;

	eval = (plf->pc_y + plf->piece_b + plf->piece_t + 2048) - (count_holes(plf)*4);
	plf->pc_y = pc_y;

	return eval;
}

uint best_ai_result,best_ai_x,best_ai_rot;
uint need_ai_update,ai_step,ai_r_step;

uint plf_ai(plf)
playfield *plf;
{
	register uint i;
	uint tmp;

	playfield dummy_plf, dummy_plf2;

	if(plf->pc_y == 0x7000){
		best_ai_result = 0;
		need_ai_update = TRUE;
		ai_step = (-plf->piece_w[0]);
		ai_r_step = 0;
		return 0;
	}

	if(need_ai_update){
		if(plf->dlyctrl & 0x01){
			return 0;
		}
		plf->pc_x = ai_step;
		update_pcs(plf);
		tmp = simulate_drop(plf);
		if(tmp > best_ai_result){
			best_ai_result = tmp;
			best_ai_x = ai_step;
			best_ai_rot = ai_r_step;
		}
		rotate_piece_nocheck(plf);

		ai_r_step++;
		if(ai_r_step == 4){
			ai_r_step = 0;
			ai_step++;
			if(ai_step == plf->width){
				for(i = 0; i != best_ai_rot; i++){
					rotate_piece(plf);
				}
				plf->pc_x = best_ai_x;
				update_pcs(plf);
				need_ai_update = FALSE;
			}
		}

		return 0;
	}

	return JOY_DOWN;
}
