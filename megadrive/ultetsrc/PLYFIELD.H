#ifndef _INC_PLYFIELD
#define _INC_PLYFIELD

/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Rotinas do playfield						 */
/*****************************************************/

#include "genesis.h"
#include "fracbkg.h"

/*
#define _PLF_MAXW 8
#define _PLF_MAXH 20
*/
#define _PLF_MAXW 14
#define _PLF_MAXH 30

#define _BLK_SPECIAL 6
#define _BLK_SOLID 7

#define _BLK_BOMB 8
#define _BLK_EXPLOSION 17
#define _BLK_EXPLOSION_END 23

#define _GAMEOVER_DELAY 140

typedef struct{
	char playfield[_PLF_MAXH][_PLF_MAXW];
	uint top,left,width,height;
	char piece[4][4];
	char piece_w[2];
	char piece_t,piece_b;
	char piece_preview[4][4][4];
	int  pc_x,pc_y,pcs_x,pcs_y;
	uint spdctrl,curspd;
	uint dlyctrl,rptctrl;
	uint lastjoy;
	uint cleared_lines;
	uint total_lines,line_stats[4],line_countdown[4];
	uint curr_speed,initial_speed;
	ulong score;
	char bombs_on,extended_mode;
	uint preview_count;
	uint special_blocks,reached_meta;
	uint game_over;
    char update_plf_frame,update_full_playfield;
	void *enemy;
	uint spr_pos_spd[4][4], spr_count;
	uint life, energy; /* Para o modo de batalha */
}playfield;

void init_playfield(plf);
void handle_playfield(plf,joy);
void draw_playfield(plf);

#endif
