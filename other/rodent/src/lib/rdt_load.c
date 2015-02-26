/*****************************************************************************/
/*                                                                           */
/*                             R O D E N T                                   */
/*                                                                           */
/*  Program:      RODENT                                                     */
/*                                                                           */
/*  Programmer:   Haroldo O. Pinheiro                                        */
/*                Belo Horizonte, Minas Gerais, Brazil                       */
/*                April 10, 2007                                             */
/*                haroldoop@gmail.com                                        */
/*                                                                           */
/*  Language:     ANSI Standard C                                            */
/*                                                                           */
/*  Description:  This is an interpreter for the rodent programming          */
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

#include "rdt_conf.h"                       /* Language configurations       */
#include "rdt_defs.h"                       /* Language definitions          */
#include "rdt_cons.h"                       /* Console routines              */
#include "rdt_load.h"                       /* Program loader                */


/*****************************************************************************/
/*                                                                           */
/*  rdt_load()                                                                   */
/*                                                                           */
/*  The Loader.                                                              */
/*  This version of the loader has been optimized to remove all spaces       */
/*  except for spaces within strings and spaces separating numbers (for      */
/*  which all but one space is removed).  It also eliminates all CR/LF       */
/*  characters.  Optimizing the loader to eliminate all unnecessary          */
/*  characters greatly improves the execution speed of the interpreter.      */
/*                                                                           */
/*****************************************************************************/

void rdt_load(FILE *progfile, cheese_envyro *envyro) {
	char  lastchr;                              /* previously loaded character   */
	char  in = 0;                               /* 1=within a string             */

	for (envyro->charpos = 0; envyro->charpos < MAXPROGLEN;     /* init entire program array..   */
	                     envyro->charpos++)
        envyro->prog[envyro->charpos] = ' ';                     /* ..to all spaces               */
	rewind(progfile);                           /* position to beginning of file */
	envyro->charpos = -1;                               /* init ptr to start of memory   */
	envyro->disaster = 0;                               /* clear disaster flag           */
	envyro->ch = '~';                                   /* init first character to ~     */
	while (!(feof(progfile) || envyro->disaster)) {     /* while not eof and loading OK..*/
		lastchr = envyro->ch;                           /* save previously loaded char   */
		fread(&(envyro->ch), 1, 1, progfile);           /* read one char from Mouse file */
		if (feof(progfile)) {                           /* if end of Mouse file..        */
			break;                                      /* then break out of loop        */
        }
		if (envyro->ch == '~') {                        /* if start of comment..         */
			do {
				fread(&(envyro->ch), 1, 1, progfile);   /* ..read characters..           */
			} while (envyro->ch != '\n');               /* ..until next newline          */
		} else if (envyro->charpos < MAXPROGLEN-1) {    /* else if program memory left.. */
			envyro->charpos++;                          /* increment pointer to memory   */
			envyro->prog[envyro->charpos] = envyro->ch; /* save read character to memory */
			if (envyro->ch == '\"') {                   /* if current char is "          */
				in = !in;                               /* then toggle quote flag        */
            }
			if (envyro->ch==10 || envyro->ch==13 || envyro->ch=='\n'      /* if CR or LF or newline..      */
				|| envyro->ch=='\t' || envyro->ch=='\r') {                /* ..or tab or \r..              */
				envyro->prog[envyro->charpos] = envyro->ch = ' ';         /* ..replace with space          */
            }
			if (envyro->ch==' ' && !in &&                /* if a space not in string..    */
						!isdigit(lastchr) &&             /* ..and not after a number..    */
						(lastchr != '\'')) {             /* ..and not after a '..         */
				envyro->charpos--;                          /* then backspace pointer        */
				envyro->ch = envyro->prog[envyro->charpos]; /* update last read character    */
			} else if (!in && lastchr == ' ' &&                   /* if last char was a space and..*/
			       !isdigit(envyro->ch) && envyro->ch != '\"'     /*..this char isn't a digit..    */
			       && envyro->prog[envyro->charpos-2] != '\'') {  /*..and it isn't a quote-space.. */
                envyro->prog[--envyro->charpos] = envyro->ch;              /* then remove the last space    */
            }
		} else {                                    /* if no program memory left..   */
			rdt_display_str(envyro, "Program is too long\n");        /* print error message           */
			envyro->disaster = 1;                   /* and set disaster flag         */
		}
	}                                               /* end while                     */
	envyro->proglen = envyro->charpos + 1;          /* set total program length      */
}                                           /* end rdt_load                  */
