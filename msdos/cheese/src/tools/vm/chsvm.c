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




/*****************************************************************************/
/*                                                                           */
/*  main()                                                                   */
/*                                                                           */
/*****************************************************************************/

int main (int argc, char *argv[]) {
    char progarray[MAXPROGLEN];
    
    chs_extra_data extra;
	cheese_envyro envyro;

	envyro.prog = progarray;
	envyro.tracing = 0;
	envyro.extra = &extra;
	
	chs_interface_init(&envyro);
	chs_interface_loadprog(&envyro, "main");
	if (envyro.disaster) {                      /* if no load problems..         */
        return 1;
	}

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


