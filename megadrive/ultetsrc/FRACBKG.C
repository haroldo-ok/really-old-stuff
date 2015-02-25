#include "genesis.h"
#include "utils.h"
#include "ultetris.h"
#include "ultrdat.h"
#include "fracbkg.h"
#include "backg1.h"
#include "backg2.h"
#include "backg3.h"
#include "backg4.h"
#include "backm1.h"
#include "backm2.h"
#include "backm3.h"
#include "backm4.h"

extern uint extWIDTH;

uint fractal_icy_pal[16]={
0x600,
0x620,
0x820,
0x842,
0xA42,
0xA62,
0xC64,
0xC84,
0xE84,
0xEA6,
0xEC6,
0xEC8,
0xECA,
0xEEA,
0xEEC,
0xEEE
};
uint fractal_grn_pal[16]={
0x200,
0x220,
0x420,
0x440,
0x640,
0x660,
0x860,
0x880,
0xA80,
0xAA2,
0xCA4,
0xCC6,
0xEC8,
0xEEA,
0xEEC,
0xEEE
};
/*
uint fractal_pal[16]={
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000,
0x000
};
*/
uint fractal_fir_pal[16]={
0x002,
0x004,
0x006,
0x008,
0x00A,
0x00C,
0x00E,
0x02E,
0x04E,
0x06E,
0x08E,
0x0AE,
0x0CE,
0x0EE,
0x2EE,
0x4EE
};
uint fractal_yel_pal[16]={
0x002,
0x022,
0x024,
0x044,
0x046,
0x066,
0x068,
0x088,
0x08A,
0x2AA,
0x4AC,
0x6CC,
0x8CE,
0xAEE,
0xCEE,
0xEEE
};

uint *frac_pals[4]={
fractal_icy_pal,
fractal_grn_pal,
fractal_fir_pal,
fractal_yel_pal
};

ulong frac_til[8][2]={
{FRACTL1_TIL,FRACTL1_TIL_END},
{FRACTL2_TIL,FRACTL2_TIL_END},
{FRACTL3_TIL,FRACTL3_TIL_END},
{FRACTL4_TIL,FRACTL4_TIL_END},
{FRACTL5_TIL,FRACTL5_TIL_END},
{FRACTL6_TIL,FRACTL6_TIL_END},
{FRACTL7_TIL,FRACTL7_TIL_END},
{FRACTL8_TIL,FRACTL8_TIL_END}
};

ulong frac_map[8]={
FRACTL1_MAP,
FRACTL2_MAP,
FRACTL3_MAP,
FRACTL4_MAP,
FRACTL5_MAP,
FRACTL6_MAP,
FRACTL7_MAP,
FRACTL8_MAP
};

void draw_fractal_bkg(frac_num,pal_num)
uint frac_num;
uint pal_num;
{
	register uint i,j;
    register ulong *pl;
    register uint *pw;
	register ulong k;
	register uint *mp;

	/* seta a palheta */
    set_colors(0, frac_pals[pal_num]);

	/* Copia os caracteres da imagem */
	for(i = 512*32, mp = (uint *)frac_til[frac_num][0];
		mp < (uint *)frac_til[frac_num][1];
		i += 32*32, mp += 32*32/2){
		dma_vram_copy(mp, i, 32*32);
	}

	/* Mapeia a imagem no background B */
	mp = (uint *)frac_map[frac_num];
	for(i = 0; i != 28; i++){
	    k = BPLAN + (  2 * (extWIDTH*i) ); 
	    pl = (ulong *) GFXCNTL;
	    *pl = GFX_WRITE_ADDR(k);

	    pw = (uint *) GFXDATA;
		for(j = 0; j != 40; j++){
			*pw = ((*mp++)+512)|BUILD_ATTR(0,0,0,0);
		}
    }
}

uint *pic_pals[]={_backg1_pal,_backg2_pal,_backg3_pal,_backg4_pal};
ulong pic_til_addrs[][2]={
{BACKG1_TIL,(BACKG1_TIL_END-BACKG1_TIL)/32},
{BACKG2_TIL,(BACKG2_TIL_END-BACKG2_TIL)/32},
{BACKG3_TIL,(BACKG3_TIL_END-BACKG3_TIL)/32},
{BACKG4_TIL,(BACKG4_TIL_END-BACKG4_TIL)/32}
};
ulong pic_map_addrs[]={BACKG1_MAP,BACKG2_MAP,BACKG3_MAP,BACKG4_MAP};

void draw_picture_bkg(pic_num)
uint pic_num;
{
	uint i;

	set_colors(0, pic_pals[pic_num]);
	set_bkg_data(512,(uint)pic_til_addrs[pic_num][1],(uint *)pic_til_addrs[pic_num][0]);
	set_bkg_tiles(0,0,40,28,pic_map_addrs[pic_num],BPLAN,512);
	scrollv(0,0);
	scrollh(0,0);
	for(i = 1; i != 81; i++){
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);
}

uint *mis_pals[]={_backm1_pal,_backm2_pal,_backm3_pal,_backm4_pal};
ulong mis_til_addrs[][2]={
{BACKM1_TIL,(BACKM1_TIL_END-BACKM1_TIL)/32},
{BACKM2_TIL,(BACKM2_TIL_END-BACKM2_TIL)/32},
{BACKM3_TIL,(BACKM3_TIL_END-BACKM3_TIL)/32},
{BACKM4_TIL,(BACKM4_TIL_END-BACKM4_TIL)/32}
};
ulong mis_map_addrs[]={BACKM1_MAP,BACKM2_MAP,BACKM3_MAP,BACKM4_MAP};

void draw_mission_bkg(pic_num)
uint pic_num;
{
	uint i;

	set_bkg_data(512,(uint)mis_til_addrs[pic_num][1],(uint *)mis_til_addrs[pic_num][0]);
	set_bkg_tiles(0,0,40,28,mis_map_addrs[pic_num],BPLAN,512);
/*	scrollv(0,0); */
	scrollh(0,0); 
/*	set_colors(0, mis_pals[pic_num]); */
	fade_in(mis_pals[pic_num], 0);
	for(i = 1; i != 81; i++){
		def_sprite(i,-32,-32,0,0);
	}
	show_sprite(1,80);
}

