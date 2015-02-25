#ifndef _INC_MISSION
#define _INC_MISSION

/*****************************************************/
/* Ultimate Tetris:									 */
/* 		Modo Miss∆o									 */
/*****************************************************/

typedef struct{
	uchar width,height;
	uchar bombs_on,extended_mode;
	uchar count_down;
	uchar special_blocks;
	uchar meta[4];
	uchar initial_speed,preview_count;
}mission_header;

extern mission_header *mishead;
extern uint mission_number, mission_timer;
extern uint mission_has_meta;

#endif
