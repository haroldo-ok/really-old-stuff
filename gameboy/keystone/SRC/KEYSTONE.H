#ifndef _KEYSTONE_H
#define _KEYSTONE_H

#include "levels.h"

typedef struct _actor{
   WORD X,Y;
   UBYTE sprnum,baseframe,frame;
   WORD XSpd,YSpd;
   UBYTE mirror;
   UBYTE palette;
}actor;

#define MAX_ACTORS  10
#define MAX_ENEMIES 6

#define _PLY_MODE_NORM  0
#define _PLY_MODE_STAIR 1
#define _PLY_MODE_ELEV  2

#define _MAP_BKG_MASK 0x000FU
#define _MAP_BKG_BITS 4
#define _MAP_OBJ_MASK 0x000FU
#define _MAP_OBJ_BITS 4
#define _MAP_STAIR_LU 0x0001U
#define _MAP_STAIR_LD 0x0002U
#define _MAP_STAIR_RU 0x0003U
#define _MAP_STAIR_RD 0x0004U
#define _MAP_WALL_L   0x0005U
#define _MAP_WALL_R   0x0006U
#define _MAP_ENM_CAR  0x0007U
#define _MAP_ENM_BALL 0x0008U
#define _MAP_ENM_RAD  0x0009U
#define _MAP_ENM_PLNE 0x000AU
#define _MAP_ITM_CASE 0x000BU
#define _MAP_ITM_MNY  0x000CU
#define _MAP_ELEV     0x000DU

typedef struct _stair{
   UBYTE X,Y,kind;
}stair;

#define _STAIR_NO 0
#define _STAIR_LU 1
#define _STAIR_LD 2
#define _STAIR_RU 3
#define _STAIR_RD 4

typedef struct _enemy{
   UBYTE kind;
   UWORD max_y;
   actor enm_actor;
}enemy;

#define _ENM_NONE  0
#define _ENM_CAR   1
#define _ENM_BALL  2
#define _ENM_RADIO 3
#define _ENM_PLANE 4
#define _ENM_CASE  5
#define _ENM_MONEY 6

typedef struct _side_wall{
   UBYTE kind;
}side_wall;

#define _WAL_NONE 0
#define _WAL_LEFT 1
#define _WAL_RIGHT 2

typedef struct _elevator{
   unsigned char floors[6];
   UBYTE curr_floor;
   BYTE updown;
   UBYTE curr_frame;
   UBYTE delay;
}elevator;

extern UBYTE elev_frame_map[];

#define _SND_NONE  0
#define _SND_STEP  1
#define _SND_JUMP  2
#define _SND_HIT   3
#define _SND_BONUS 4
#define _SND_DEAD  5
#define _SND_TIMBN 6
#define _SND_XLIFE 7
#define _SND_PAUSE 8

extern void do_sound(UBYTE id);

extern UBYTE frame_ctrl,stair_frame_ctrl,elev_frame_ctrl;
extern UBYTE timer,subtimer;
extern UBYTE lives;
extern UWORD score,last_score;
extern UBYTE sndmode,sndctrl;
extern WORD global_x,global_y;
extern WORD scn_x,scn_y;
extern WORD player_max_y;
extern WORD thief_max_y;
extern WORD global_max_y;
extern UBYTE current_room;
extern UBYTE player_floor;
extern UBYTE player_mode;
extern UBYTE player_death;
extern UBYTE thief_floor;
extern UBYTE thief_mode;
extern UBYTE thief_caught;
extern UBYTE thief_curr_waypoint;
extern Thief_AI *thief_waypoint_list;
extern UBYTE curr_level_num;
extern Level_Config *curr_level;
extern UWORD main_map[8][6];
extern elevator elevators[8];
extern side_wall wall_list[6];
extern stair stair_list[6];
extern enemy enemy_list[MAX_ENEMIES];
extern actor Player,Thief;
extern actor *actor_list[MAX_ACTORS];

#endif // _KEYSTONE_H
