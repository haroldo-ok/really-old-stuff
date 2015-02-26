#include "genesis.h"
#include "pal\intro3.h"
#include "pal\intro4.h"
#include "pal\intro5.h"
#include "pal\select.h"
#include "pal\select0.h"
#include "pal\spewm.h"
#include "pal\spews.h"
#include "pal\table2.h"
#include "pal\taunt.h"
#include "pal\tauntb.h"
#include "pal\winner1.h"
#include "pal\winner2.h"
#include "pal\winner3.h"
#include "pal\winner4.h"
#include "pal\winner5.h"
#include "pal\zone1.h"
#include "pal\zone2.h"
#include "pal\zone2s.h"
#include "pal\zone3.h"
#include "pal\zone3s.h"
#include "pal\zone4.h"
#include "pal\zone5.h"
#include "pal\zone6.h"
#include "pal\zone7.h"
#include "pal\zone8.h"
#include "pal\taunta.h"
#include "pal\redbio.h"
#include "pal\greenbio.h"
#include "pal\bluebio.h"
#include "pal\yellbio.h"
#include "pal\purpbio.h"

typedef struct{
	char *charfile;
	char *mapfile;
	uint *pal;
} bkg_rec;

bkg_rec backgrounds[]={
{"INTRO3.RDC",   "INTRO3.MAP",   _intro3_pal},	/* 0 */
{"INTRO4.RDC",   "INTRO4.MAP",   _intro4_pal},	/* 1 */
{"INTRO5.RDC",   "INTRO5.MAP",   _intro5_pal},	/* 2 */
{"SELECT.RDC",   "SELECT.MAP",   _select_pal},	/* 3 */
{"SELECT0.RDC",  "SELECT0.MAP",  _select0_pal},	/* 4 */
{"SPEWM.RDC",    "SPEWM.MAP",    _spewm_pal},	/* 5 */
{"SPEWS.RDC",    "SPEWS.MAP",    _spews_pal},	/* 6 */
{"TABLE2.RDC",   "TABLE2.MAP",   _table2_pal},	/* 7 */
{"TAUNT.RDC",    "TAUNT.MAP",    _taunt_pal},	/* 8 */
{"TAUNTA.RDC",   "TAUNTA.MAP",   _taunta_pal},	/* 9 */
{"TAUNTB.RDC",   "TAUNTB.MAP",   _tauntb_pal},	/* 10 */
{"WINNER1.RDC",  "WINNER1.MAP",  _winner1_pal},	/* 11 */
{"WINNER2.RDC",  "WINNER2.MAP",  _winner2_pal},	/* 12 */
{"WINNER3.RDC",  "WINNER3.MAP",  _winner3_pal},	/* 13 */
{"WINNER4.RDC",  "WINNER4.MAP",  _winner4_pal},	/* 14 */
{"WINNER5.RDC",  "WINNER5.MAP",  _winner5_pal},	/* 15 */
{"ZONE1.RDC",    "ZONE1.MAP",    _zone1_pal},	/* 16 */
{"ZONE2.RDC",    "ZONE2.MAP",    _zone2_pal},	/* 17 */
{"ZONE2S.RDC",   "ZONE2S.MAP",   _zone2S_pal},	/* 18 */
{"ZONE3.RDC",    "ZONE3.MAP",    _zone3_pal},	/* 19 */
{"ZONE3S.RDC",   "ZONE3S.MAP",   _zone3S_pal},	/* 20 */
{"ZONE4.RDC",    "ZONE4.MAP",    _zone4_pal},	/* 21 */
{"ZONE5.RDC",    "ZONE5.MAP",    _zone5_pal},	/* 22 */
{"ZONE6.RDC",    "ZONE6.MAP",    _zone6_pal},	/* 23 */
{"ZONE7.RDC",    "ZONE7.MAP",    _zone7_pal},	/* 24 */
{"ZONE8.RDC",    "ZONE8.MAP",    _zone8_pal},	/* 25 */
{"REDBIO.RDC",   "REDBIO.MAP",   _redbio_pal},	/* 26 */
{"BLUEBIO.RDC",  "BLUEBIO.MAP",  _bluebio_pal},	/* 27 */
{"YELLBIO.RDC",  "YELLBIO.MAP",  _yellbio_pal},	/* 28 */
{"GREENBIO.RDC", "GREENBIO.MAP", _greenbio_pal}, /* 29 */
{"PURPBIO.RDC",  "PURPBIO.MAP",  _purpbio_pal}	/* 30 */
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
