#ifndef _RANDMAP_H
#define _RANDMAP_H

#define RANDMAP_ROOM_CNT_X 4
#define RANDMAP_ROOM_CNT_Y 4
#define RANDMAP_ROOM_COUNT RANDMAP_ROOM_CNT_Y*RANDMAP_ROOM_CNT_X

#define RANDMAP_ROOM_MIN_W 10
#define RANDMAP_ROOM_MIN_H 10

typedef struct{
	uint top;
	uint left;
	uint width;
	uint height;
} randmap_room;

void randmap_build();

#endif /* _RANDMAP_H */
