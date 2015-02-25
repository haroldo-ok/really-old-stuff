#ifndef _INC_OPTIONS
#define _INC_OPTIONS

/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Op‡äes de jogo								 */
/*****************************************************/

#define _GAMEMODE_1P_SURVIVAL	0
#define _GAMEMODE_1P_VS_2P		1
#define _GAMEMODE_1P_VS_CPU		2
#define _GAMEMODE_MISSION		3
#define _GAMEMODE_BATTLE		4
#define _GAMEMODE_CREDITS		5

typedef struct{
	uint curr_wh_setting;
	uint width;
	uint height;
	uint bombs_on;
	uint extended_mode;
	uint initial_speed;
	uint preview_count;
}playfield_options;

typedef struct{
	uint W,H,str_index;
}wh_setting;

#define _WH_SETTINGS_COUNT 4

extern uint curr_game_mode;
extern playfield_options plf_opt[5];
extern playfield_options *curr_plf_opt;
extern wh_setting wh_settings[_WH_SETTINGS_COUNT];

void init_options();

#endif
