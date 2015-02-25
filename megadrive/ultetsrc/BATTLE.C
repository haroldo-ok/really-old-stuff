#include "genesis.h"
#include "utils.h"
#include "plyfield.h"
#include "options.h"
#include "ultrdat.h"
#include "gamebkg.h"
#include "psgsound.h"
#include "language.h"
#include "battle.h"
#include "mage_s.h"

extern playfield playfield1,playfield2;
extern uint frame_pal[16];
extern uint pal_black[16];

spr_anim_frame mage_anim[]={
/* Posi‡Æo inicial */
{0,0,0*16,35,1},
{0,0,1*16,15,2},
{0,0,2*16,15,3},
{0,0,1*16,15,0},
/* Atingido */
{0,0,0*16,15,5},
{-3,-6,3*16,7,6},
{-6,-8,3*16,7,7},
{-9,-10,4*16,7,8},
{-12,-11,4*16,15,0},
/* Ataque 1 */
{0,0,0*16,15,10},
{0,0,5*16,10,11},
{2,0,6*16,10,12},
{6,0,7*16,20,0},
/* Ataque 2 */
{0,0,0*16,15,14},
{0,0,8*16,10,15},
{2,0,9*16,10,16},
{6,0,10*16,20,0},
/* Ataque 3 */
{0,0,0*16,15,18},
{0,0,11*16,10,19},
{0,0,12*16,10,20},
{0,0,13*16,10,21},
{0,0,14*16,10,22},
{0,0,13*16,10,23},
{0,0,14*16,10,24},
{0,0,13*16,10,0},
};

battle_anim_def mage_anim_def={mage_anim,4,9,13,17,5,10,40};

void show_sprite_32x32(number,posx,posy,attr,base,offs,dest)
uint number;
int posx;
int posy;
uint attr;
ulong base;
uint offs;
uint dest;
{
	dma_vram_copy(base+((ulong)offs << 5), dest << 5, 16*32);
	def_sprite(number,posx,posy,0x0F00,attr|dest);
}

void init_spr_anim(sprnum,X,Y,base,dest,anim,mirror,def,status)
uint sprnum;
int X, Y;
ulong base;
uint dest;
spr_anim_frame *anim;
uint mirror;
battle_anim_def *def;
anim_status_rec *status;
{
	status->sprnum = sprnum;
	status->X = X;
	status->Y = Y;
	status->base = base;
	status->dest = dest;
	status->anim = anim;
	status->mirror = mirror;
	status->anim_num = 0;
	status->dly_cntr = status->anim[status->anim_num].delay;
	status->battle_def = def;
	status->enemy = NULL;
	status->enm_hit_dly_cntr = 0;
}

void set_spr_anim(status,frame)
anim_status_rec *status;
uint frame;
{
	status->anim_num = frame;
	status->dly_cntr = status->anim[status->anim_num].delay;

	if(frame == status->battle_def->anim_atk1){
		status->enm_hit_dly_cntr = status->battle_def->hit_dly1;
	}else if(frame == status->battle_def->anim_atk2){
		status->enm_hit_dly_cntr = status->battle_def->hit_dly2;
	}else if(frame == status->battle_def->anim_atk3){
		status->enm_hit_dly_cntr = status->battle_def->hit_dly3;
	}
}

void handle_spr_anim(status)
anim_status_rec *status;
{
	if(status->mirror){
	   	show_sprite_32x32(status->sprnum,
							status->X-status->anim[status->anim_num].xofs,
							status->Y+status->anim[status->anim_num].yofs,
							BUILD_ATTR(2,0,0,1),status->base,
							status->anim[status->anim_num].sprnum,
							status->dest);
	}else{
	   	show_sprite_32x32(status->sprnum,
							status->X+status->anim[status->anim_num].xofs,
							status->Y+status->anim[status->anim_num].yofs,
							BUILD_ATTR(2,0,0,0),status->base,
							status->anim[status->anim_num].sprnum,
							status->dest);
	}
	status->dly_cntr--;
	if(!status->dly_cntr){
		status->anim_num = status->anim[status->anim_num].next;
		status->dly_cntr = status->anim[status->anim_num].delay;
	}
	if(status->enm_hit_dly_cntr){
		status->enm_hit_dly_cntr--;
		if((!status->enm_hit_dly_cntr)&&(status->enemy)){
			set_spr_anim((anim_status_rec *)(status->enemy),
                         ((anim_status_rec *)(status->enemy))->battle_def->anim_hit);
		}
	}
}

void check_attack(plf,anim,joy,joywait)
playfield *plf;
anim_status_rec *anim;
uint joy;
uint *joywait;
{
	if(!(joy & (BUTTON_A|BUTTON_B|BUTTON_C))){
		*joywait = FALSE;
	}

	if(*joywait){
		return;
	}

	if(joy & BUTTON_A){
		if(plf->energy > 64){
			set_spr_anim(anim,mage_anim_def.anim_atk1);
			plf->energy -= 64;
			if (((playfield *)(plf->enemy))->life >= 10){
				((playfield *)(plf->enemy))->life -= 10;
			}else{
				((playfield *)(plf->enemy))->life = 0;
			}

			add_plf_lines((playfield *)plf->enemy,1);

			plf->update_plf_frame = TRUE;
			plf->update_full_playfield = TRUE;
			((playfield *)(plf->enemy))->update_plf_frame = TRUE;
			((playfield *)(plf->enemy))->update_full_playfield = TRUE;
		}
		*joywait = TRUE;
	}

	if(joy & BUTTON_B){
		if(plf->energy > 128){
			set_spr_anim(anim,mage_anim_def.anim_atk2);
			plf->energy -= 128;
			if (((playfield *)(plf->enemy))->life >= 20){
				((playfield *)(plf->enemy))->life -= 20;
			}else{
				((playfield *)(plf->enemy))->life = 0;
			}

			add_plf_lines((playfield *)plf->enemy,2);

			plf->update_plf_frame = TRUE;
			plf->update_full_playfield = TRUE;
			((playfield *)(plf->enemy))->update_plf_frame = TRUE;
			((playfield *)(plf->enemy))->update_full_playfield = TRUE;
		}
		*joywait = TRUE;
	}

	if(joy & BUTTON_C){
		if(plf->energy > 192){
			set_spr_anim(anim,mage_anim_def.anim_atk3);
			plf->energy -= 192;
			if (((playfield *)(plf->enemy))->life >= 40){
				((playfield *)(plf->enemy))->life -= 40;
			}else{
				((playfield *)(plf->enemy))->life = 0;
			}

			btl_stone_enm_pieces(plf);

			plf->update_plf_frame = TRUE;
			plf->update_full_playfield = TRUE;
			((playfield *)(plf->enemy))->update_plf_frame = TRUE;
			((playfield *)(plf->enemy))->update_full_playfield = TRUE;
		}
		*joywait = TRUE;
	}

}

void do_battle(){
	anim_status_rec anim1, anim2;
	uint joywait1, joywait2;
	register uint i;

	/* Inicializa‡Æo do playfield */
	curr_plf_opt->width = 10;
	curr_plf_opt->height = 26;
	curr_plf_opt->bombs_on = FALSE;
	curr_plf_opt->extended_mode = FALSE;
	curr_plf_opt->initial_speed = 2;
	curr_plf_opt->preview_count = 4;

	init_playfield(&playfield1);
	init_playfield(&playfield2);
	playfield1.enemy = (void *)&playfield2;
	playfield2.enemy = (void *)&playfield1;
	playfield2.left = 40-playfield1.width-playfield1.left;
	plf_display_width = 14;
	plf_display_height = 18;

	/* Inicializa‡Æo dos gr ficos */
   	init_tiles();
    dma_vram_copy(FRAME_B_BIN, (256+64)*32, 64*32);
	draw_fractal_bkg(random(8),random(4));
	draw_playfield(&playfield1);
	draw_playfield(&playfield2);

	for(i = 1; i != 81; i++){
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);

	/* Carrega os lutadores */   
    set_colors(2, _mage_s_pal);
    set_colors(3, _mage_s_pal);

	init_spr_anim(17,(playfield1.left+playfield1.width+2)*8,112,MAGE_S_TIL,256+128,mage_anim,0,&mage_anim_def,&anim1);
	init_spr_anim(18,(playfield2.left-6)*8,112,MAGE_S_TIL,256+128+16,mage_anim,1,&mage_anim_def,&anim2);
	anim1.enemy = (void *)&anim2;
	anim2.enemy = (void *)&anim1;

	/* In¡cio do combate */
    init_joypad();
	joywait1 = FALSE;
	joywait2 = FALSE;
	out_text(0,0,1,APLAN,"Ultimate tetris beta version");
   
    while((playfield1.game_over != 1)||(playfield2.game_over != 1))
   	{
        test_joy();
		handle_playfield(&playfield1,read_joypad1());
		handle_playfield(&playfield2,read_joypad2());
		generate_sound();

		wait_sync();

		draw_playfield(&playfield1);
		draw_battle_playfield_frame(&playfield1);
	    playfield1.update_plf_frame = FALSE;
    	playfield1.update_full_playfield = FALSE;

		draw_playfield(&playfield2);
		draw_battle_playfield_frame(&playfield2);
    	playfield2.update_plf_frame = FALSE;
	    playfield2.update_full_playfield = FALSE;

		handle_spr_anim(&anim1);
		handle_spr_anim(&anim2);
		show_sprite(1,18);

		if((read_joypad1()|read_joypad2()) & BUTTON_S){
			if(pause_menu() == 1){
				playfield1.pc_y = 0x7000;
				prepare_gameover(&playfield1);
				playfield2.pc_y = 0x7000;
				prepare_gameover(&playfield2);
			}
		}

		check_attack(&playfield1,&anim1,read_joypad1(),&joywait1);
		check_attack(&playfield2,&anim2,read_joypad2(),&joywait2);

    }

	for(i = 1; i != 81; i++){
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);
}

void test_battle(){
	register uint i, j;
	anim_status_rec anim1, anim2;

	init_tiles();

    set_colors(2, _mage_s_pal);
    set_colors(3, _mage_s_pal);

	init_spr_anim(1,32,32,MAGE_S_TIL,256+128,mage_anim,0,&mage_anim_def,&anim1);
	init_spr_anim(2,128,32,MAGE_S_TIL,256+128+16,mage_anim,1,&mage_anim_def,&anim2);
	anim1.enemy = (void *)&anim2;
	anim2.enemy = (void *)&anim1;

	while(!(read_joypad1()&BUTTON_S)){
		handle_spr_anim(&anim1);
		handle_spr_anim(&anim2);
		show_sprite(1,2);
		wait_sync();
		i = read_joypad1();
		if(i & BUTTON_A){
			set_spr_anim(&anim1,mage_anim_def.anim_atk1);
		}
		if(i & BUTTON_B){
			set_spr_anim(&anim1,mage_anim_def.anim_atk2);
		}
		if(i & BUTTON_C){
			set_spr_anim(&anim1,mage_anim_def.anim_atk3);
		}
	}
	while(read_joypad1()&BUTTON_S);

	for(i = 1; i != 81; i++){
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);
}

void play_battle_mode()
{
	do_battle();
}
