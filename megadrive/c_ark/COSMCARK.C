/*
	Minimal Example
		by Haroldo de Oliveira pinheiro
*/
/*
 *
 * A Plan Adr = c000
 * window adr = b000
 * B Plan adr = e000
 * sprite adr = bc00
 * HScrol adr = b800
 *
 */

#include "genesis.h"
#include "utils.h"
#include "psgsound.h"
#include "conio.h"
#include "rdc.h"
#include "utils.h"
#include "bkgs.h"
#include "sprhand.h"
#include "pal\mtrship.h"
#include "cosmcark.h"

uint char1_pal[]={
0x000,
0x200,
0x400,
0x600,
0x800,
0xA00,
0x002,
0x004,
0x006,
0x008,
0x00A,
0x00C,
0x026,
0x268,
0x0AC,
0x0AE
};

uint zorp_pal[]={
0x000,
0x000,
0x040,
0x080,
0x0A0,
0x0C0,
0xEEE,
0x004,
0x006,
0x008,
0x00A,
0x00C,
0x026,
0x268,
0x0AC,
0x0AE
};

uint snd_saucer1[] = {
   SET_VOLX+8,
   SET_TONEX+400,
   SET_TONEX+300,
   SET_TONEX+200,
   SET_TONEX+100,
   SET_TONEX+200,
   SET_TONEX+300,
   END_SOUND
};

uint snd_saucer2[] = {
   SET_VOLX+8,
   SET_TONEX+200,
   SET_TONEX+150,
   SET_TONEX+100,
   SET_TONEX+50,
   SET_TONEX+100,
   SET_TONEX+150,
   END_SOUND
};

uint snd_beam1[] = {
   SET_TONEX+100,
   SET_VOLX+12,
   DELAY+3,
   END_SOUND
};

uint snd_beam2[] = {
   SET_TONEX+50,
   SET_VOLX+12,
   DELAY+3,
   END_SOUND
};

uint snd_capture1[] = {
   SET_TONEX+400,
   SET_VOLX+12,
   SET_TONEX+350,
   SET_TONEX+300,
   SET_TONEX+250,
   SET_TONEX+200,
   SET_TONEX+150,
   SET_TONEX+100,
   SET_TONEX+50,
   SET_VOLX+0,
   END_SOUND
};

uint snd_mothership1[] = {
   SET_TONEX+300,
   SET_VOLX+12,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+9,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+6,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+3,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+0,
   END_SOUND
};

uint snd_mothership2[] = {
   SET_TONEX+500,
   SET_VOLX+3,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+6,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+9,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_VOLX+12,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+500, DELAY+1,
   SET_TONEX+400, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_TONEX+200, DELAY+1,
   SET_TONEX+300, DELAY+1,
   SET_VOLX+0,
   END_SOUND
};

uchar beam_ctrl;
sprite_rec saucer, abductee[2];

void atract_mode();
void game_loop1();
void game_loop2();

void main()
{
    register uint i,j,joy;

    /* Initialize Genesis GFX registers */
    init_GFX();

    /* Wait until GFX reg are initialized */
    wait_sync();

	/* Inicializa o Sega Genesis File System */
	init_GFS();

	init_joypad();

	/* Loop principal */
	while(TRUE){
		game_loop2();
		game_loop1();
	}
}

void load_mothership()
{
	ulong tmp;

	tileset_load_RDC("MTRSHP_T.RDC", 456, 122);

	get_GFS_fileaddr(&tmp, "MTRSHP_M.RDC");
	RDC_Decompress(tmp, huge_buffer);
	set_bkg_tiles(5,0,30,6,huge_buffer,APLAN,BUILD_ATTR(3,1,0,0)+456);
}

void atract_mode()
{
	uint joy, scr;

	joy = (read_joypad1() | read_joypad2());

	while(!(joy & BUTTON_S)){
		joy = (read_joypad1() | read_joypad2());

		if(!(joy & BUTTON_S)){
			for(scr = 1; (scr != 8) && !(joy & BUTTON_S); scr++){
				joy = (read_joypad1() | read_joypad2());
			}
		}
	}
}

void move_saucer(saucer, joy)
register sprite_rec *saucer;
register uint joy;
{
	saucer->stance = 0;

	/* I know I should use shifts instead of mul/div, but I'm lazy 8-) */
    if(saucer->posy < 28){
	    if(saucer->posx < 120){
			saucer->posx = 120;
			saucer->xaccel = -saucer->xaccel*2/3;
    	}
	    if(saucer->posx > 168){
			saucer->posx = 168;
			saucer->xaccel = -saucer->xaccel*2/3;
    	}
		if(saucer->posy < 8){
			saucer->posy = 8;
			saucer->yaccel = -saucer->yaccel*2/3;
		}
    }else if((saucer->posy < 32) && 
             ( (saucer->posx < 120) || 
               (saucer->posx > 168)    )){
		saucer->posy = 32;
		saucer->yaccel = -saucer->yaccel*2/3;
    }

    if(saucer->posx < 0){
		saucer->posx = 0;
		saucer->xaccel = -saucer->xaccel*2/3;
   	}
    if(saucer->posx > 288){
		saucer->posx = 288;
		saucer->xaccel = -saucer->xaccel*2/3;
   	}

    if(saucer->posy > 140){
		saucer->posy = 140;
		saucer->yaccel = -saucer->yaccel*2/3;
    }

	if(joy & JOY_LEFT){
		saucer->xaccel -= 0x18;
		saucer->stance = 120;
	} 
    if(joy & JOY_RIGHT){
		saucer->xaccel += 0x18;
		saucer->stance = 160;
	}

	if(joy & JOY_UP){
		saucer->yaccel -= 0x18;
		saucer->stance = 40;
	} else if(joy & JOY_DOWN){
		saucer->yaccel += 0x18;
		saucer->stance = 80;
	}

	beam_ctrl &= 0x7F;
	saucer->xfric = 0x04;
	saucer->yfric = 0x04;
	if(joy & (BUTTON_A|BUTTON_B|BUTTON_C)){
		beam_ctrl |= 0x80;

		saucer->xfric = 0x14;
		saucer->yfric = 0x14;
	}

	if(!saucer->stance){
		if(!(vtimer&0x07)){
			start_sound(1, snd_saucer1);
		}
	}else{
		if(!(vtimer&0x07)){
			start_sound(1, snd_saucer2);
		}
	}

	if(beam_ctrl & 0x80){
		if(!(vtimer&0x07)){
			start_sound(2, snd_beam1);
		}
	}else{
		set_vol(2, 0);
	}
}

void draw_beam()
{
	register uint i;
	register uint x, y;

	if(beam_ctrl & 0x80){
		if(beam_ctrl & 0x01){
			x = saucer.posx+8;
			y = saucer.posy+8;
			for(i = 2; i != 8; i++){
				def_sprite(i, x, y, 0x700, 248);
				y += 32;
			}
		}
		beam_ctrl++;
		beam_ctrl &= 0x7F;
	}
}

void move_abductee(abductee)
register sprite_rec *abductee;
{
	register int n;

	if(abductee->posx < 0){
		abductee->posx = 0;
		abductee->xaccel = -abductee->xaccel*2/3;
		abductee->xgrav = -abductee->xgrav;
    }
	if(abductee->posx > 304){
		abductee->posx = 304;
		abductee->xaccel = -abductee->xaccel*2/3;
		abductee->xgrav = -abductee->xgrav;
    }

/*    if(abductee->posy < 0){
		abductee->posy = 0;
		abductee->yaccel = 0;
    }*/
    if(abductee->posy > 200){
		abductee->posy = 200;
		abductee->yaccel = 0;
    }

	n = random(0x100);
	if(n < 0x07){
		if(n & 0x01){
			abductee->stance = 8;
			abductee->xgrav = 0x1F;
		}else{
			abductee->stance = 0;
			abductee->xgrav = -0x1F;
		}
	}

	if(abductee->xgrav > 0){
		abductee->stance = 8;
	}else{
		abductee->stance = 0;
	}

	abductee->xfric = 0x00;
	abductee->ygrav = 0x1F;
	if(beam_ctrl & 0x80){
		n = abductee->posx-saucer.posx-2;
		if((n > 0) && (n < 12)){
			abductee->stance = 16;
			abductee->xfric = 0x4A;
			abductee->ygrav = -0x07;

			if(!(vtimer&0x07)){
				start_sound(2, snd_beam2);
			}
		}

		n = abductee->posy-saucer.posy-2;
		if((n > 0) && (n < 12)){
			abductee->posy = -32;
			start_sound(3, snd_capture1);
		}
	}
}

void game_loop1()
{
	register uint joy;
	register uint i, j;

	RAZ();

	tileset_load_RDC("ZORP.RDC", 224, 24);
	tileset_load_RDC("BEAM.RDC", 248, 8);
	tileset_load_RDC("SAUCER.RDC", 256, 200);
	load_mothership();
	load_bkgnd(0);

	beam_ctrl = 0;

	sprite_init(&saucer, 1, 16, 16, 0xD00, BUILD_ATTR(1,0,0,0)|256, 8);
	saucer.posx    = 144;
	saucer.posy    = 16;
	saucer.stance  = 0;
	saucer.frm_cnt = 5;
	saucer.frm_spd = 0x3FL;
	saucer.xfric   = 0x04;
	saucer.yfric   = 0x04;
	saucer.xmaxac  = 0x400;
	saucer.ymaxac  = 0x400;

	for(i = 0; i != 2; i++){
		sprite_init(&abductee[i], i+9, random(320), 200, 0x500, BUILD_ATTR(2,0,0,0)|224, 4);
		abductee[i].frm_cnt = 3;
		abductee[i].frm_spd = 0x1FL;
		abductee[i].xgrav 	= -0x1FL;
		abductee[i].ygrav 	= 0x1FL;
		abductee[i].xmaxac  = 0x200;
	}

	scrollv(70, 0);
	sprite_prepare();

	set_vol(1, 0);
	set_vol(2, 0);
	set_vol(3, 0);

    set_colors(1, char1_pal);
    set_colors(2, zorp_pal);
    set_colors(3, _mtrship_pal);

	start_sound(2, snd_mothership1);

	for(j = 70; j; j--){
		for(i = 0; i != 2; i++){
			if(abductee[i].posy > 0){
				move_abductee(&abductee[i]);
				sprite_move(&abductee[i]);
				sprite_draw(&abductee[i]);
			}
		}

		wait_sync();
		scrollv(j, 0);
		show_sprite(1,80);
		sprite_prepare();
	}

	saucer.yaccel = 0xFF;

	for(j = 70; j; j--){
		sprite_move(&saucer);
		sprite_draw(&saucer);

		for(i = 0; i != 2; i++){
			if(abductee[i].posy > 0){
				move_abductee(&abductee[i]);
				sprite_move(&abductee[i]);
				sprite_draw(&abductee[i]);
			}
		}

		wait_sync();
		show_sprite(1,80);
		sprite_prepare();
	}

	while(saucer.posy > 20){
		joy = (read_joypad1() | read_joypad2());

		move_saucer(&saucer, joy);

		sprite_move(&saucer);
		sprite_draw(&saucer);

		for(i = 0; i != 2; i++){
			if(abductee[i].posy > 0){
				move_abductee(&abductee[i]);
				sprite_move(&abductee[i]);
				sprite_draw(&abductee[i]);
			}
		}

		draw_beam();		

		wait_sync();
		show_sprite(1,80);
		sprite_prepare();
	}

	set_vol(1, 0);
	set_vol(2, 0);
	set_vol(3, 0);

	start_sound(2, snd_mothership2);

	for(j = 0; j != 70; j++){
		for(i = 0; i != 2; i++){
			if(abductee[i].posy > 0){
				move_abductee(&abductee[i]);
				sprite_move(&abductee[i]);
				sprite_draw(&abductee[i]);
			}
		}

		wait_sync();
		scrollv(j, 0);
		show_sprite(1,80);
		sprite_prepare();
	}
}

void game_loop2()
{
	register uint joy;
	register uint i, j;
	ulong tmp;

	RAZ();

	init_text_mode();
	text_info.attribute = BUILD_ATTR(3,0,0,0) >> 8;

	get_GFS_fileaddr(&tmp, "FONT.CHR");
	loadfont((uchar *)tmp,0,256,15,0);

	load_mothership();

	beam_ctrl = 0;

	scrollv(70, 0);
	sprite_prepare();

	set_vol(1, 0);
	set_vol(2, 0);
	set_vol(3, 0);

    set_colors(3, _mtrship_pal);

	start_sound(2, snd_mothership1);

	for(j = 70; j != -88; j--){
		wait_sync();
		scrollv(j, 0);
		show_sprite(1,80);
		sprite_prepare();
	}

	set_vol(1, 0);
	set_vol(2, 0);
	set_vol(3, 0);

	cputs("         COSMIC ARK DEMO v1.0\n");
	cputs("    by Haroldo de Oliveira Pinheiro\n");
	cputs("         haroldoop@ig.com.br\n");
	cputs("    members.fortunecity.com/haroldoop\n");

	gotoxy(1, 22);

	cputs("              made for the\n");
	cputs("     2004 Summer Coding Competition\n");
	cputs("www.emulationzone.org/projects/metalix/\n");

	for(j = 210; j; j--){
		wait_sync();
	}

	start_sound(2, snd_mothership2);

	for(j = -88; j != 70; j++){
		for(i = 0; i != 2; i++){
			if(abductee[i].posy > 0){
				move_abductee(&abductee[i]);
				sprite_move(&abductee[i]);
				sprite_draw(&abductee[i]);
			}
		}

		wait_sync();
		scrollv(j, 0);
		show_sprite(1,80);
		sprite_prepare();
	}
}
