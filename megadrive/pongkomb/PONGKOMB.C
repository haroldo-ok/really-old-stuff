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
#include "rpgwalk.h"
#include "utils.h"
#include "bkgs.h"

void atract_mode();

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
		atract_mode();
	}
}

uint show_atract_screen(num)
uint num;
{
	uint joy;
	uint time;

	time = 350;

	switch(num){
		case 0:
			num = 0;
		break;

		case 1:
			num = 1;
		break;

		case 2:
			num = random(5) + 26;
		break;

		case 3:
			num = 2;
		break;

		case 4:
			num = 9;
			time = 70;
		break;

		case 5:
			num = 8;
			time = 70;
		break;

		case 6:
			num = 10;
		break;

		case 7:
			num = random(5) + 26;
		break;
	}

	load_bkgnd(num);
	joy = (read_joypad1() | read_joypad2());

	while(!(joy & BUTTON_S) && time){
		wait_sync();
		joy = (read_joypad1() | read_joypad2());
		time--;
	}
}

void atract_mode()
{
	uint joy, scr;

	joy = (read_joypad1() | read_joypad2());

	while(!(joy & BUTTON_S)){
		joy = show_atract_screen(0);

		if(!(joy & BUTTON_S)){
			for(scr = 1; (scr != 8) && !(joy & BUTTON_S); scr++){
				joy = show_atract_screen(scr);
			}
		}
	}
}
