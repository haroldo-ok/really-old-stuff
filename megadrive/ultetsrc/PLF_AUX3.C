
/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas auxiliares do playfield (parte 3)	 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"

extern uint extWIDTH;

extern uint speed_table[10];

void new_piece(plf);

uint count_special_blocks(plf)
playfield *plf;
{
	register uint i, j, count;

	count = 0;
	for(i = 0; i != plf->height; i++){
		for(j = 0; j != plf->width; j++){
			if(plf->playfield[i][j] == _BLK_SPECIAL){
				count++;
			}
		}
	}

	return count;
}

uint check_plf_meta(plf)
playfield *plf;
{
	uint i, found;

	found = FALSE;
	for(i = 0; i != 4; i++){
		if(plf->line_countdown[i]){
			found = TRUE;
		}
	}

	return !found;
}

void init_playfield(plf)
playfield *plf;
{
	register uint i, j, k;

	for(i = 0; i != _PLF_MAXH; i++){
		for(j = 0; j != _PLF_MAXW; j++){
			plf->playfield[i][j] = 0;
		}
	}
    plf->left	= 2;
	plf->top	= (28 - curr_plf_opt->height) >> 1;
	plf->width  = curr_plf_opt->width;
	plf->height = curr_plf_opt->height;

	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			plf->piece[i][j] = 0;
			for(k = 0; k != 4; k++){
				plf->piece_preview[k][i][j] = 0;
			}
    	}
    }
	plf->pc_x  = 0;
	plf->pc_y  = 0x7000;
	plf->pcs_x = 0;
	plf->pcs_y = 0;

	plf->lastjoy = 0;

	plf->spdctrl = 0;
	plf->curspd  = speed_table[curr_plf_opt->initial_speed];

	plf->dlyctrl = 0;
	plf->rptctrl = 4;

	plf->cleared_lines = 0;

	plf->initial_speed = curr_plf_opt->initial_speed;
	plf->curr_speed = curr_plf_opt->initial_speed;

	plf->total_lines = 0;
	for(i = 0; i != 4; i++){
		plf->line_stats[i] = 0;
		plf->line_countdown[i] = 0;
	}
	plf->score = 0;

	plf->special_blocks = count_special_blocks(plf);
	plf->reached_meta = check_plf_meta(plf);

	plf->bombs_on = curr_plf_opt->bombs_on;
	plf->extended_mode = curr_plf_opt->extended_mode;
	plf->preview_count = curr_plf_opt->preview_count;
	plf->game_over = 0;

    plf->update_plf_frame = TRUE;
    plf->update_full_playfield = TRUE;

	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			plf->spr_pos_spd[i][j] = 0;
		}
	}
	plf->spr_count = 0;

	plf->enemy = NULL;

	for(i = 0; i != 5; i++){
		new_piece(plf);
	}

	plf->life = 255;
	plf->energy = 0;
}

void gameover_sequence(plf)
playfield *plf;
{
	register uint i, j, k;

	if(plf->game_over <= _GAMEOVER_DELAY){ /* Aguarda mais alguns ciclos */
		plf->game_over--;
	}else if(plf->game_over < (_GAMEOVER_DELAY + plf->height)){ /* Preenchendo com blocos s¢lidos */
		j = plf->height - (plf->game_over - _GAMEOVER_DELAY);
		for(i = 0; i != plf->width; i++){
			plf->playfield[j][i] = _BLK_SOLID;
		}
		plf->game_over--;
		plf->update_full_playfield = TRUE;
	}else{ /* Limpeza final de linhas */
		clear_lines(plf);
	}
}

