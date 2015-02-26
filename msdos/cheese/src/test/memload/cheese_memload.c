/*****************************************************************************/
/*                                                                           */
/* CHEESE Optimizer                                                          */
/*   by Haroldo O. Pinheiro                                  				 */
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




//char         *progarray = "&about&&ok&\"This is a test\\x21\\n\"0A:(A.10<^\"\\n\"A.!A.2\\[\" is odd\"|\" is even\"]A.1+A:)$";         /* array to hold program         */
char         *progarray = "\"Hello, this is a test\\n\"&about& &ok& &crash&$";         /* array to hold program         */

/*****************************************************************************/
/*                                                                           */
/*  main()                                                                   */
/*                                                                           */
/*****************************************************************************/

int main (int argc, char *argv[]) {

	cheese_envyro envyro;
    FILE  *progfile;                             /* pointer to Mouse source file  */
    FILE  *optfile;                              /* pointer to optimized source file  */

	envyro.prog = progarray;
	envyro.tracing = 0;
	envyro.proglen = strlen(progarray);

	/*---------------------------------------------------------------------------*/
	/*  If load went OK, then define macros and run the interpreter.             */
	/*---------------------------------------------------------------------------*/

    chs_makedeftable(&envyro);               /* create macro definition table */
	chs_interpret(&envyro);                  /* and run interpreter           */

	if (envyro.disaster) {                      /* if no load problems..         */
        return 1;
	}

	/*---------------------------------------------------------------------------*/
	/*  All done.  Return to operating system.                                   */
	/*---------------------------------------------------------------------------*/

	return 0;                                   /* return to operating system    */

}                                               /* end MouseInterpreter          */


