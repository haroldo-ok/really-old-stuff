/*
	Ultimate Tetris
		by Haroldo de Oliveira pinheiro
*/
/*
 *
 * A Plan Adr = c000
 * window adr = b000
 * B Plan adr = e000
 * //sprite adr = be00
 * sprite adr = bc00
 * HScrol adr = b800
 *
 */

#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "gamebkg.h"
#include "fracbkg.h"
#include "ultetris.h"
#include "ultrdat.h"
#include "plf_ai.h"
#include "language.h"
#include "options.h"
#include "psgsound.h"
#include "credits.h"

uint blocks_pal[16]={
0x000,
0x444,
0x888,
0xEEE,
0x004,
0x008,
0x00E,
0x040,
0x080,
0x0E0,
0x400,
0x800,
0xE00,
0x044,
0x088,
0x0EE
};

uint bkg_pal[16]={
0xfff,
0xe50,
0xfa8,
0xf96,
0xfba,
0xfa8,
0xf97,
0xfcb,
0xfba,
0xfcc,
0xf87,
0xfaa,
0xf99,
0xf88,
0xe22,
0x000
};

uint frame_pal[16]={
0x000,
0x420,
0x862,
0xE84,
0x004,
0x008,
0x00E,
0x040,
0x080,
0x0E0,
0x400,
0x800,
0xE00,
0x044,
0x088,
0x0EE
};

/***** MODIFY THE WIDTH ****/
/***** see INIT_GFX     ****/
uint  extWIDTH;
uint  plyx,plyy;


/*************    Variables  *************/
int xwrite1, xwrite2;   
playfield playfield1,playfield2;

/************* Prot¢tipos **********/
void play_1p_survival();
void play_versus(versus_cpu);


/*************  Main program  ***********/
void main()
{
    register uint i,j;
    register uint *pw;

    /* Initialize Genesis GFX registers */
    init_GFX();
    
	init_PSG();

	init_options();

    /* some correct */
/*    pw = (uint *) GFXCNTL; */

/*    *pw = 0x8700; */  /* reg. 7 - Background Color number*/
/*    *pw = 0x9001; */  /* reg 16 - scrl screen v&h size */
/*    extWIDTH = 32;*/


    /* Wait until GFX reg are initialized */
    wait_sync();

	choose_language();

	/* Loop principal */
	while(TRUE){
	    init_GFX();

		curr_game_mode = title_screen();

		switch(curr_game_mode){
			case _GAMEMODE_1P_SURVIVAL:
				play_1p_survival();
			break;
			case _GAMEMODE_1P_VS_2P:
				play_versus(FALSE);
			break;
			case _GAMEMODE_1P_VS_CPU:
				play_versus(TRUE);
			break;
			case _GAMEMODE_MISSION:
				play_mission();
			break;
			case _GAMEMODE_BATTLE:
				play_battle_mode();
			break;
			case _GAMEMODE_CREDITS:
				show_credits();
			break;
		}
	}
};

/*************  Initialize GFX  ***********/
void init_GFX()
{
    register uint *pw;

    pw = (uint *) GFXCNTL;

    *pw = 0x8016;   /* reg. 0 - Enable HBL */
    *pw = 0x8174;   /* reg. 1 - Enable display, VBL, DMA + VCell size */
    *pw = 0x8230;   /* reg. 2 - Plane A =$30*$400=$C000 */
    *pw = 0x832C;   /* reg. 3 - Window  =$2C*$400=$B000 */
    *pw = 0x8407;   /* reg. 4 - Plane B =$7*$2000=$E000 */
/*    *pw = 0x855F;*/   /* reg. 5 - sprite table begins at $BE00=$5F*$200 */
    *pw = 0x855E;   /* reg. 5 - sprite table begins at $BC00=$5E*$200 */
    *pw = 0x8600;   /* reg. 6 - not used */
    *pw = 0x8700;   /* reg. 7 - Background Color number*/
    *pw = 0x8800;   /* reg. 8 - not used */
    *pw = 0x8900;   /* reg. 9 - not used */
    *pw = 0x8a01;   /* reg 10 - HInterrupt timing */
    *pw = 0x8b00;   /* reg 11 - $0000abcd a=extr.int b=vscr cd=hscr */
/*    *pw = 0x8c08;*/   /* reg 12 - hcell mode + shadow/highight + interlaced mode */
    *pw = 0x8c81;   /* reg 12 - hcell mode + shadow/highight + interlaced mode */
    *pw = 0x8d2E;   /* reg 13 - HScoll Table = $B800 */
    *pw = 0x8e00;   /* reg 14 - not used */
    *pw = 0x8f02;   /* reg 15 - auto increment data */
    *pw = 0x9011;   /* reg 16 - scrl screen v&h size */
    
    extWIDTH = 64;
    
    *pw = 0x9100;   /* reg 17 - window hpos */
    *pw = 0x92ff;   /* reg 18 - window vpos */
};

/************ init_tiles sub-program  **********/
void init_tiles()
{
    register uint x, y;
    
    dma_vram_copy(FONT_BIN+16, 0, 256*32);
    dma_vram_copy(BLOCKS_BIN, 256*32, 64*32);
    dma_vram_copy(FRAME_BIN, (256+64)*32, 64*32);
    wait_sync();

    /* Define the palettes (now we can see the fields) */
    set_colors(1, blocks_pal);
    set_colors(2, frame_pal);
}

/*************  test_joy() sub-program  ***********/
void test_joy()
{
    register uint joy;

    joy= read_joypad1();

}



/*************  redraw sub-program  ***********/
void redraw(show_plf2)
uint show_plf2;
{
	wait_sync();

	draw_playfield(&playfield1);
	draw_playfield_frame(&playfield1);
    playfield1.update_plf_frame = FALSE;
    playfield1.update_full_playfield = FALSE;

	if(show_plf2){
		draw_playfield(&playfield2);
		draw_playfield_frame(&playfield2);
    	playfield2.update_plf_frame = FALSE;
	    playfield2.update_full_playfield = FALSE;
	}
}

void play_1p_survival()
{
	init_playfield(&playfield1);
	playfield1.left = (40-playfield1.width-20) >> 1;
	plf_display_width = 20;
	plf_display_height = 9;

   	init_tiles();
	draw_picture_bkg(random(8)/2);
	draw_playfield(&playfield1);
   
    init_joypad();
	out_text(0,0,1,APLAN,"Ultimate tetris beta version");
   
    while(playfield1.game_over != 1)
   	{
        test_joy();
		handle_playfield(&playfield1,read_joypad1());
		generate_sound();
   		redraw(FALSE);

		if((read_joypad1()|read_joypad2()) & BUTTON_S){
			if(pause_menu() == 1){
				playfield1.pc_y = 0x7000;
				prepare_gameover(&playfield1);
			}
		}
    }
}

void play_versus(versus_cpu)
uint versus_cpu;
{
	init_playfield(&playfield1);
	init_playfield(&playfield2);
	playfield1.enemy = (void *)&playfield2;
	playfield2.enemy = (void *)&playfield1;
	playfield2.left = 40-playfield1.width-playfield1.left;
	plf_display_width = 10;
	plf_display_height = 9;

   	init_tiles();
	draw_fractal_bkg(random(8),random(4));
	draw_playfield(&playfield1);
	draw_playfield(&playfield2);
   
    init_joypad();
	out_text(0,0,1,APLAN,"Ultimate tetris beta version");
   
    while((playfield1.game_over != 1)||(playfield2.game_over != 1))
   	{
        test_joy();
		handle_playfield(&playfield1,read_joypad1());
		if(!versus_cpu){
			handle_playfield(&playfield2,read_joypad2());
		}else{
			handle_playfield(&playfield2,plf_ai(&playfield2));
		}
		generate_sound();
   		redraw(TRUE);

		if((read_joypad1()|read_joypad2()) & BUTTON_S){
			if(pause_menu() == 1){
				playfield1.pc_y = 0x7000;
				prepare_gameover(&playfield1);
				playfield2.pc_y = 0x7000;
				prepare_gameover(&playfield2);
			}
		}
    }

	versus_result(&playfield1,&playfield2);
}
