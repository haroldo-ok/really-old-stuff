
/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Resultados do modo versus					 */
/*****************************************************/

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "ultetris.h"
#include "ultrdat.h"
#include "plf_ai.h"
#include "gamebkg.h"
#include "language.h"
#include "options.h"
#include "psgsound.h"
#include "1p_icn.h"
#include "2p_icn.h"
#include "winner.h"
#include "loser.h"
#include "venc.h"
#include "perd.h"

extern uint frame_pal[];
extern uint block_pal[];
extern uint pal_black[];

void show_result_sprites(sprpos,sprnums)
uint sprpos[2][2],sprnums[2][7];
{
	register uint i,j,k;

	k = 1;
	for(i = 0; i != 2; i++){
		for(j = 0; j != 7; j++){
			def_sprite(k++,
					   sprpos[i][0] - (j*8), sprpos[i][1],
					   0x000, sprnums[i][j]|0x6000);
			def_sprite(k++,
					   sprpos[i][0] - (j*8), sprpos[i][1]+8,
					   0x000, (sprnums[i][j] + 16)|0x6000);
		}
	}
	show_sprite(1,k-1);
}

void draw_winner(X,Y,basetile)
uint X;
uint Y;
uint basetile;
{
	if(curr_language){
		set_bkg_data(basetile,(uint)(WINNER_TIL_END-WINNER_TIL)/32,(uint *)WINNER_TIL);
		set_bkg_tiles(X,Y,_WINNER_WIDTH,_WINNER_HEIGHT,(uint *)WINNER_MAP,APLAN,basetile|0x4000);
	}else{
		set_bkg_data(basetile,(uint)(VENC_TIL_END-VENC_TIL)/32,(uint *)VENC_TIL);
		set_bkg_tiles(X,Y,_VENC_WIDTH,_VENC_HEIGHT,(uint *)VENC_MAP,APLAN,basetile|0x4000);
	}
}

void draw_loser(X,Y,basetile)
uint X;
uint Y;
uint basetile;
{
	if(curr_language){
		set_bkg_data(basetile,(uint)(LOSER_TIL_END-LOSER_TIL)/32,(uint *)LOSER_TIL);
		set_bkg_tiles(X,Y,_LOSER_WIDTH,_LOSER_HEIGHT,(uint *)LOSER_MAP,APLAN,basetile|0x4000);
	}else{
		set_bkg_data(basetile,(uint)(PERD_TIL_END-PERD_TIL)/32,(uint *)PERD_TIL);
		set_bkg_tiles(X,Y,_PERD_WIDTH,_PERD_HEIGHT,(uint *)PERD_MAP,APLAN,basetile|0x4000);
	}
}

void versus_result(plf1,plf2)
playfield *plf1, *plf2;
{
	register uint i,j;
	uint sprpos[2][2],sprnums[2][7];
	ulong score1,score2;

	score1 = plf1->score;
	score2 = plf2->score;

	for(i = 0; i != 2; i++){
		for(j = 0; j != 7; j++){
			sprnums[i][j] = (256+64+16+11);
		}
	}
	sprnums[0][0] = (256+64+16);
	sprnums[1][0] = (256+64+16);

	/* Prepara os sprites */
	for(i = 0; i != 7; i++){
		if(score1){
			sprnums[0][i] = (score1 % 10) + (256+64+16);
			score1 /= 10;
		}
		sprpos[0][0] = (plf1->left+plf1->width+plf_display_width-1) * 8;
		sprpos[0][1] = (plf1->top+3) * 8;

		if(score2){
			sprnums[1][i] = (score2 % 10) + (256+64+16);
			score2 /= 10;
		}
		sprpos[1][0] = (plf2->left-2) * 8;
		sprpos[1][1] = (plf2->top+3+plf_display_height) * 8;
	}

    set_colors(3, frame_pal);

	/* Mostra os sprites */
	show_result_sprites(sprpos,sprnums);

	/* Escurece a tela, e depois a limpa */
	fade_from_to(frame_pal,pal_black, 2);
	fade_from_to(frame_pal,pal_black, 1);
	set_colors(0, pal_black);
	fill_bkg_rect(0,0,40,28,APLAN,0);
	fill_bkg_rect(0,0,40,28,BPLAN,0);

	/* Monta o fundo */
	set_bkg_data(512,(uint)(_1P_TIL_END-_1P_TIL)/32,(uint *)_1P_TIL);
	set_bkg_tiles(2,10,__1P_WIDTH,__1P_HEIGHT,(uint *)_1P_MAP,APLAN,512|0x4000);

	set_bkg_data(512+16,(uint)(_2P_TIL_END-_2P_TIL)/32,(uint *)_2P_TIL);
	set_bkg_tiles(2,16,__2P_WIDTH,__2P_HEIGHT,(uint *)_2P_MAP,APLAN,(512+16)|0x4000);

	if(plf1->score < plf2->score){
		draw_loser(19,10,512+32);
	}else{
		draw_winner(19,10,512+32);
	}

	if(plf2->score < plf1->score){
		draw_loser(19,16,512+32+128);
	}else{
		draw_winner(19,16,512+32+128);
	}

	/* Movimenta os sprites at‚ sua respectiva posi‡Æo */
	i = FALSE;
	while(!i){
		i = TRUE;

		if(sprpos[0][0] < (17*8)){
			sprpos[0][0]++;
			i = FALSE;
		}else if(sprpos[0][0] > (17*8)){
			sprpos[0][0]--;
			i = FALSE;
		}

		if(sprpos[0][1] < (10*8)){
			sprpos[0][1]++;
			i = FALSE;
		}else if(sprpos[0][1] > (10*8)){
			sprpos[0][1]--;
			i = FALSE;
		}

		if(sprpos[1][0] < (17*8)){
			sprpos[1][0]++;
			i = FALSE;
		}else if(sprpos[1][0] > (17*8)){
			sprpos[1][0]--;
			i = FALSE;
		}

		if(sprpos[1][1] < (uint)(16*8)){
			sprpos[1][1]++;
			i = FALSE;
		}else if(sprpos[1][1] > (uint)(16*8)){
			sprpos[1][1]--;
			i = FALSE;
		}

		wait_sync();
		show_result_sprites(sprpos,sprnums);
	}

	fade_in(__1p_pal,2);

    out_text(CENTER_TXT(__PRESS_START),23,3,APLAN,__PRESS_START);

	while(!((read_joypad1()|read_joypad2()) & BUTTON_S));
	while((read_joypad1()|read_joypad2()) & BUTTON_S);

	/* Limpa a bagun‡a */
	for(i = 1; i != (7*2*2)+1; i++){
		def_sprite(i, -32, -32, 0x000, 0);
	}
	show_sprite(1,(7*2*2));
}
