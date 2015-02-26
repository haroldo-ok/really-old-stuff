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

char source[] =
"A: . 3\r\n\
B: x a\r\n\
a: 2\n\
b: a\n\
map:\n\
 #####\n\
  #...#\n\
  #.@.#\n\
  #...#\n\
 #ABC#\n\
 #abc#\n\
 #####\n\
  \n\
c: #\n\
\n\n\
$";

void debg(int n, int n2) {
    char str[32], *o;
    int buf[32], *d;

    buf[0] = n;    
    buf[2] = n2;    
    set_bkg_map(buf, 0, 16, 32, 1);    
}

int main (int argc, char *argv[]) {
//    char source[2048];
    char sourcecpy[sizeof(source)];
    rpg_map map;
    rpg_display_data display;
    int i, j;
    char ch;
    UBYTE joy;
    
    strcpy(sourcecpy, source);

    rpg_display_init(&display);
    rpg_map_parse(&map, sourcecpy);
    
    ch = 0;
    while (ch != 27) {
        rpg_process_command(&map, ch);
        if (map.currprog) {
            rpg_chs_run_prog(&display, &map, map.currprog);
            map.currprog = 0;
        }
        
		wait_vblank_noint();
        rpg_display_map(&display, &map);
        
        ch = 0;
        while (!ch) {
            joy = read_joypad1();        
            if (joy & JOY_UP) {
                ch = '8';
            } else if (joy & JOY_DOWN) {
                ch = '2';
            } else if (joy & JOY_LEFT) {
                ch = '4';
            } else if (joy & JOY_RIGHT) {
                ch = '6';
            }
        }
        while (joy & (JOY_UP|JOY_DOWN|JOY_LEFT|JOY_RIGHT)) {
            wait_vblank_noint();
            joy = read_joypad1();        
        }
    }
}


