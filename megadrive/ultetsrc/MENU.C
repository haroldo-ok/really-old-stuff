#include "genesis.h"
#include "utils.h"
#include "ultrdat.h"
#include "titlepal.h"
#include "titlback.h"
#include "smaltitl.h"
#include "psgsound.h"
#include "options.h"
#include "language.h"

extern uint  extWIDTH;
extern uint  blocks_pal[];

extern uint Ding1[];

uint wallpaper_x;
uint wallpaper_y;

uint main_menu();

uint title_screen()
{
	register uint i,j;

	/* Tela-t¡tulo */
	set_bkg_data(256,(uint)(BACK_TIL_END-BACK_TIL)/32,BACK_TIL);
	for(i = 0; i < 64; i += _BACK_HEIGHT){
		for(j = 0; j < 64; j += _BACK_WIDTH){
			set_bkg_tiles(j,i,_BACK_WIDTH,_BACK_HEIGHT,BACK_MAP,BPLAN,256);
		}
	}
    set_colors(0, _back_pal);

	set_bkg_data(512,(uint)(TITLE_TIL_END-TITLE_TIL)/32,TITLE_TIL);
	set_bkg_tiles(0,0,_TITLE_WIDTH,_TITLE_HEIGHT,TITLE_MAP,APLAN,512|0x2000);
    set_colors(1, _title_pal);

    dma_vram_copy(FONT_BIN+16, 0, 256*32);
    set_colors(2, blocks_pal);
    out_text(CENTER_TXT(__PRESS_START),20,1,APLAN,__PRESS_START);

	while(!(read_joypad1() & BUTTON_S)){
		scrollv(0, wallpaper_y);
		scrollh(0, wallpaper_x);
		random(1); /* S¢ para "aleatorizar" o gerador de n£meros aleat¢rios */
		wallpaper_x--;
		wallpaper_y--;
		generate_sound();
	    wait_sync();
	}

	fill_bkg_rect(0,20,40,1,APLAN,0); /* Limpa o "Aperte Start" */
	play_sample(YEAH_RAW,YEAH_RAW_END-YEAH_RAW);
	for(j = 0; j != 128; j+=4){
		scrollv(j, wallpaper_y);
		scrollh(0, wallpaper_x);
		wallpaper_x--;
		wallpaper_y--;
		generate_sound();
	    wait_sync();
	}

	fill_bkg_rect(0,0,40,28,APLAN,0); /* Limpa a tela-t¡tulo */

	i = main_menu();

	clrscr();
	scrollv(0, 0);
	scrollh(0, 0);

	return i;
}

char *menustrings[8];
uint menu_option,menu_option_count;
uint menu_blink_ctrl;
uint menu_last_joypad,menu_joypad_changed;

void do_menu(X,Y,W,H,full_update,hide_sprites)
uint X,Y,W,H;
uint full_update,hide_sprites;
{
	register uint i;
	uint joy;
	char *currstr;

	if(full_update){
		fill_bkg_rect(X,Y,W,H,APLAN,0); /* Limpa a  rea */

		currstr = menustrings[0];
		for(i = 0; (i != 8) && (menustrings[i] != NULL); i++){
			currstr = menustrings[i];
		    out_text(20-(strlen2(currstr) >> 1),(i*2)+Y,1,APLAN,currstr);
		}
		menu_option_count = i;
		if(menu_option >= menu_option_count){
			if(menu_option_count){
				menu_option = menu_option_count-1;
			}else{
				menu_option = 0;
			}
		}
	}

	if(!hide_sprites){
		menu_blink_ctrl = (menu_blink_ctrl + 1) & 0x0F;
		currstr = menustrings[menu_option];
		def_sprite(1, (19-(strlen2(currstr) >> 1))*8, (Y+(menu_option*2))*8,
				   0,(1024+menu_blink_ctrl)|BUILD_ATTR(2,0,0,0));
		def_sprite(2, (21+(strlen2(currstr) >> 1))*8, (Y+(menu_option*2))*8,
				   0,(1024+menu_blink_ctrl)|BUILD_ATTR(2,0,0,0));
		show_sprite(1,2);
	}else{
		def_sprite(1,0,-32,0,0);
		def_sprite(2,0,-32,0,0);
		show_sprite(1,2);
	}

	joy = read_joypad1()|read_joypad2();
	menu_joypad_changed = FALSE;
	if(menu_option_count){
		if(joy != menu_last_joypad){
			if(joy & JOY_UP){
				if(menu_option){
					menu_option--;
				}else{
					menu_option = menu_option_count - 1;
				}
				start_sound(1,Ding1);
			}
			if(joy & JOY_DOWN){
				menu_option++;
				menu_option %= menu_option_count;
				start_sound(1,Ding1);
			}
			menu_joypad_changed = TRUE;
		}
	}
	menu_last_joypad = joy;
}

uint plf_option_menu(num)
uint num;
{
	uint need_update;

	if(num > _GAMEMODE_1P_VS_CPU){
		return 0;
	}

	curr_plf_opt = &plf_opt[num];

	curr_plf_opt->width = wh_settings[curr_plf_opt->curr_wh_setting].W;
	curr_plf_opt->height = wh_settings[curr_plf_opt->curr_wh_setting].H;

	menustrings[0] = __WH_SETTINGS(curr_plf_opt->curr_wh_setting);
	menustrings[1] = __BOMB_SETTINGS(curr_plf_opt->bombs_on);
	menustrings[2] = __EXTMODE_SETTINGS(curr_plf_opt->extended_mode);
	menustrings[3] = NULL;
	menu_option = 0;
	do_menu(0,_SMALTITL_HEIGHT+3,40,20,TRUE,TRUE);

	while(!(read_joypad1() & BUTTON_S)){
		do_menu(0,_SMALTITL_HEIGHT+3,40,20,need_update,FALSE);
		need_update = FALSE;

		if(menu_joypad_changed){
			switch(menu_option){
				case 0:
					if(menu_last_joypad & JOY_LEFT){
						if(curr_plf_opt->curr_wh_setting){
							curr_plf_opt->curr_wh_setting--;
						}else{
							curr_plf_opt->curr_wh_setting = _WH_SETTINGS_COUNT-1;
						}
					}
					if(menu_last_joypad & (JOY_RIGHT|BUTTON_A|BUTTON_B|BUTTON_C)){
						curr_plf_opt->curr_wh_setting++;
						curr_plf_opt->curr_wh_setting %= _WH_SETTINGS_COUNT;
					}
					menustrings[0] = __WH_SETTINGS(curr_plf_opt->curr_wh_setting);
					curr_plf_opt->width = wh_settings[curr_plf_opt->curr_wh_setting].W;
					curr_plf_opt->height = wh_settings[curr_plf_opt->curr_wh_setting].H;
					need_update = TRUE;
				break;
				case 1:
					if(menu_last_joypad & (JOY_LEFT|JOY_RIGHT|BUTTON_A|BUTTON_B|BUTTON_C)){
						curr_plf_opt->bombs_on = !curr_plf_opt->bombs_on;
					}
					menustrings[1] = __BOMB_SETTINGS(curr_plf_opt->bombs_on);
					need_update = TRUE;
				break;
				case 2:
					if(menu_last_joypad & (JOY_LEFT|JOY_RIGHT|BUTTON_A|BUTTON_B|BUTTON_C)){
						curr_plf_opt->extended_mode = !curr_plf_opt->extended_mode;
					}
					menustrings[2] = __EXTMODE_SETTINGS(curr_plf_opt->extended_mode);
					need_update = TRUE;
				break;
			}
			if(need_update){
				start_sound(1,Ding1);
			}
		}

		scrollv(0, wallpaper_y);
		scrollh(0, wallpaper_x);
		wallpaper_x++;
		wallpaper_y--;

		generate_sound();
	    wait_sync();
	}

	return 0;
}

uint main_menu()
{
	register uint i,j;

	scrollv(-244, wallpaper_y);
	scrollh(0, wallpaper_x);

	/* Miniatura do t¡tulo */
	set_bkg_data(512,(uint)(SMALTITL_TIL_END-SMALTITL_TIL)/32,SMALTITL_TIL);
	set_bkg_tiles(20-(_SMALTITL_WIDTH >> 1),1,_SMALTITL_WIDTH,_SMALTITL_HEIGHT,SMALTITL_MAP,APLAN,512|0x2000);
    set_colors(1, _smaltitl_pal);

	/* Caracteres do menu */
    dma_vram_copy(MENU_BIN, 1024*32, 32*32);

	menustrings[0] = __GAME_MODES(0);
	menustrings[1] = __GAME_MODES(1);
	menustrings[2] = __GAME_MODES(2);
	menustrings[3] = __GAME_MODES(3);
	menustrings[4] = __GAME_MODES(4);
	menustrings[5] = __GAME_MODES(5);
	menustrings[6] = NULL;
	menu_option = 0;
	do_menu(0,_SMALTITL_HEIGHT+3,40,20,TRUE,TRUE);

	for(j = -244; j != 0; j+= 4){
		scrollv(j, wallpaper_y);
		scrollh(0, wallpaper_x);
		wallpaper_x++;
		wallpaper_y--;
		generate_sound();
	    wait_sync();
	}
	scrollv(0, wallpaper_x);
	scrollh(0, wallpaper_y);

	while(!(read_joypad1() & BUTTON_S)){
		do_menu(0,_SMALTITL_HEIGHT+3,40,20,FALSE,FALSE);

		scrollv(0, wallpaper_y);
		scrollh(0, wallpaper_x);
		wallpaper_x++;
		wallpaper_y--;

		generate_sound();
	    wait_sync();
	}

	while(read_joypad1() & BUTTON_S) /* espera soltar o start */;

	i = menu_option;
	plf_option_menu(menu_option);

	scrollv(0,0);
	scrollh(0,0);
	reset_sprites(2);

	return i;
}

uint pause_menu()
{
	register uint i,j;
	char *currstr;

	/* Limpa os sprites */
	for(i = 0; i != 16; i++){
		def_sprite(i+1,0,-32,0,0);
	}
	show_sprite(1,16);

	/* Cursor do menu (Note que o bloco-base ‚ diferente) */
    dma_vram_copy(MENU_BIN, 1*32, 32*32);

	menustrings[0] = __PAUSE_OPTS(0);
	menustrings[1] = __PAUSE_OPTS(1);
	menustrings[2] = NULL;
	menu_option = 0;
	do_menu(0,28+12,40,20,TRUE,TRUE);

	for(j = 0; j != 244; j += 4){
		scrollv(j, 0);
		scrollh(0, 0);
		generate_sound();
	    wait_sync();
	}

	while(!((read_joypad1()|read_joypad2()) & BUTTON_S)){
		do_menu(0,28+12,40,20,FALSE,TRUE);

		menu_blink_ctrl = (menu_blink_ctrl + 1) & 0x0F;
		currstr = menustrings[menu_option];
		def_sprite(1, (19-(strlen2(currstr) >> 1))*8, (10+(menu_option*2))*8,
				   0,(1+menu_blink_ctrl)|BUILD_ATTR(2,0,0,0));
		def_sprite(2, (21+(strlen2(currstr) >> 1))*8, (10+(menu_option*2))*8,
				   0,(1+menu_blink_ctrl)|BUILD_ATTR(2,0,0,0));
		show_sprite(1,2);

		generate_sound();
	    wait_sync();
	}

	while((read_joypad1()|read_joypad2()) & BUTTON_S) /* espera soltar o start */;

	i = menu_option;

	/* Limpa os sprites */
	for(j = 0; j != 16; j++){
		def_sprite(j+1,0,-32,0,0);
	}
	show_sprite(1,16);

	/* Volta a tela ao lugar correto */
	for(j = 244; j != 0; j -= 4){
		scrollv(j, 0);
		scrollh(0, 0);
		generate_sound();
	    wait_sync();
	}
	scrollv(0, 0);
	scrollh(0, 0);

	/* Limpa a sujeira */
	fill_bkg_rect(0,28,40,28,APLAN,0);

	return i;
}
