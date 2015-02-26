#ifndef _INC_COSMCARK_

#define _INC_COSMCARK_

#define ANGLE_NORTH 0
#define ANGLE_SOUTH 128
#define ANGLE_EAST 192
#define ANGLE_WEST 64

#define ANGLE_NORTHWEST 32
#define ANGLE_SOUTHWEST 96
#define ANGLE_NORTHEAST 224
#define ANGLE_SOUTHEAST 160

#define PLAYFIELD_WIDTH (48*16)
#define PLAYFIELD_HEIGHT (48*16)

extern sprite_rec *player;
extern uint level;
extern ulong score;

void kill_player();

#endif
