#include <gb.h>
#include <string.h>
#include "brdrtil.h"
#include "brdrmap.h"
#include "brdrpal.h"

#define _SET_PAL_0_1 0x00U
#define _SET_PAL_2_3 0x08U
#define _SET_PAL_0_3 0x10U
#define _SET_PAL_1_2 0x18U

#define _SET_CHARSET 0x98U
#define _SET_SGB_MAP 0xA0U

#define _SGB_RGB(R,G,B) ((B << 10)|(G << 5)|R)

UBYTE testcommand[16]={
0x21,
0x01, 
0x01, 
0x01,
0x00, 0x00,
0x07, 0x0F,
0x00, 0x00, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00
};

UBYTE winmask_off[16]={
0xB8,
0x00, 
0x00, 0x00, 
0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00
};

UBYTE sgbcommand[16];

void sgb_transfer(UBYTE *data); //A implementa‡Æo est  em SGBTRANS.S

void set_sgb_pal(BYTE pal2set,
				 UWORD c00, UWORD c01, UWORD c02, UWORD c03,
				 UWORD c10, UWORD c11, UWORD c12, UWORD c13){

	sgbcommand[0]=pal2set|0x01U;

	*(UWORD *)(sgbcommand+1)=c00;   // (UWORD)sgbcommand[1]
	*(UWORD *)(sgbcommand+3)=c01;   // (UWORD)sgbcommand[3]
	*(UWORD *)(sgbcommand+5)=c02;   // (UWORD)sgbcommand[5]
	*(UWORD *)(sgbcommand+7)=c03;   // (UWORD)sgbcommand[7]

	*(UWORD *)(sgbcommand+ 9)=c11;  // (UWORD)sgbcommand[ 9]
	*(UWORD *)(sgbcommand+11)=c12;  // (UWORD)sgbcommand[11]
	*(UWORD *)(sgbcommand+13)=c13;  // (UWORD)sgbcommand[13]

	sgb_transfer(sgbcommand);
}

void sgb_select_area(UBYTE area_mode,
					 UBYTE out_pal, UBYTE frm_pal, UBYTE ins_pal,
					 UBYTE x1, UBYTE y1, UBYTE x2, UBYTE y2){
	sgbcommand[0]=0x21;
	sgbcommand[1]=0x01;
	sgbcommand[2]=area_mode;
	sgbcommand[3]=(out_pal<<4)|(frm_pal<<2)|ins_pal;

	sgbcommand[4]=x1;
	sgbcommand[5]=y1;
	sgbcommand[6]=x2;
	sgbcommand[7]=y2;

	sgbcommand[14]=0;
	sgbcommand[15]=0;

	sgb_transfer(sgbcommand);
}

void prepare_for_border(){
   UBYTE i,j,k;
   unsigned char buf[20];
   //
   SCX_REG = 0;
   SCY_REG = 0;
   k=0x80;
   for(i = 0; i != 13; i++){
      for(j = 0; j != 20; j++){
         buf[j] = k++;
      }
      set_bkg_tiles(0,i,20,1,buf);
   }
}

void transfer_charset(unsigned char *data, BYTE subset){
   UWORD i;
   UBYTE *dst;
   //
   dst = (void *)0x8800U;
   memcpy(dst,data,0x1000U);
   //
   memset(sgbcommand,0,16);
   sgbcommand[0] = _SET_CHARSET|0x01U;
   sgbcommand[1] = subset;
   sgb_transfer(sgbcommand);
}

void transfer_sgb_map(UWORD *data, UWORD *pal){
   UWORD i;
   UBYTE *src,*dst;
   //
   dst = (UBYTE *)0x8800U;
   memcpy(dst,data,0x0800U);
   //
   dst = (UBYTE *)0x9000U;
   memcpy(dst,pal,0x0020UL);
   memcpy(dst+0x020,pal,0x0020UL);
   memcpy(dst+0x040,pal,0x0020UL);
   memcpy(dst+0x060,pal,0x0020UL);
   //
   memset(sgbcommand,0,16);
   sgbcommand[0] = _SET_SGB_MAP|0x01U;
   sgb_transfer(sgbcommand);
}

void draw_border(){
    DISPLAY_OFF;
    LCDC_REG = 0x63;
    /*
    * LCD        = Off
    * WindowBank = 0x9C00
    * Window     = On
    * BG Chr     = 0x8800
    * BG Bank    = 0x9800
    * OBJ        = 8x8
    * OBJ        = On
    * BG         = On
    */

    disable_interrupts();

    prepare_for_border();
    transfer_charset(border_tiles,0);
    transfer_charset(border_tiles+0x1000U,1);
    transfer_sgb_map((UWORD *)border_map,(UWORD *)border_pal);

	sgb_transfer(winmask_off);

    enable_interrupts();
}
