#include <stdio.h>                          /* standard i/o                  */
#include <stdlib.h>                         /* standard library              */
#include <string.h>                         /* string functions              */
#include <ctype.h>                          /* character functions           */
#include <curses.h>                         /* curses terminal library       */

#include "rdt_conf.h"                       /* Language configurations       */
#include "rdt_defs.h"                       /* Language definitions          */
#include "rdt_cons.h"                       /* Console routines              */
#include "rdt_load.h"                       /* Program loader                */
#include "rdt_itfc.h"                       /* Machine-dependant interface   */

/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  CHEESE_EXT      ".chs"              /* default source file extension */


void rdt_interface_init(cheese_envyro *envyro) {
    rdt_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    extra->imgwin = NULL;
    extra->textwin = NULL;
    
	initscr();
	start_color();	
	noecho();
	clear();
	refresh();

	init_pair(1, COLOR_WHITE, COLOR_BLACK);
	init_pair(2, COLOR_WHITE, COLOR_BLUE);

    rdt_interface_setscreenmode(envyro, SCREEN_MODE_TEXT);
}

void rdt_interface_loadprog(cheese_envyro *envyro, char *name) {
    FILE  *progfile;                             /* pointer to Mouse source file  */    
    char         filename[101];                  /* Mouse source file name        */

	/*---------------------------------------------------------------------------*/
	/*  If no file extension given, add the default extension to filename.       */
	/*---------------------------------------------------------------------------*/

	strcpy(filename, name);                  /* copy cmd line argument        */
	if (strchr(filename, (int)'.') == NULL)  {  /* if no file extension given..  */
		strcat(filename, CHEESE_EXT);           /* ..append default extension    */
    }

	/*---------------------------------------------------------------------------*/
	/*  Open mouse source file.                                                  */
	/*---------------------------------------------------------------------------*/

	if ((progfile=fopen(filename,"rb"))==NULL) { /* open Mouse source file        */
		printf("Error opening file %s\n",        /* if open error, print err msg  */
				filename);
		envyro->disaster = 1;
		return;
	}

	/*---------------------------------------------------------------------------*/
	/*  Load Mouse source file into memory, then close the source file.          */
	/*---------------------------------------------------------------------------*/

	rdt_load(progfile, envyro);                 /* load program into memory      */
	fclose(progfile);                           /* close Mouse source file       */
}

void rdt_interface_runprog(cheese_envyro *envyro, char *name) {
    char progarray[MAXPROGLEN];   
	
	envyro->prog = progarray;	
	envyro->disaster = 0;
	rdt_interface_loadprog(envyro, name);
	if (envyro->disaster) {                      /* if no load problems..         */
        return;
	}
	
	/*---------------------------------------------------------------------------*/
	/*  If load went OK, then define macros and run the interpreter.             */
	/*---------------------------------------------------------------------------*/

    rdt_makedeftable(envyro);               /* create macro definition table */
	rdt_interpret(envyro);                  /* and run interpreter           */
}

void rdt_interface_setscreenmode(cheese_envyro *envyro, int mode) {
    rdt_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    
    endwin();
    extra->imgwin = NULL;
    extra->textwin = NULL;
     
    switch (mode) {
    case SCREEN_MODE_TEXT:
         extra->textwin = newwin(LINES, COLS, 0, 0);
         break;
         
    case SCREEN_MODE_SPLIT:
         extra->imgwin = newwin(LINES-9, COLS, 0, 0);
         extra->textwin = newwin(8, COLS, LINES-8, 0);
         break;
         
    case SCREEN_MODE_IMAGE:
         extra->imgwin = newwin(LINES, COLS, 0, 0);
         break;         
    }
}

void rdt_interface_setwrap(cheese_envyro *envyro, int mode) {
}

void rdt_interface_setautopause(cheese_envyro *envyro, int mode) {
}

void rdt_interface_setautoscroll(cheese_envyro *envyro, int mode) {
}

int rdt_interface_clrimg(cheese_envyro *envyro) {
}

void rdt_interface_setimg(cheese_envyro *envyro, int imgnum) {
}

int rdt_interface_clrtxt(cheese_envyro *envyro) {
}

void rdt_interface_gotoxy(cheese_envyro *envyro, int x, int y) {
}

int rdt_interface_getx(cheese_envyro *envyro) {
}

int rdt_interface_gety(cheese_envyro *envyro) {
}

int rdt_interface_getw(cheese_envyro *envyro) {
}

int rdt_interface_geth(cheese_envyro *envyro) {
}

void rdt_interface_outputchar(cheese_envyro *envyro, char c) {
    rdt_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    waddch(extra->textwin, c);
    wrefresh(extra->textwin);
}

char rdt_interface_inputchar(cheese_envyro *envyro) {
    rdt_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    wgetch(extra->textwin);
}

int rdt_interface_inputint(cheese_envyro *envyro) {
    rdt_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    WINDOW *win;
    int x, y;
    
   	getyx(extra->textwin, y, x);
    
    win = newwin(1, 8, y, x);
	wbkgd(win, COLOR_PAIR(2));
	werase(win);
    
    char ch = 0;
    int n = 0;
    int sig = 1;
    while (ch != '\n') {
        mvwprintw(win, 0, 2, "%5d", sig*n);
        wrefresh(win);
        
        ch = wgetch(win);
        
        if (ch == '-') {
            sig = -sig;
        } else if ((ch >= '0') && (ch <= '9') && (n < 10000)) {
            n = (n * 10) + (ch - '0');
        }
    }
    werase(win);
    delwin(win);
    
	touchwin(extra->textwin);
    wrefresh(extra->textwin);
    
    return sig*n;
}

int rdt_interface_inputcursor(cheese_envyro *envyro) {
}
