#include "genesis.h"
#include "utils.h"
#include "ultrdat.h"
#include "options.h"
#include "language.h"
#include "psgsound.h"

extern uint  extWIDTH;
extern uint  blocks_pal[];

#define _SMALTITL_WIDTH  21
#define _SMALTITL_HEIGHT  8

extern uint _smaltitl_pal[16];

uint cred_pal1[16]={
0x200,
0x000,
0x200,
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
0x0EE
};

uint cred_pal2[16]={
0x200,
0x000,
0x200,
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
0xCCC
};

uint cred_pal3[16]={
0x200,
0x000,
0x200,
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
0x0E0
};

void show_credits()
{
	register uint txt_line,bkg_y,line_dly,bkg_dly;
	char **text_ptr,*str;
	uint text_pal_num;

    set_colors(0, cred_pal1);
    set_colors(3, cred_pal3);

	/* Fonte */
    dma_vram_copy(FONT_BIN+16, 0, 256*32);
    set_colors(1, cred_pal2);

	/* Miniatura do t¡tulo */
	set_bkg_data(512,(uint)(SMALTITL_TIL_END-SMALTITL_TIL)/32,SMALTITL_TIL);
	set_bkg_tiles(20-(_SMALTITL_WIDTH >> 1),1,_SMALTITL_WIDTH,_SMALTITL_HEIGHT,SMALTITL_MAP,APLAN,512|0x4000);
    set_colors(2, _smaltitl_pal);

	out_text(CENTER_TXT(__CREDITS_CAPTION),_SMALTITL_HEIGHT+2,3,APLAN,__CREDITS_CAPTION);

	fill_bkg_rect(0,0,40,64,BPLAN,0);

	txt_line = 28;
	bkg_y	 = 0;
	line_dly = 0;
	bkg_dly	 = 0;
	text_ptr = __CREDITS_TEXT_PTR;

	while( (*text_ptr != NULL) && (!(read_joypad1()&BUTTON_S)) ){
		if(!line_dly){
			text_pal_num = 1;
			str = *text_ptr;
			if(*str == '\f'){
				text_pal_num = 0;
				str++;
			}
			fill_bkg_rect(0,txt_line,40,1,BPLAN,0);
			out_text(2,txt_line,text_pal_num,BPLAN,str);

			text_ptr++;
			txt_line++;
			txt_line &= 0x3F;
			line_dly = 32;
		}

		if(!bkg_dly){
			bkg_y--;
			scrollv(0, -bkg_y);

			bkg_dly = 4;
		}

		line_dly--;
		bkg_dly--;
		generate_sound();
		wait_sync();
	}

	line_dly = 224;
	while(line_dly && !(read_joypad1()&BUTTON_S)){
		if(!bkg_dly){
			bkg_y--;
			scrollv(0, -bkg_y);

			bkg_dly = 4;
			line_dly--;
		}

		bkg_dly--;
		generate_sound();
		wait_sync();
	}
}