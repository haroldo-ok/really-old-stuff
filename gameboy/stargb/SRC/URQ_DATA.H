#ifndef _URQ_DATA_H
#define _URQ_DATA_H

#include "melee.h"

#define URQUAN_SPR_TILE_COUNT 0x3C
#define URQUAN_MAX_SHOTS 0x02
#define URQUAN_MAX_FIGHTERS 0x04
#define URQUAN_SHOT_SPR_DATA 0x32
#define URQUAN_SHOT_1ST_SPR 0x09
#define URQUAN_FUSION_ENRG 0x05

typedef struct _urquan_aux_rec{
   shot_rec fusion_bolts[URQUAN_MAX_SHOTS];
   shot_rec fighters[URQUAN_MAX_FIGHTERS];
   UBYTE firing_delay;
} urquan_aux_rec;

extern unsigned char urquan_ship[];
extern UWORD urquan_palette[];

extern void handle_urquan(ship_rec *ship);
extern void urquan_init(ship_rec *ship);

#endif /*_URQ_DATA_H*/
