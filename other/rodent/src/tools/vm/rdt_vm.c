/*****************************************************************************/
/*                                                                           */
/* RODENT Virtual Machine                                                    */
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

#include "rdt_conf.h"                       /* Language configurations       */
#include "rdt_defs.h"                       /* Language definitions          */
#include "rdt_cons.h"                       /* Console routines              */
#include "rdt_load.h"                       /* Program loader                */
#include "rdt_intr.h"                       /* The interpreter itself        */




/*****************************************************************************/
/*                                                                           */
/*  main()                                                                   */
/*                                                                           */
/*****************************************************************************/

int main () {
    rdt_extra_data extra;
	cheese_envyro envyro;

	envyro.prog = NULL;
	envyro.tracing = 0;
	envyro.extra = &extra;
	
	rdt_interface_init(&envyro);
	rdt_interface_runprog(&envyro, "main");

	if (envyro.disaster) {                      /* if no load problems..         */
        return 1;
	}

	/*---------------------------------------------------------------------------*/
	/*  All done.  Return to operating system.                                   */
	/*---------------------------------------------------------------------------*/

	return 0;                                   /* return to operating system    */

}                                               /* end MouseInterpreter          */


