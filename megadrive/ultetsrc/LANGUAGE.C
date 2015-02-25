#include "genesis.h"
#include "utils.h"
#include "ultrdat.h"
#include "psgsound.h"
#include "brflag.h"
#include "usflag.h"

#define _BACK_WIDTH  16 /* Copiado de titlsmal.h */
#define _BACK_HEIGHT  8

extern uint  extWIDTH;
extern uint  blocks_pal[];
extern uint _back_pal[16];

extern uint Ding1[];

extern uint wallpaper_x;
extern uint wallpaper_y;

extern uint menu_blink_ctrl;

uint curr_language;

char *_press_start[2]={
	{"Aperte Start"},
	{"Press Start"}
};

char *_game_modes[2][6]={
	{
		"Sobreviv~88ncia",
		"Disputa de dois",
		"Jogador contra CPU",
		"Modo Miss~C6o",
		"Combate Tetris",
		"Cr~82ditos"
	},
	{
		"Survival",
		"2 Player Versus",
		"Player Versus CPU",
		"Mission Mode",
		"Tetris Battle",
		"Credits"
	}
};

char *_wh_settings[2][4]={
	{
		"Tamanho: 22x10",
		"Tamanho: 20x8",
		"Tamanho: 26x12",
		"Tamanho: 22x8"
	},
	{
		"Size: 22x10",
		"Size: 20x8 ",
		"Size: 26x12",
		"Size: 22x8 "
	}
};

char *_bomb_settings[2][2]={
	{
		"Sem Bombas",
		"Com Bombas"
	},
	{
		"Bombs Off",
		"Bombs On"
	}
};

char *_extmode_settings[2][2]={
	{
		"Pe~87as Normais",
		"Pe~87as Extendidas"
	},
	{
		"Normal Blocks",
		"Extended Blocks"
	}
};

char *_game_over_str[2][2]={
	{
		"FIM DE",
		"JOGO"
	},
	{
		"GAME",
		"OVER"
	}
};

char *_survival_stbar[2][6]={
	{
		"Vel.    :",
		"Linhas  x",
		"Simples x",
		"Duplo   x",
		"Triplo  x",
		"Tetris  x"
	},
	{
		"Speed  :",
		"Lines  x",
		"Single x",
		"Double x",
		"Triple x",
		"Tetris x"
	}
};

char *_mission_stbar[2][8]={
	{
		"Fase     :",
		"Vel.     :",
		"Especial x",
		"Simples  x",
		"Duplo    x",
		"Triplo   x",
		"Tetris   x",
		"Tempo    x"
	},
	{
		"Mission :",
		"Speed   :",
		"Special x",
		"Single  x",
		"Double  x",
		"Triple  x",
		"Tetris  x",
		"Time    x"
	}
};

char *_mission_briefing[2][5]={
	{
		"Miss~C6o 000",
		"Cumpra a meta",
		"Destrua os blocos especiais",
		"Sobreviva 000 segundos",
		"0 vidas restantes"
	},
	{
		"Mission 000",
		"Fullfill your meta",
		"Destroy the special blocks",
		"Survive 000 seconds",
		"0 lives left"
	}
};

char *_mission_ending[2][6]={
	{
		"Parab~82ns!!",
		"",
		"Voc~88 sobreviveu ~85s miss~E4es.",
		"Seu score final:",
		"XXXXXXX pontos",
		"0 vidas"
	},
	{
		"Congratulations!!",
		"",
		"You survived from the missions.",
		"Your final score:",
		"XXXXXXX points",
		"0 lives"
	}
};

char *_credits_caption[2]={
	{"*** Cr~82ditos ***"},
	{"*** Credits ***"}
};

char *_pause_opts[2][2]={
	{
		"Continuar",
		"Desiste"
	},
	{
		"Continue",
		"Quit"
	}
};

char *_credits_text_ptr_prt[]={
	"\fGr~A0ficos",
	"\tHaroldo de Oliveira Pinheiro",
	"",
	"\fC~A2digo",
	"\tHaroldo de Oliveira Pinheiro",
	"",
	"\fVozes",
	"\tHaroldo de Oliveira Pinheiro",
	"",
	"\fFerramentas usadas",
	"\tSega Genesis C Compiler",
	"\t\tpor Paul W. Lee",
	"\tTile Layer v0.50b",
	"\t\tpor SnowBro",
	"\tPCX2GEN,",
	"\tPCXG2GEN,",
	"\tMAKEDAT,",
	"\tPATCHDAT",
	"\t\tpor Haroldo O. Pinheiro",
	"\tPOV-Ray(tm) v3.1",
	"\t\tpelo POV-Team",
	NULL
};

char *_credits_text_ptr_eng[]={
	"\fGraphics",
	"\tHaroldo de Oliveira Pinheiro",
	"",
	"\fCode",
	"\tHaroldo de Oliveira Pinheiro",
	"",
	"\fVoices",
	"\tHaroldo de Oliveira Pinheiro",
	"",
	"\fTools used",
	"\tSega Genesis C Compiler",
	"\t\tby Paul W. Lee",
	"\tTile Layer v0.50b",
	"\t\tby SnowBro",
	"\tPCX2GEN,",
	"\tPCXG2GEN,",
	"\tMAKEDAT,",
	"\tPATCHDAT",
	"\t\tby Haroldo O. Pinheiro",
	"\tPOV-Ray(tm) v3.1",
	"\t\tby the POV-Team",
	NULL
};

void choose_language()
{
	register uint i,j;

	/* Textura de fundo */
	set_bkg_data(256,(uint)(BACK_TIL_END-BACK_TIL)/32,BACK_TIL);
	for(i = 0; i < 64; i += _BACK_HEIGHT){
		for(j = 0; j < 64; j += _BACK_WIDTH){
			set_bkg_tiles(j,i,_BACK_WIDTH,_BACK_HEIGHT,BACK_MAP,BPLAN,256);
		}
	}
    set_colors(0, _back_pal);

	/* Fonte */
    dma_vram_copy(FONT_BIN+16, 0, 256*32);
    set_colors(3, blocks_pal);
    out_text(11,4,2,APLAN,"Escolha a linguagem");
    out_text(13,5,2,APLAN,"Select language");

	/* Bandeira do Brasil */
	set_bkg_data(512,(uint)(BRFLAG_TIL_END-BRFLAG_TIL)/32,BRFLAG_TIL);
	set_bkg_tiles(2,10,_BRFLAG_WIDTH,_BRFLAG_HEIGHT,BRFLAG_MAP,APLAN,512|0x2000);
    set_colors(1, _brflag_pal);

	/* Bandeira dos EUA */
	set_bkg_data(1024,(uint)(USFLAG_TIL_END-USFLAG_TIL)/32,USFLAG_TIL);
	set_bkg_tiles(21,10,_USFLAG_WIDTH,_USFLAG_HEIGHT,USFLAG_MAP,APLAN,1024|0x4000);
    set_colors(2, _usflag_pal);

	/* Cursor */
    dma_vram_copy(MENU_BIN, 32, 32*32);

    out_text(15,20,2,APLAN,"Portugu~88s");

	i = 0;
	j = 0;
	curr_language = 0;
	while(!(read_joypad1() & BUTTON_S)){
		scrollv(0, wallpaper_y);
		scrollh(0, wallpaper_x);
		random(1); /* S¢ para "aleatorizar" o gerador de n£meros aleat¢rios */
		wallpaper_x--;
		wallpaper_y++;

		i = read_joypad1();
		if(i != j){
			if(i & JOY_LEFT){
				curr_language = 0;
				fill_bkg_rect(0,20,40,1,APLAN,0);
			    out_text(15,20,2,APLAN,"Portugu~88s");
				start_sound(1,Ding1);
			}
			if(i & JOY_RIGHT){
				curr_language = 1;
				fill_bkg_rect(0,20,40,1,APLAN,0);
			    out_text(16,20,2,APLAN,"English");
				start_sound(1,Ding1);
			}
			j = i;
		}

		menu_blink_ctrl = (menu_blink_ctrl + 1) & 0x0F;
		def_sprite(1, (curr_language*152)+16, 80,
				   0,(1+menu_blink_ctrl)|BUILD_ATTR(3,0,0,0));
		def_sprite(2, (curr_language*152)+16, 144,
				   0,(1+menu_blink_ctrl)|BUILD_ATTR(3,0,0,0));
		def_sprite(3, (curr_language*152)+146, 80,
				   0,(1+menu_blink_ctrl)|BUILD_ATTR(3,0,0,0));
		def_sprite(4, (curr_language*152)+146, 144,
				   0,(1+menu_blink_ctrl)|BUILD_ATTR(3,0,0,0));
		show_sprite(1,4);

		generate_sound();
	    wait_sync();
	}

	if(curr_language){
		play_sample(ENGLISH_RAW,ENGLISH_RAW_END-ENGLISH_RAW);
	}else{
		play_sample(PORTUG_RAW,PORTUG_RAW_END-PORTUG_RAW);
	}

	for(i = 0; i != 40; i++){
		scrollv(0, wallpaper_y);
		scrollh(0, wallpaper_x);
		random(1); /* S¢ para "aleatorizar" o gerador de n£meros aleat¢rios */
		wallpaper_x--;
		wallpaper_y++;
		generate_sound();
		wait_sync();
	}

	/* Aguarda a soltura do botÆo start */
	while(read_joypad1() & BUTTON_S){
		scrollv(0, wallpaper_y);
		scrollh(0, wallpaper_x);
		random(1); /* S¢ para "aleatorizar" o gerador de n£meros aleat¢rios */
		wallpaper_x--;
		wallpaper_y++;
		generate_sound();
	    wait_sync();
	}

	fill_bkg_rect(0,0,40,28,APLAN,0); /* Limpa a tela */
	reset_sprites(4);
}