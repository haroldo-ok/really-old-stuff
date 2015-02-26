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



/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  CHEESE_EXT      ".chs"              /* default source file extension */


/*****************************************************************************/
/*  global variables                                                         */
/*****************************************************************************/

char         progarray[MAXPROGLEN];         /* array to hold program         */
char         filename[101];                 /* Mouse source file name        */

/*****************************************************************************/
/*                                                                           */
/*  main()                                                                   */
/*                                                                           */
/*****************************************************************************/

int main (int argc, char *argv[]) {

	cheese_envyro envyro;
    FILE  *progfile;                             /* pointer to Mouse source file  */
    
	envyro.prog = progarray;
	envyro.tracing = 0;

	/*---------------------------------------------------------------------------*/
	/*  Check command-line arguments.                                            */
	/*---------------------------------------------------------------------------*/

	if (argc != 2) {                             /* check for 1 cmd line argument */
		chs_display_str("Syntax:  CHEESE <filename>\n");   /* if not, print help message    */
		exit(0);                                 /* and return to oper system     */
	}


	/*---------------------------------------------------------------------------*/
	/*  If no file extension given, add the default extension to filename.       */
	/*---------------------------------------------------------------------------*/

	strcpy(filename, argv[1]);                  /* copy cmd line argument        */
	if (strchr(filename, (int)'.') == NULL)  {  /* if no file extension given..  */
		strcat(filename, CHEESE_EXT);           /* ..append default extension    */
    }

	/*---------------------------------------------------------------------------*/
	/*  Open mouse source file.                                                  */
	/*---------------------------------------------------------------------------*/

	if ((progfile=fopen(filename,"rb"))==NULL) { /* open Mouse source file        */
		printf("Error opening file %s\n",        /* if open error, print err msg  */
				filename);
		exit(1);                                 /* and return to operating sys   */
	}

	/*---------------------------------------------------------------------------*/
	/*  Load Mouse source file into memory, then close the source file.          */
	/*---------------------------------------------------------------------------*/

	chs_load(progfile, &envyro);                /* load program into memory      */
	fclose(progfile);                           /* close Mouse source file       */

	/*---------------------------------------------------------------------------*/
	/*  If load went OK, then define macros and run the interpreter.             */
	/*---------------------------------------------------------------------------*/

	if (!envyro.disaster) {                      /* if no load problems..         */
		chs_makedeftable(&envyro);               /* create macro definition table */
		chs_interpret(&envyro);                  /* and run interpreter           */
	}

	/*---------------------------------------------------------------------------*/
	/*  All done.  Return to operating system.                                   */
	/*---------------------------------------------------------------------------*/

	return 0;                                   /* return to operating system    */

}                                               /* end MouseInterpreter          */


