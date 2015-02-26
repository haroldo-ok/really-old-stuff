#include <stdio.h>                          /* standard i/o                  */
#include <stdlib.h>                         /* standard library              */
#include <string.h>                         /* string functions              */
#include <ctype.h>                          /* character functions           */

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


void rdt_interface_setscreenmode(cheese_envyro *envyro, int mode) {
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
    putch(c);
}

char rdt_interface_inputchar(cheese_envyro *envyro) {
    return getchar();
}

int rdt_interface_inputint(cheese_envyro *envyro) {
    int value;
    scanf("%d", &value);
    return value;
}

int rdt_interface_inputcursor(cheese_envyro *envyro) {
}
