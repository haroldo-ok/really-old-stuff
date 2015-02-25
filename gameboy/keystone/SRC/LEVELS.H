#ifndef _LEVELS_H
#define _LEVELS_H

typedef struct _Thief_AI{
   UWORD dest;
   UBYTE mode;
}Thief_AI;

typedef struct _Level_Config{
   UWORD *map;
   Thief_AI *AI;
   UBYTE ply_start_room, thief_start_room;
   UBYTE ply_start_floor, thief_start_floor;
   UBYTE room_count,floor_count;
}Level_Config;

#define MAX_LEVELS 8

extern Level_Config levels[MAX_LEVELS];

#endif // _LEVELS_H
