#ifndef _INC_LANGUAGE
#define _INC_LANGUAGE

/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Suporte multilinguagem						 */
/*****************************************************/

extern uint curr_language;

void choose_language();

#define CENTER_TXT(txt) ((40-strlen2(txt)) >> 1)

#define DOUBLE_RAW_L (curr_language? DOUBLE_RAW:DUPLO_RAW)
#define DOUBLE_RAW_END_L (curr_language? DOUBLE_RAW_END:DUPLO_RAW_END)

#define TRIPLE_RAW_L (curr_language? TRIPLE_RAW:TRIPLO_RAW)
#define TRIPLE_RAW_END_L (curr_language? TRIPLE_RAW_END:TRIPLO_RAW_END)

extern char *_press_start[2];
#define __PRESS_START (_press_start[curr_language])

extern char *_game_modes[2][6];
#define __GAME_MODES(n) (_game_modes[curr_language][n])

extern char *_wh_settings[2][4];
#define __WH_SETTINGS(n) (_wh_settings[curr_language][n])

extern char *_bomb_settings[2][2];
#define __BOMB_SETTINGS(n) (_bomb_settings[curr_language][n])

extern char *_extmode_settings[2][2];
#define __EXTMODE_SETTINGS(n) (_extmode_settings[curr_language][n])

extern char *_game_over_str[2][2];
#define __GAME_OVER_STR(n) (_game_over_str[curr_language][n])

extern char *_pause_opts[2][2];
#define __PAUSE_OPTS(n) (_pause_opts[curr_language][n])

extern char *_survival_stbar[2][6];
#define __SURVIVAL_STBAR(n) (_survival_stbar[curr_language][n])

extern char *_mission_stbar[2][8];
#define __MISSION_STBAR(n) (_mission_stbar[curr_language][n])

extern char *_mission_briefing[2][5];
#define __MISSION_BRIEFING(n) (_mission_briefing[curr_language][n])

extern char *_mission_ending[2][6];
#define __MISSION_ENDING(n) (_mission_ending[curr_language][n])

extern char *_credits_caption[2];
#define __CREDITS_CAPTION (_credits_caption[curr_language])

extern char *_credits_text_ptr_prt[];
extern char *_credits_text_ptr_eng[];
#define __CREDITS_TEXT_PTR (curr_language ? _credits_text_ptr_eng : _credits_text_ptr_prt)

#endif
