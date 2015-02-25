
/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas do playfield						 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"
#include "psgsound.h"
#include "language.h"

extern uint extWIDTH;

extern uint TanTanTaan1[];

char pieces[][4][4]={
	/* Pe‡as normais */
	{{0,0,0,0},
	 {0,1,1,0},
	 {0,1,1,0},
	 {0,0,0,0}},
	{{0,0,0,0},
	 {0,0,1,0},
	 {0,1,1,0},
	 {0,1,0,0}},
	{{0,0,0,0},
	 {0,1,0,0},
	 {0,1,1,0},
	 {0,0,1,0}},
	{{0,0,0,0},
	 {0,1,1,0},
	 {0,0,1,0},
	 {0,0,1,0}},
	{{0,0,0,0},
	 {0,1,1,0},
	 {0,1,0,0},
	 {0,1,0,0}},
	{{0,0,1,0},
	 {0,0,1,0},
	 {0,0,1,0},
     {0,0,1,0}},
	{{0,0,1,0},
	 {0,1,1,0},
	 {0,0,1,0},
     {0,0,0,0}},
	/* Pe‡as extendidas */
	{{0,1,1,0},
	 {0,0,1,0},
	 {0,0,1,0},
	 {0,0,1,0}},
	{{0,1,1,0},
	 {0,1,0,0},
	 {0,1,0,0},
	 {0,1,0,0}},
	{{0,1,0,0},
	 {0,1,1,0},
	 {0,0,1,0},
	 {0,0,1,0}},
	{{0,0,1,0},
	 {0,1,1,0},
	 {0,1,0,0},
	 {0,1,0,0}},
	{{0,0,0,0},
	 {0,1,1,1},
	 {0,1,0,1},
	 {0,0,0,0}},
	{{0,0,0,0},
	 {0,1,1,1},
	 {0,1,1,0},
	 {0,0,0,0}},
	{{0,0,1,0},
	 {0,1,1,1},
	 {0,0,1,0},
	 {0,0,0,0}}
};

uint speed_table[10]={45,40,33,20,14,10,8,6,4,2};

void new_piece(plf)
playfield *plf;
{
	register uint i, j, k, l;

	/* Primeiro, pega a pe‡a que j  est  no preview */

	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			plf->piece[i][j] = plf->piece_preview[0][i][j];
		}
	}

	/* Agora, atualiza o preview */

	for(k = 0; k != 3; k++){
		for(i = 0; i != 4; i++){
			for(j = 0; j != 4; j++){
				plf->piece_preview[k][i][j] = plf->piece_preview[k+1][i][j];
			}
		}
	}

	/* Finalmente, adiciona a pe‡a nova ao preview */

	if(plf->extended_mode){
        k = random(13);
	}else{
		k = random(7);
	}
	l = random(4)+2;
	for(i = 0; i != 4; i++){
		for(j = 0; j != 4; j++){
			if(pieces[k][i][j]){
				if(plf->bombs_on && !random(15)){
					plf->piece_preview[3][i][j] = _BLK_BOMB;
				}else{
					plf->piece_preview[3][i][j] = l;
				}
			}else{
				plf->piece_preview[3][i][j] = 0;
			}
		}
	}
	plf->pc_y = -4;
	update_piece_w(plf);
    plf->update_plf_frame = TRUE;
}

void handle_playfield(plf,joy)
playfield *plf;
uint joy;
{
	register uint i, j, k;

	/* Movimentos da pe‡a */
	if(plf->game_over == 1){ /* Game Over MESMO */
		/* Nada a fazer */
	}else if(plf->game_over){ /* Sequˆncia final de Game Over */
		gameover_sequence(plf);
	}else if(plf->cleared_lines){ /* Linhas a limpar */
		clear_lines(plf);
	}else if(plf->pc_y == 0x7000){ /* Nenhuma pe‡a */
		new_piece(plf);
	}else{ /* Pe‡a em jogo */
		if(joy & JOY_LEFT){
			if(plf->pc_x != -2){
				if((!plf->rptctrl)||!(plf->lastjoy & JOY_LEFT)){
					plf->pc_x = plf->pcs_x;
					move_piece_lr(plf,-1);
				}
			}
		}
		if(joy & JOY_RIGHT){
			if(plf->pc_x != plf->width-2){
				if((!plf->rptctrl)||!(plf->lastjoy & JOY_RIGHT)){
					plf->pc_x = plf->pcs_x;
					move_piece_lr(plf, 1);
				}
			}
		}
		if((joy & JOY_UP)&&!(plf->lastjoy & JOY_UP)){
			rotate_piece(plf);
		}
		if(joy & JOY_DOWN){
			if(!(plf->dlyctrl&0x01)){
				lower_piece(plf);
			}
		}
		if(joy & BUTTON_S){
/*			start_sound(1,TanTanTaan1);
			while(read_joypad1() & BUTTON_S); */
/*			plf->pc_y = 0x7000; */
		}
		plf->lastjoy = joy;

		update_pcs(plf);

		if(!plf->spdctrl){ /* J  ‚ hora de abaixar a pe‡a? */
			lower_piece(plf);
			plf->spdctrl = plf->curspd;
		}else{
			plf->spdctrl--;
		}
		if(!(joy & (JOY_LEFT|JOY_RIGHT))){ /* NÆo moveu para nenhum dos dois lados? */
			plf->rptctrl = 4; /* Reseta o delay de repeti‡Æo */
		}else if(plf->rptctrl){
			plf->rptctrl--;
		}
		if(plf->cleared_lines){ /* Conseguiu completar alguma linha? */
			/* Incrementa o score e produz o efeito sonoro */
			switch(plf->cleared_lines){
				case 0:
				break;
				case 1:
					plf->score += 50;
					plf->energy += 32;
					play_sample(YEAH_RAW,YEAH_RAW_END-YEAH_RAW);
				break;
				case 2:
					plf->score += 150;
					plf->energy += 72;
					play_sample(DOUBLE_RAW_L,DOUBLE_RAW_END_L-DOUBLE_RAW_L);
				break;
				case 3:
					plf->score += 400;
					plf->energy += 128;
					play_sample(TRIPLE_RAW_L,TRIPLE_RAW_END_L-TRIPLE_RAW_L);
				break;
				case 4:
					plf->score += 1300;
					plf->energy += 192;
					play_sample(TETRIS_RAW,TETRIS_RAW_END-TETRIS_RAW);
				break;
			}
			if(plf->energy > 255){
				plf->energy = 255;
			}
			/* Atrapalha o advers rio */
			if((plf->enemy) && 
			   (!((playfield *)plf->enemy)->game_over) && 
			   (plf->cleared_lines > 1) &&
			   (curr_game_mode != _GAMEMODE_BATTLE)){
				add_plf_lines((playfield *)plf->enemy,plf->cleared_lines-1);
			}
			/* Atualiza estat¡sticas */
			plf->total_lines += plf->cleared_lines;
			if(plf->cleared_lines){
				i = plf->cleared_lines;
				plf->line_stats[i-1]++;
				while(i&&(!plf->line_countdown[i-1])){
					i--;
				}
				if(i){
					plf->line_countdown[i-1]--;
				}
				plf->special_blocks = count_special_blocks(plf);
				plf->reached_meta = check_plf_meta(plf);
			}
			/* Verifica se ‚ hora de aumentar a velocidade */
			i = (plf->total_lines / 20) + plf->initial_speed;
			if(i < 10){
				plf->curr_speed = i;
				i = speed_table[i];
			}else{
				plf->curr_speed = 9;
				i = 0;
			}
			if(i != plf->curspd){
				plf->curspd = i;
				start_sound(1,TanTanTaan1);
			}
		}
	}

	plf->dlyctrl++;
}

