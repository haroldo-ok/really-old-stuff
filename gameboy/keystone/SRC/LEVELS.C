#include <gb.h>
#include "keystone.h"
#include "levels.h"

/* Fase 1 */

UWORD level1_map[][6]={
{0x0009,0x0510,0x0050,0x0510,0x0000,0x0000},
{0x0079,0x0075,0x0003,0x0070,0x0000,0x0000},
{0x00B9,0x0001,0x0074,0x0003,0x0000,0x0000},
{0x0099,0x0AD0,0x00D0,0x07D0,0x0000,0x0000},
{0x00A9,0x0093,0x0090,0x0081,0x0000,0x0000},
{0x0009,0x0081,0x00C1,0x00B0,0x0000,0x0000},
{0x0099,0x0060,0x0630,0x0062,0x0000,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev1[]={
{(6*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(7*160L),_PLY_MODE_NORM}
};

/* Fase 2 */

UWORD level2_map[][6]={
{0x0009,0x0510,0x0050,0x0510,0x0000,0x0000},
{0x00A9,0x0093,0x0074,0x00B2,0x0000,0x0000},
{0x0079,0x00A1,0x0091,0x0090,0x0000,0x0000},
{0x00C9,0x07D0,0x07D0,0x08D0,0x0000,0x0000},
{0x0089,0x0074,0x00A1,0x00C3,0x0000,0x0000},
{0x0099,0x00B3,0x0093,0x00A5,0x0000,0x0000},
{0x00A9,0x0060,0x0630,0x0062,0x0000,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev2[]={
{(6*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(7*160L),_PLY_MODE_NORM}
};

/* Fase 3 */

UWORD level3_map[][6]={
{0x0009,0x0510,0x0050,0x0510,0x0000,0x0000},
{0x0079,0x0093,0x0074,0x00B2,0x0000,0x0000},
{0x0079,0x0071,0x08D0,0x08D0,0x0000,0x0000},
{0x00C9,0x0093,0x0075,0x0081,0x0000,0x0000},
{0x0089,0x0074,0x0091,0x00C3,0x0000,0x0000},
{0x0099,0x07D0,0x07D0,0x0075,0x0000,0x0000},
{0x0099,0x00B3,0x0093,0x0075,0x0000,0x0000},
{0x00A9,0x0060,0x0630,0x0062,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev3[]={
{(7*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(8*160L),_PLY_MODE_NORM}
};

/* Fase 4 */

UWORD level4_map[][6]={
{0x0009,0x0050,0x0520,0x0002,0x0000,0x0000},
{0x0079,0x0081,0x0081,0x00C1,0x0000,0x0000},
{0x0089,0x00A4,0x0075,0x0074,0x0000,0x0000},
{0x0099,0x08D0,0x0AD0,0x07D0,0x0000,0x0000},
{0x00A9,0x0075,0x00B3,0x0081,0x0000,0x0000},
{0x00B9,0x0083,0x0091,0x00A5,0x0000,0x0000},
{0x0009,0x0640,0x0060,0x0640,0x0000,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev4[]={
{((8*8L)-4),_PLY_MODE_NORM},
{_STAIR_LD,_PLY_MODE_STAIR},
{(6*160L)+(8*8L),_PLY_MODE_NORM},
{_STAIR_RD,_PLY_MODE_STAIR},
{0,_PLY_MODE_NORM}
};

/* Fase 5 */

UWORD level5_map[][6]={
{0x0009,0x0050,0x0510,0x0050,0x0510,0x0000},
{0x0079,0x0075,0x00B1,0x00B4,0x0071,0x0000},
{0x0089,0x0080,0x08D0,0x07D0,0x08D0,0x0000},
{0x00C9,0x0072,0x0892,0x00A5,0x0791,0x0000},
{0x00A9,0x0630,0x0060,0x0630,0x0062,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev5[]={
{(0*160L)+(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(4*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(0*160L),_PLY_MODE_NORM}
};

/* Fase 6 */

UWORD level6_map[][6]={
{0x0009,0x0510,0x0050,0x0510,0x0000,0x0000},
{0x00A9,0x0093,0x0794,0x00B2,0x0000,0x0000},
{0x0079,0x0A91,0x0081,0x00A0,0x0000,0x0000},
{0x07C9,0x07D0,0x07D0,0x07D0,0x0000,0x0000},
{0x0089,0x0074,0x00A1,0x08C3,0x0000,0x0000},
{0x0099,0x00B3,0x0093,0x00A5,0x0000,0x0000},
{0x09A9,0x0060,0x0630,0x0062,0x0000,0x0000},
{0x0000,0x0000,0x0000,0x0000,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev6[]={
{(6*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(7*160L),_PLY_MODE_NORM}
};

/* Fase 7 */

UWORD level7_map[][6]={
{0x0009,0x0510,0x0050,0x0510,0x0000,0x0000},
{0x0079,0x0093,0x0794,0x00B2,0x0000,0x0000},
{0x0079,0x0791,0x08D0,0x08D0,0x0000,0x0000},
{0x00C9,0x0093,0x00A5,0x0081,0x0000,0x0000},
{0x0089,0x00A4,0x0091,0x0AC3,0x0000,0x0000},
{0x0099,0x07D0,0x07D0,0x0075,0x0000,0x0000},
{0x0099,0x00B3,0x0893,0x0075,0x0000,0x0000},
{0x00A9,0x0060,0x0630,0x0062,0x0000,0x0000}
};

Thief_AI thief_waypoint_lev7[]={
{(7*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(8*160L),_PLY_MODE_NORM}
};

/* Fase 8 */

UWORD level8_map[][6]={
{0x00A9,0x0050,0x0510,0x0050,0x0510,0x0000},
{0x0079,0x0095,0x0060,0x0630,0x00A5,0x0000},
{0x00B9,0x06D0,0x0B54,0x0D50,0x0082,0x0000},
{0x0099,0x0050,0x0810,0x0075,0x00C3,0x0000},
{0x00A9,0x0093,0x0093,0x0081,0x0074,0x0000},
{0x0009,0x0084,0x00C1,0x00B3,0x0095,0x0000},
{0x0099,0x0081,0x00C1,0x00B1,0x0081,0x0000},
{0x0009,0x0630,0x0060,0x0630,0x0062,0x0000}
};

Thief_AI thief_waypoint_lev8[]={
{(5*160L)+(7*8L),_PLY_MODE_NORM},
{(4*160L)+(9*8L),_PLY_MODE_NORM}, // "Vacila" um pouco
{(7*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(3*160L)+(9*8L),_PLY_MODE_NORM},
{_STAIR_LU,_PLY_MODE_STAIR},
{(7*160L)+(7*8L),_PLY_MODE_NORM},
{_STAIR_RU,_PLY_MODE_STAIR},
{(0*160L),_PLY_MODE_NORM}
};

/* Lista das fases */

Level_Config levels[MAX_LEVELS]={
{level1_map[0],thief_waypoint_lev1,6,3,3,2,7,4},
{level2_map[0],thief_waypoint_lev2,6,3,3,2,7,4},
{level3_map[0],thief_waypoint_lev3,7,3,3,2,8,4},
{level4_map[0],thief_waypoint_lev4,0,3,0,1,7,4},
{level5_map[0],thief_waypoint_lev5,4,3,4,2,5,5},
{level6_map[0],thief_waypoint_lev6,6,3,3,2,7,4},
{level7_map[0],thief_waypoint_lev7,7,3,3,2,8,4},
{level8_map[0],thief_waypoint_lev8,7,2,4,3,8,5}
};
