#include "genesis.h"
#include "sprhand.h"
#include "pal\bkg01.h"

typedef struct{
	char *charfile;
	char *mapfile;
	uint *pal;
} bkg_rec;

bkg_rec backgrounds[]={
{"BKG01_T.RDC",   "BKG01_M.RDC",   _bkg01_pal}	/* 0 */
};

bkg_rec *curr_bkg;

void load_bkgnd(bkgnum)
uint bkgnum;
{
	ulong tmp;

	curr_bkg = &backgrounds[bkgnum];

	get_GFS_fileaddr(&tmp, curr_bkg->charfile);
	RDC_Decompress(tmp, huge_buffer);
	set_bkg_data(578,830,huge_buffer);

	get_GFS_fileaddr(&tmp, curr_bkg->mapfile);
	RDC_Decompress(tmp, huge_buffer);
	set_bkg_tiles(0,0,40,28,huge_buffer,BPLAN,BUILD_ATTR(0,0,0,0)+578);

	set_colors(0,curr_bkg->pal);
}
