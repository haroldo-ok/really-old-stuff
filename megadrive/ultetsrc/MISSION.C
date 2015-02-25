#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"
#include "gamebkg.h"
#include "psgsound.h"
#include "language.h"
#include "mission.h"

extern playfield playfield1;
extern uint frame_pal[16];
extern uint pal_black[16];

char *mission_pointer;
mission_header *mishead;
playfield_options mission_opt;
uint mission_number, mission_timer, mission_sub_timer;
uint mission_has_meta;
uint mission_lives;

void load_next_mission()
{
	register uint i,j;

	if(mission_pointer >= (char *)MISSION_TET_END){ /* N∆o resta mais nenhuma miss∆o */
		return;
	}

	mishead = (mission_header *)mission_pointer;

	curr_plf_opt->width = mishead->width;
	curr_plf_opt->height = mishead->height;
	curr_plf_opt->bombs_on = mishead->bombs_on;
	curr_plf_opt->extended_mode = mishead->extended_mode;
	curr_plf_opt->initial_speed = mishead->initial_speed;
	curr_plf_opt->preview_count = mishead->preview_count;

	mission_timer = mishead->count_down;
	mission_sub_timer = 60;

	init_playfield(&playfield1);

	mission_has_meta = FALSE;
	for(i = 0; i != 4; i++){
		playfield1.line_countdown[i] = mishead->meta[i];
		if(mishead->meta[i]){
			mission_has_meta = TRUE;
		}
	}

	mission_pointer += sizeof(mission_header); /* Salta os bytes do cabeáalho */

	for(i = 0; i != mishead->height; i++){
		for(j = 0; j != mishead->width; j++){
			playfield1.playfield[i][j] = *mission_pointer;
			mission_pointer++;
		}
	}

	playfield1.special_blocks = count_special_blocks(&playfield1);
	playfield1.reached_meta = check_plf_meta(&playfield1);

	mission_number++;
}

uint mission_clear()
{
	uint clear;

	if(mishead->count_down && mission_timer){ 
		/* Se tem contagem regressiva e o tempo n∆o tiver acabado */
		return FALSE;
	}

	if(mishead->special_blocks && playfield1.special_blocks){
		/* Se ainda houver blocos especiais */
		return FALSE;
	}

	if(mission_has_meta && (!playfield1.reached_meta)){
		/* Se houver uma meta, mas n∆o foi alcanáada */
		return FALSE;
	}

	return TRUE;
}

void mission_briefing()
{
	register uint i,j;

	fill_bkg_rect(0,28,40,28,APLAN,0); /* Limpa o texto da miss∆o anterior */

	for(i = 1; i != 81; i++){ /* Limpa os sprites */
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);

	/* Move a tela para cima */
	for(i = 0; i != 244; i += 4){
		wait_sync();
		scrollv(i,0);
		generate_sound();
	}
	scrollv(-244,0);

	fill_bkg_rect(0,0,40,28,APLAN,0); /* Limpa a †rea do playfield */

	set_colors(0,pal_black);

	/* Descreve os objetivos da miss∆o */
	i = 41;

	out_text(CENTER_TXT(__MISSION_BRIEFING(0)),i,2,APLAN,__MISSION_BRIEFING(0));
	if(curr_language){
		j = CENTER_TXT(__MISSION_BRIEFING(0))+strlen2("Mission ");
	}else{
		j = CENTER_TXT(__MISSION_BRIEFING(0))+strlen2("Miss∆o ");
	}
	out_uint(j,i,2,APLAN,3,mission_number);
	i+=2;

	if(mission_has_meta){
		out_text(CENTER_TXT(__MISSION_BRIEFING(1)),i,2,APLAN,__MISSION_BRIEFING(1));
		i++;
	}
	if(mishead->special_blocks){
		out_text(CENTER_TXT(__MISSION_BRIEFING(2)),i,2,APLAN,__MISSION_BRIEFING(2));
		i++;
	}
	if(mishead->count_down){
		out_text(CENTER_TXT(__MISSION_BRIEFING(3)),i,2,APLAN,__MISSION_BRIEFING(3));
		if(curr_language){
			j = CENTER_TXT(__MISSION_BRIEFING(3))+strlen2("Survive ");
		}else{
			j = CENTER_TXT(__MISSION_BRIEFING(3))+strlen2("Sobreviva ");
		}
		out_uint(j,i,2,APLAN,3,mishead->count_down);
		i++;
	}

	out_text(CENTER_TXT(__MISSION_BRIEFING(4)),i+2,2,APLAN,__MISSION_BRIEFING(4));
	out_uint(CENTER_TXT(__MISSION_BRIEFING(4)),i+2,2,APLAN,1,mission_lives);

	/* Aguarda cerca de dois segundos */
    for(j = 120; j != 0; j--){
		wait_sync();
		generate_sound();
	}

	fill_bkg_rect(0,i+2,40,1,APLAN,0);
	out_text(CENTER_TXT(__PRESS_START),i+2,2,APLAN,__PRESS_START);

	/* Prepara o cen†rio de fundo */
	if(mishead->count_down){
		i = 0;
	}else if(mishead->special_blocks){
		i = 1;
	}else{
		i = 2;
	}

	draw_mission_bkg(i); 

	playfield1.left = (40-playfield1.width-20) >> 1;
	plf_display_width = 20;
	plf_display_height = 9;

   	init_tiles();
	draw_playfield(&playfield1);

	scrollh(0, 0); 
	scrollv(-244, 0); 
    wait_sync();

	/* Aguarda o bot∆o start */
	while(!((read_joypad1()|read_joypad2())&BUTTON_S)){
		wait_sync();
		generate_sound();
	}
	while(((read_joypad1()|read_joypad2())&BUTTON_S)){
		wait_sync();
		generate_sound();
	}

	/* Rola a tela de volta Ö posiá∆o normal */
	for(i = 244; i != 0; i -= 4){
		wait_sync();
		scrollv(i,0);
		generate_sound();
	}
	scrollv(0,0);
}

void mission_ending()
{
	register uint i,j;

	fill_bkg_rect(0,0,40,56,APLAN,0); /* Limpa a tela toda */
	for(i = 1; i != 81; i++){ /* Limpa os sprites */
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);
	scrollh(0, 0); 
	scrollv(0, 0); 
	set_colors(0,pal_black);

	draw_mission_bkg(3);

	/* Aguarda cerca de dois segundos */
    for(j = 120; j != 0; j--){
		wait_sync();
		generate_sound();
	}

	for(i = 0; i != 4; i++){
		out_text(CENTER_TXT(__MISSION_ENDING(i)),i+11,2,APLAN,__MISSION_ENDING(i));
	}

	j = playfield1.score;
	i = 3;
	while(j){ /* Calcula o ajuste horizontal do score */
		i--;
		j /= 100;
	}
	i = CENTER_TXT(__MISSION_ENDING(4)) - i;
	out_text(i,15,2,APLAN,__MISSION_ENDING(4));
	out_ulong(i,15,2,APLAN,7,playfield1.score); 
	out_text(CENTER_TXT(__MISSION_ENDING(5)),16,2,APLAN,__MISSION_ENDING(5));
	out_uint(CENTER_TXT(__MISSION_ENDING(5)),16,2,APLAN,1,mission_lives);

	/* Aguarda cerca de dez segundos */
    for(j = 600; j != 0; j--){
		wait_sync();
		generate_sound();
	}
}

void play_mission()
{
	uint mission_skip;
	ulong score;

	mission_pointer = (char *)MISSION_TET;
	curr_plf_opt = &mission_opt;
	mission_number = 0;

	playfield1.game_over = 0;
	mission_lives = 5;
	score = 0;
    while((mission_lives)&&
		  (mission_pointer < (char *)MISSION_TET_END)){
		load_next_mission();

	    mission_briefing();

		init_joypad();
		out_text(0,0,1,APLAN,"Ultimate tetris beta version");

		playfield1.score = score;
		mission_skip = FALSE;
	    while((playfield1.game_over != 1) && (!mission_clear()) && (!mission_skip)){
			handle_playfield(&playfield1,read_joypad1());
			generate_sound();
   			redraw(FALSE);

			if((read_joypad1() & (BUTTON_S|BUTTON_A|BUTTON_B|BUTTON_C)) == (BUTTON_S|BUTTON_A|BUTTON_B|BUTTON_C)){
				mission_skip = TRUE;
				while(read_joypad1() & BUTTON_S);
			}else if((read_joypad1()|read_joypad2()) & BUTTON_S){
				if(pause_menu() == 1){
					playfield1.pc_y = 0x7000;
					prepare_gameover(&playfield1);
					mission_lives = 1;
				}
			}

			if(!(--mission_sub_timer)){
				if(mission_timer){
					mission_timer--;
					playfield1.update_plf_frame = TRUE;
				}
				mission_sub_timer = 60;
			}
		}
		
		score = playfield1.score;
		if(playfield1.game_over == 1){
			mission_lives--;
		}
    }

	if(mission_lives){
		mission_ending();
	}

	fill_bkg_rect(0,0,40,56,APLAN,0); /* Limpa a tela toda */
}