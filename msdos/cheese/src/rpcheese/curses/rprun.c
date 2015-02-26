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

#include "chs_conf.h"                       /* Language configurations       */
#include "chs_defs.h"                       /* Language definitions          */
#include "chs_cons.h"                       /* Console routines              */
#include "chs_load.h"                       /* Program loader                */
#include "chs_intr.h"                       /* The interpreter itself        */
#include "rpg_conf.h"
#include "rpg_defs.h"



/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  CHEESE_EXT      ".chs"              /* default source file extension */

int main (int argc, char *argv[]) {
    char source[2048];
    
    rpg_map map;
    rpg_display_data display;
    rpg_envyro env;
    int i, j;
    char ch;
    
    memset(&env, 0, sizeof(env));

    rpg_display_init(&display);
    rpg_map_load(&display, source, 0);
    rpg_map_parse(&map, source);
    map.extra = &env;

    ch = 0;
    while (ch != 27) {
        rpg_process_command(&map, ch);
        if (map.currprog) {
            rpg_chs_run_prog(&display, &map, map.currprog);
            map.currprog = 0;
        }
        rpg_display_map(&display, &map);
        ch = getch();
    }
}


