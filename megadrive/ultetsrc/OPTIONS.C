#include "genesis.h"
#include "ultrdat.h"
#include "plyfield.h"
#include "options.h"

uint curr_game_mode;

playfield_options plf_opt[5], *curr_plf_opt;

wh_setting wh_settings[_WH_SETTINGS_COUNT]={
	{10,22,0},
	{ 8,20,1},
	{12,26,2},
	{ 8,22,3}
};

void init_options()
{
	register uint i;

	for(i = 0; i != 4; i++){
		plf_opt[i].curr_wh_setting = 0;
		plf_opt[i].width = _PLF_MAXW;
		plf_opt[i].height = _PLF_MAXH;
		plf_opt[i].bombs_on = FALSE;
		plf_opt[i].extended_mode = FALSE;
		plf_opt[i].initial_speed = 0;
		plf_opt[i].preview_count = 4;
	}
	curr_plf_opt = plf_opt;
}
