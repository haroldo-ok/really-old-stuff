#include "genesis.h"
#include "pal\title1.h"
#include "pal\title2.h"
#include "pal\title3.h"
#include "pal\gameover.h"

typedef struct{
	char *charfile;
	char *mapfile;
	uint *pal;
} bkg_rec;

bkg_rec backgrounds[]={
{"TITLE1.RDC",   "TITLE1.MAP",   _title1_pal},	 /* 0 */
{"TITLE2.RDC",   "TITLE2.MAP",   _title2_pal}, 	 /* 1 */
{"TITLE3.RDC",   "TITLE3.MAP",   _title3_pal},	 /* 2 */
{"GAMEOVER.RDC", "GAMEOVER.MAP", _gameover_pal}, /* 3 */
};
bkg_rec *curr_bkg;

unsigned char huge_buffer[0x8C00]; /* 35k */

void load_bkgnd(bkgnum)
uint bkgnum;
{
	ulong tmp;

	curr_bkg = &backgrounds[bkgnum];

	get_GFS_fileaddr(&tmp, curr_bkg->charfile);
	RDC_Decompress(tmp, huge_buffer);
	set_bkg_data(256,40*28,huge_buffer);

	get_GFS_fileaddr(&tmp, curr_bkg->mapfile);
	set_bkg_tiles(0,0,40,28,tmp,BPLAN,256);

	set_colors(0,curr_bkg->pal);
}

void load_bkgnd_dly(bkgnum, dly)
uint bkgnum;
uint dly;
{
	load_bkgnd(bkgnum);
	wait_delay(dly);
}