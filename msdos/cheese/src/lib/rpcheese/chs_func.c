/*****************************************************************************/
/*                                                                           */
/*                             C H E E S E                                   */
/*                                                                           */
/*  Program:      CHEESE                                                     */
/*                                                                           */
/*  Programmer:   Haroldo O. Pinheiro                                        */
/*                Belo Horizonte, Minas Gerais, Brazil                       */
/*                April 10, 2007                                             */
/*                haroldoop@gmail.com                                        */
/*                                                                           */
/*  Language:     ANSI Standard C                                            */
/*                                                                           */
/*  Description:  This is an interpreter for the cheese programming          */
/*                language, a variant of the mouse programming language      */
/*                designed for being embedded inside other programs.         */
/*                                                                           */
/*  Version:      1.00                                                       */
/*                                                                           */
/*  Notes:        This interpreter is based on David G. Simpson's mouse83,   */
/*                with some additional features inspired by mouse2000, by    */
/*                the same author, which, in turn, came from the original    */
/*                Pascal  implementation in "Mouse: A Language for           */
/*                Microcomputers" by Peter Grogono.                          */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/*  #includes                                                                */
/*****************************************************************************/

#include <stdio.h>                          /* standard i/o                  */
#include <stdlib.h>                         /* standard library              */
#include <string.h>                         /* string functions              */
#include <ctype.h>                          /* character functions           */

#include "rpg_conf.h"

#include "chs_conf.h"                       /* Language configurations       */
#include "chs_defs.h"                       /* Language definitions          */
#include "chs_cons.h"                       /* Console routines              */
#include "chs_intr.h"                       /* Interpreter routines          */
#include "chs_func.h"                       /* Extended functions            */


/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define EXTENDED_FUNCTION_COUNT 8

/*****************************************************************************/
/*  pointer table references                                                 */
/*****************************************************************************/

extern char *function_names[];
extern chs_extended_function *function_pointers[];

chs_extended_function *chs_find_function(char *name) {
    int i, min, max, cmp;
    char *p;
    
    min = 0;
    max = EXTENDED_FUNCTION_COUNT;
    while (min != max) {
        i = (min + max) >> 1;
        p = function_names[i];
        cmp = strcmp(name, p);
        if (!cmp) {
            return function_pointers[i];
        } else if (cmp < 0) {
            max = i;
        } else {
            min = i;
        }
    }
    
    return NULL;
}

void chs_execute_function(cheese_envyro *envyro, char *name) {
    chs_extended_function *func = chs_find_function(name);
    if (func) {
        (*func)(envyro, name);
    } else {
        chs_display_error(envyro, 13);
    }   
}

void chs_func_about(cheese_envyro *envyro, char *name) {
    chs_display_str(envyro, "RPCheese v0.01\n");
}

void chs_func_get_flag(cheese_envyro *envyro, char *name) {
     int index = chs_pop(envyro);
     int value = ENVYRO_EXTRA(*envyro)->env->flag_bytes[index >> 3];
     int state = (value >> (index & 0x07)) & 0x01;
     chs_push(envyro, state);
}

void chs_func_get_int(cheese_envyro *envyro, char *name) {
     int index = chs_pop(envyro);
     int value = ENVYRO_EXTRA(*envyro)->env->global_vars[index];
     chs_push(envyro, value);
}

void chs_func_loadmap(cheese_envyro *envyro, char *name) {
    int nextmap = chs_pop(envyro);
    rpg_map *map = ENVYRO_EXTRA(*envyro)->map;
    
    rpg_map_load(ENVYRO_EXTRA(*envyro)->display, map->source, nextmap);
    rpg_map_parse(map, map->source);
}

void chs_func_pause(cheese_envyro *envyro, char *name) {
    chs_display_pause(envyro);
}

void chs_func_set_flag(cheese_envyro *envyro, char *name) {
     int index = chs_pop(envyro);
     int bitshift = index & 0x07;
     int value = (chs_pop(envyro) != 0 ? 0x01 : 0x00);
     char mask = ~(0x01 << bitshift);
     char temp = ENVYRO_EXTRA(*envyro)->env->flag_bytes[index >> 3];     
     temp = (temp & mask) | (value << bitshift);
     ENVYRO_EXTRA(*envyro)->env->flag_bytes[index >> 3] = temp;
}

void chs_func_set_int(cheese_envyro *envyro, char *name) {
     int index = chs_pop(envyro);
     int value = chs_pop(envyro);
     ENVYRO_EXTRA(*envyro)->env->global_vars[index] = value;
}

void chs_func_teleport_player(cheese_envyro *envyro, char *name) {
    int y = chs_pop(envyro);
    int x = chs_pop(envyro);
    rpg_map *map = ENVYRO_EXTRA(*envyro)->map;

    rpg_map_teleport_player(map, x, y);
}

/*****************************************************************************/
/*  pointer tables                                                           */
/*****************************************************************************/

char *function_names[] = {"about", "gf", "gi", "loadmap", "pause", "sf", "si", "teleptply"};
chs_extended_function *function_pointers[] = {chs_func_about, 
                                              chs_func_get_flag, chs_func_get_int, 
                                              chs_func_loadmap, chs_func_pause,
                                              chs_func_set_flag, chs_func_set_int,
                                              chs_func_teleport_player};
