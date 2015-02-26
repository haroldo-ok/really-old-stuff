#include <stdio.h>                          /* standard i/o                  */
#include <stdlib.h>                         /* standard library              */
#include <string.h>                         /* string functions              */
#include <ctype.h>                          /* character functions           */
#include <curses.h>                         /* curses terminal library       */

#include "chs_conf.h"                       /* Language configurations       */
#include "chs_defs.h"                       /* Language definitions          */
#include "chs_cons.h"                       /* Console routines              */
#include "chs_load.h"                       /* Program loader                */
#include "chs_itfc.h"                       /* Machine-dependant interface   */

/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  CHEESE_EXT      ".chs"              /* default source file extension */


void chs_interface_init(cheese_envyro *envyro) {
    chs_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    extra->imgwin = NULL;
    extra->textwin = NULL;
    
	initscr();
	start_color();	
	noecho();
	clear();
	refresh();

    chs_interface_setscreenmode(envyro, SCREEN_MODE_TEXT);
}

void chs_interface_loadprog(cheese_envyro *envyro, char *name) {
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

	chs_load(progfile, envyro);                 /* load program into memory      */
	fclose(progfile);                           /* close Mouse source file       */
}


void chs_interface_setscreenmode(cheese_envyro *envyro, int mode) {
    chs_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    
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

void chs_interface_setwrap(cheese_envyro *envyro, int mode) {
}

void chs_interface_setautopause(cheese_envyro *envyro, int mode) {
}

void chs_interface_setautoscroll(cheese_envyro *envyro, int mode) {
}

int chs_interface_clrimg(cheese_envyro *envyro) {
}

void chs_interface_setimg(cheese_envyro *envyro, int imgnum) {
}

int chs_interface_clrtxt(cheese_envyro *envyro) {
}

void chs_interface_gotoxy(cheese_envyro *envyro, int x, int y) {
}

int chs_interface_getx(cheese_envyro *envyro) {
}

int chs_interface_gety(cheese_envyro *envyro) {
}

int chs_interface_getw(cheese_envyro *envyro) {
}

int chs_interface_geth(cheese_envyro *envyro) {
}

void chs_interface_outputchar(cheese_envyro *envyro, char c) {
    chs_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    waddch(extra->textwin, c);
    wrefresh(extra->textwin);
}

char chs_interface_inputchar(cheese_envyro *envyro) {
    chs_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    wgetch(extra->textwin);
}

int chs_interface_inputint(cheese_envyro *envyro) {
    chs_extra_data *extra =  ENVYRO_EXTRA(*envyro);
    char ch = 0;
    int n = 0;
    int sig = 1;
    while (ch != '\n') {
        mvwprintw(extra->textwin, 0, 0, "%5d", sig*n);
        wrefresh(extra->textwin);
        
        ch = wgetch(extra->textwin);
        
        if (ch == '-') {
            sig = -sig;
        } else if ((ch >= '0') && (ch <= '9') && (n < 10000)) {
            n = (n * 10) + (ch - '0');
        }
    }
    
    return sig*n;
}

int chs_interface_inputcursor(cheese_envyro *envyro) {
}
