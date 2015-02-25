/* RPG GUI routines                                              */
/* by Haroldo de Oliveira Pinheiro                               */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "conio.h"
#include "string.h"
#include "rpg_gui.h"

void gui_init()
{
    ulong faddr;
	
	get_GFS_fileaddr(&faddr, "FONT.CHR");
	loadfont((uchar *)faddr+8, 1, 256, GUI_FNT_FRG, GUI_FNT_BKG);
	init_text_mode();
	text_info.attribute = GUI_FNT_ATR;

	get_GFS_fileaddr(&faddr, "INTERFC.TIL");
	set_bkg_data(GUI_TIL_BASE, GUI_TIL_CNT, faddr);
}

void gui_clear()
{
	fill_bkg_rect(0, 0, 40, 28, APLAN, 0);
}

void gui_draw_frame(x, y, w, h)
register uint x;
register uint y;
register uint w;
register uint h;
{
	fill_bkg_rect(x+1, y+1, w-2, h-2, APLAN, GUI_FRM_FILLER|GUI_FRM_ATR);

	fill_bkg_rect(x+1,   y,      w-2, 1,   APLAN, GUI_FRM_TOP   |GUI_FRM_ATR);
	fill_bkg_rect(x+1,   y+h-1,  w-2, 1,   APLAN, GUI_FRM_BOTTOM|GUI_FRM_ATR);
	fill_bkg_rect(x,     y+1,    1,   h-2, APLAN, GUI_FRM_LEFT  |GUI_FRM_ATR);
	fill_bkg_rect(x+w-1, y+1,    1,   h-2, APLAN, GUI_FRM_RIGHT |GUI_FRM_ATR);

	put_tile(GUI_FRM_TOPLEFT,     GUI_FRM_ATR, x,     y,     APLAN);
	put_tile(GUI_FRM_TOPRIGHT,    GUI_FRM_ATR, x+w-1, y,     APLAN);
	put_tile(GUI_FRM_BOTTOMLEFT,  GUI_FRM_ATR, x,     y+h-1, APLAN);
	put_tile(GUI_FRM_BOTTOMRIGHT, GUI_FRM_ATR, x+w-1, y+h-1, APLAN);
}

void gui_pager(x, y, w, h, text)
uint x;
uint y;
uint w;
uint h;
register char *text;
{
	uint tmr;
	register char *p, *mrk;
	register uint lin, col;

	x++;
	y++;
	w -= 2;
	h -= 2;

	wait_btn_release(BUTTON_A|BUTTON_B|BUTTON_C);

	/* Prints the text with word wrapping */
	while(*text){
		gui_draw_frame(x-1, y-1, w+2, h+2);
		window(x, y, x+w-1, y+h-1);
		gotoxy(1, 1);

		/* Loops until the end of the current page of text */
		p = text;
		lin = h;
		while(*p && lin){
			col = 0;	
			mrk = text;
			/* mrk will point to the end of the current line. */
			while(*p && (*p != '\n') && (col <= w)){
				if((*p == ' ') || (*p == 9)){
					mrk = p;
				}
				p++;
				col++;
			}
			if((!(*p)) || (*p == '\n')){
				mrk = p;
			}
			/* In the unlikely(?) ocurrance that a single word is longer */
			/* than the text box, prints it (the word) at its entirety.  */
			if(mrk == text){
				mrk = p;
			}

			while(text != mrk){
				putch(*text);
				text++;
			}
			putch('\n');

			if(*mrk){
				p = mrk+1;
				text = p;
			}
			lin--;
		}

		/* Waits for a keypress while showing blinking a cursor */
		tmr = 0;
		while(!((read_joypad1()|read_joypad2()) & (BUTTON_A|BUTTON_B|BUTTON_C))){
			if(tmr & 0x08){
				put_tile(GUI_FRM_MORE, GUI_FRM_ATR, x+w-1, y+h, APLAN);
			}else{
				put_tile(GUI_FRM_BOTTOM, GUI_FRM_ATR, x+w-1, y+h, APLAN);
			}
			wait_sync();
			tmr++;
		}
		wait_btn_release(BUTTON_A|BUTTON_B|BUTTON_C);
	}
}

uint gui_menu(x, y, minw, maxw, minh, maxh, options, count, albottom)
uint x;
uint y;
uint minw;
uint maxw;
uint minh;
uint maxh;
char **options;
uint count;
uint albottom;
{
	uint w, h;
	uint tmr, joy;
	uint i;
	uint k;
	uint choice;

	x++;
	y++;
	minw -= 2;
	maxw -= 2;
	minh -= 2;
	maxh -= 2;

	w = 0;
	for(i = 0; i != count; i++){
		k = strlen(options[i])+1;
		if(k > w){
			w = k;
		}
	}
	h = count;

	if(w < minw){
		w = minw;
	}
	if(w > maxw){
		w = maxw;
	}

	if(h < minh){
		h = minh;
	}
	if(h > maxh){
		h = maxh;
	}

	if(albottom){
		y = y + minh - h;
	}

	wait_btn_release(BUTTON_A|BUTTON_B|BUTTON_C|JOY_UP|JOY_DOWN);

	choice = 0;
	joy    = 0;
	while(!(joy & (BUTTON_A|BUTTON_B|BUTTON_C))){
		gui_draw_frame(x-1, y-1, w+2, h+2);
		window(x, y, x+w-1, y+h+1);
		gotoxy(1, 1);
		for(i = 0; i != count; i++){
			putch(' ');
			cputs(options[i]);
			putch('\n');
		}

		wait_btn_release(BUTTON_A|BUTTON_B|BUTTON_C|JOY_UP|JOY_DOWN);

		/* Waits for a keypress while showing blinking a cursor */
		tmr = 0;
		joy = 0;
		while(!(joy & (BUTTON_A|BUTTON_B|BUTTON_C|JOY_UP|JOY_DOWN))){
			if(tmr & 0x08){
				put_tile(GUI_FRM_CURSOR, GUI_FRM_ATR, x, y+choice, APLAN);
			}else{
				put_tile(GUI_FRM_FILLER, GUI_FRM_ATR, x, y+choice, APLAN);
			}
			wait_sync();
			tmr++;

			joy = (read_joypad1()|read_joypad2());
		}

		if((joy & JOY_UP) && (choice != 0)){
			choice--;
		}

		if((joy & JOY_DOWN) && (choice != (count-1))){
			choice++;
		}
	}
	wait_btn_release(BUTTON_A|BUTTON_B|BUTTON_C|JOY_UP|JOY_DOWN);

	return choice;
}
