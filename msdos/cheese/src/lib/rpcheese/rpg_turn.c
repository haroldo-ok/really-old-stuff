#include "rpg_defs.h"

char rpg_map_get_tile(rpg_map *map, int x, int y) {
    return map->line_ptrs[y][x];
}

char rpg_map_get_tile_type_prog(rpg_map *map, char ch, char *ttype, int *prognum, char **params) {
    int depth = 4;
    rpg_actor *act;
    rpg_tile *tile;
    
    *ttype = ch;
    *prognum = 0;
    *params = 0;
    while ((*ttype != '#') && (*ttype != '.') && (depth)) {
        if (IS_ACTOR(*ttype)) {
            act = map->actors + (*ttype - BASE_ACTOR_CHAR);
            *prognum = act->prog_number;
            *params = act->prog_parms;
            if (*prognum < 0) {
                *ttype = -(*prognum);
                *prognum = 0;
            } else {
                *ttype = '#';
            }
        } else if (IS_TILE(*ttype)) {
            tile = map->tiles + (*ttype - BASE_TILE_CHAR);
            *prognum = tile->prog_number;
            *params = tile->prog_parms;
            if (*prognum < 0) {
                *ttype = -(*prognum);
                *prognum = 0;
            } else {
                *ttype = '.';
            }
        } else {
            *ttype = '.';
        }
        depth--;
    }
}

char rpg_map_get_tile_type(rpg_map *map, char ch) {
    char newch;
    int prognum;
    char *progparms;
    
    rpg_map_get_tile_type_prog(map, ch, &newch, &prognum, &progparms);
    
    return newch;
}

void rpg_map_set_tile(rpg_map *map, int x, int y, char tile) {
    map->line_ptrs[y][x] = tile;
}

void rpg_map_locate_player(rpg_map *map) {
    int i, j;
    char ch;
    
    for (i = 0; i != map->height; i++) {
        for (j = 0; j != map->width; j++) {
            ch = rpg_map_get_tile(map, j, i);
            if (ch == '@') {
                map->player.x = j;
                map->player.y = i;
                return;
            }
        }
    }
}

void rpg_map_move_player(rpg_map *map, int xofs, int yofs) {
    char ch, tiletype;
    int prognum;
    char *progparms;
    int newx = map->player.x + xofs;
    int newy = map->player.y + yofs;

    ch = rpg_map_get_tile(map, newx, newy);

    rpg_map_get_tile_type_prog(map, ch, &tiletype, &prognum, &progparms);
    if (prognum > 0) {
        map->currprog = prognum;
        map->prog_parms = progparms;
    }
    if (tiletype == '#') {
        return;
    }
    
    rpg_map_set_tile(map, map->player.x, map->player.y, map->player.tile_below);
    map->player.tile_below = ch;
        
    rpg_map_set_tile(map, newx, newy, '@');
    
    map->player.x = newx;
    map->player.y = newy;
}

void rpg_map_teleport_player(rpg_map *map, int x, int y) {
    int xofs = 0;
    int yofs = 0;     
     
    rpg_map_locate_player(map);
    if (x != -1) {
       xofs = x - map->player.x;
    }
    if (y != -1) {
       yofs = y - map->player.y;
    }
    rpg_map_move_player(map, xofs, yofs);
    rpg_map_locate_player(map);
}

void rpg_process_command(rpg_map *map, int cmd) {
    if ((map->player.x < 0) || (map->player.y < 0)) {
        rpg_map_locate_player(map);
    }
    
    if (cmd == '8') {
        rpg_map_move_player(map, 0, -1);
    } else if (cmd == '2') {
        rpg_map_move_player(map, 0, 1);
    } else if (cmd == '4') {
        rpg_map_move_player(map, -1, 0);
    } else if (cmd == '6') {
        rpg_map_move_player(map, 1, 0);
    }
}
