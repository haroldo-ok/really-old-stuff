/*****************************************************************************/
/*                                                                           */
/*                            R P C H E E S E                                */
/*                                                                           */
/*  Program:      RPCHEESE                                                   */
/*                                                                           */
/*  Programmer:   Haroldo O. Pinheiro                                        */
/*                Belo Horizonte, Minas Gerais, Brazil                       */
/*                April 18, 2007                                             */
/*                haroldoop@gmail.com                                        */
/*                                                                           */
/*  Language:     ANSI Standard C                                            */
/*                                                                           */
/*****************************************************************************/

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "rpg_defs.h"

int rpgp_is_newline(char c) {
    return (c == 10) || (c == 13);
}

int rpgp_is_space(char c) {
    return isspace(c) && !rpgp_is_newline(c);
}

void rpgp_skip_spaces(char **p) {
    while (rpgp_is_space(**p)) {
        (*p)++;
    }
}

void rpgp_skip_nonspaces(char **p) {
    while (!isspace(**p)) {
        (*p)++;
    }
}

void rpgp_skip_newline(char **p) {
    if (**p == 13) { // CR
        (*p)++;
        if (**p == 10) { // CRLF
            (*p)++;
        }
    } else if (**p == 10) { // LF
        (*p)++;
    }
}

void rpgp_skip_to_newline(char **p) {
    while (!rpgp_is_newline(**p)) {
        (*p)++;
    }
}

char *rpgp_find_char(char *p, char c) {
    while (!rpgp_is_newline(*p)) {
        if (*p == c) {
            return p;
        }
        p++;
    }
    return NULL;
}

int rpgp_line_length(char *p) {
    int len = 0;
    while (*p && !rpgp_is_newline(*p)) {
        len++;
        p++;
    }
    return len;
}

int rpgp_copy_until_char(char *d, char *o, char c, int n) {
     char *sep;
     int len;

     sep = rpgp_find_char(o, ':');

     for (len = 0; (o != sep) && (len != n); o++, d++, len++) {
             *d = *o;
     }
     *d = 0;

     return len;
}

void rpgp_parse_property(rpg_map *map, char **p) {
     char cmd[16];
     int len;
     int temp;
     char ch, *ptemp;
     rpg_actor *act;
     rpg_tile *tile;

     len = rpgp_copy_until_char(cmd, *p, ':', 15);

     *p += len + 1;
     if (len == 1) {
         if (*cmd == '@') {
         } else if ((*cmd >= BASE_ACTOR_CHAR) && (*cmd < BASE_ACTOR_CHAR + MAX_ACTORS)) {
            rpgp_skip_spaces(p);
            ch = **p;
            (*p)++;
            rpgp_skip_spaces(p);
            if (isdigit(**p)) {
				temp = atoi(*p);
            } else {
                temp = -(**p);
            }
            act = map->actors + (*cmd - BASE_ACTOR_CHAR);
            act->x = -2;
            act->y = -2;
            act->tile = *cmd;
            act->tile_below = ch;
            act->prog_number = temp;
            rpgp_skip_nonspaces(p);
            act->prog_parms = *p;
         } else if ((*cmd >= BASE_TILE_CHAR) && (*cmd < BASE_TILE_CHAR + MAX_TILES)) {
            rpgp_skip_spaces(p);
            if (isdigit(**p)) {
				temp = atoi(*p);
            } else {
                temp = -(**p);
            }
            tile = map->tiles + (*cmd - BASE_TILE_CHAR);
            tile->tile = *cmd;
            tile->prog_number = temp;
            rpgp_skip_nonspaces(p);
            tile->prog_parms = *p;
         }
     } else {
         if (!strcmp("map", cmd)) {
            map->data = *p;

            rpgp_skip_spaces(p);
            if (rpgp_is_newline(**p)) {
               rpgp_skip_newline(p);
               rpgp_skip_spaces(p);
            }
            do {
               map->line_ptrs[map->height] = *p;
               temp = rpgp_line_length(*p);
               if (temp > map->width) {
                   map->width = temp;
               }
               map->height++;

               rpgp_skip_to_newline(p);
               rpgp_skip_newline(p);
               rpgp_skip_spaces(p);
            } while (!rpgp_is_newline(**p));
         }
     }
}

void rpg_map_init(rpg_map *map) {
    rpg_actor *act;
    rpg_tile *tile;
    char ch;
    int i;

    map->width  = 0;
    map->height = 0;

    map->player.x = -1;
    map->player.y = -1;
    map->player.tile_below = '.';
    
    map->mainprog = 0;
    map->currprog = 0;
    
    for (i = MAX_ACTORS, ch = BASE_ACTOR_CHAR, act = map->actors; i; i--, ch++, act++) {
        act->prog_number = 0;
        act->tile = ch;
        act->tile_below = '.';
        act->x = -1;
        act->y = -1;
    }
    
    for (i = MAX_TILES, ch = BASE_TILE_CHAR, tile = map->tiles; i; i--, ch++, tile++) {
        tile->prog_number = 0;
        tile->tile = ch;
    }
}
     
void rpg_map_parse(rpg_map *map, char *src) {
    char *p = src;
    
    map->source = src;
    rpg_map_init(map);

    rpgp_skip_spaces(&p);
    while (*p != '$') {
        if (isalpha(*p)) {
            rpgp_parse_property(map, &p);
        }
        rpgp_skip_to_newline(&p);
        rpgp_skip_newline(&p);
        rpgp_skip_spaces(&p);
    }
}
