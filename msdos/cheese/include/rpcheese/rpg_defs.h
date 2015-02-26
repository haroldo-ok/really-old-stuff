#ifndef _RPG_DEFS_H_
#define _RPG_DEFS_H_

#include "chs_conf.h"

#define BASE_ACTOR_CHAR 'A'
#define MAX_ACTORS 26
#define IS_ACTOR(a) (((a) >= BASE_ACTOR_CHAR) && ((a) < BASE_ACTOR_CHAR + MAX_ACTORS))

#define BASE_TILE_CHAR 'a'
#define MAX_TILES  26
#define IS_TILE(a) (((a) >= BASE_TILE_CHAR) && ((a) < BASE_TILE_CHAR + MAX_TILES))

#define MAX_LINES  32
#define FLAG_BYTE_COUNT 256
#define FLAG_COUNT ((FLAG_BYTE_COUNT) << 3)
#define GLOBAL_VARS_COUNT 256

typedef struct _rpg_actor {
        int x, y;                            /* Actor's coordinates on the map */
        char tile;                           /* Actor's tile                   */
        char tile_below;                     /* Tile at actor's feet           */
        int prog_number;                     /* Actor's program number         */
        char *prog_parms;                    /* Pointer to program parameters  */
} rpg_actor;

typedef struct _rpg_tile {
        char tile;                           /* Tile                          */
        int prog_number;                     /* Tile's program number         */
        char *prog_parms;                    /* Pointer to program parameters  */
} rpg_tile;

typedef struct _rpg_map {
        int width, height;                   /* Map's width and height    */
        char *source;                        /* Map's "source"            */
        char *data;                          /* Map data, 1 char per tile */

        #ifdef DYNAMIC_LINE_POINTERS
        char **line_ptrs;                    /* Pointers to the start of each line */
        #else
        char *line_ptrs[MAX_LINES];          /* Pointers to the start of each line */
        #endif

        int mainprog;                        /* Map's main program number    */
        int currprog;                        /* Map's current program number */
        char *prog_parms;                    /* Map's current program params */
        rpg_actor player;                    /* Players actor                */
        rpg_actor actors[MAX_ACTORS];        /* Map's actor list             */
        rpg_tile  tiles[MAX_TILES];          /* Map's tile types list        */

        void *extra;                         /* Additional, implementation-dependant, data*/
} rpg_map;

typedef struct _rpg_envyro {
        char flag_bytes[FLAG_BYTE_COUNT];
        CHEESE_WORD global_vars[GLOBAL_VARS_COUNT]; 
} rpg_envyro;

#endif /* _RPG_DEFS_H_ */
