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
#include <sms.h>                            /* Sega Master System functions  */

#include "chs_conf.h"                       /* Language configurations       */
#include "chs_defs.h"                       /* Language definitions          */
#include "chs_cons.h"                       /* Console routines              */
#include "chs_load.h"                       /* Program loader                */
#include "chs_intr.h"                       /* The interpreter itself        */


unsigned char pal1[] = {0x00, 0x20, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
				0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F};


//char         *progarray = "&about&&ok&\"This is a test\\x21\\n\"0A:(A.10<^\"\\n\"A.!A.2\\[\" is odd\"|\" is even\"]A.1+A:)$";         /* array to hold program         */
char         *progarray = "\"This is a test\"$";         /* array to hold program         */

/*****************************************************************************/
/*                                                                           */
/*  main()                                                                   */
/*                                                                           */
/*****************************************************************************/

void main () {

//	cheese_envyro envyro;
//    FILE  *progfile;                             /* pointer to Mouse source file  */
    //FILE  *optfile;                              /* pointer to optimized source file  */

	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN);
	load_tiles(standard_font, 0, 255, 1);
	load_palette(pal1, 0, 16);
	load_palette(pal1, 16, 16);

	set_bkg_map(main, 0, 0, 32, 26);

	printf("Hello, stdio!\nIs it working?\nI hope so.");
	gotoxy(5, 5);
	printf("Hello, gotoxy(%d, %d)!", 5, 5);

	for (;;) {
		wait_vblank_noint();
	}

/*
	set_vdp_reg(VDP_REG_HINT_COUNTER, 0x0F);
	set_vdp_reg(VDP_REG_FLAGS0, VDP_REG_FLAGS0_SYNC | VDP_REG_FLAGS0_CHANGE);
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN | VDP_REG_FLAGS1_VINT);
	load_tiles(standard_font, 0, 255, 1);
	load_palette(pal1, 0, 16);
	load_palette(pal1, 16, 16);

	gotoxy(0,0);

    printf("init");

	envyro.prog = progarray;
	envyro.tracing = 0;
	envyro.proglen = strlen(progarray);

	/*---------------------------------------------------------------------------*/
	/*  If load went OK, then define macros and run the interpreter.             */
	/*---------------------------------------------------------------------------*/
/*
    printf("deftable");
    chs_makedeftable(&envyro);               /* create macro definition table */
/*    printf("inter");
	chs_interpret(&envyro);                  /* and run interpreter           */
/*    printf("ok");

	if (envyro.disaster) {                      /* if no load problems..         */
/*        return 1;
	}

	/*---------------------------------------------------------------------------*/
	/*  All done.  Return to operating system.                                   */
	/*---------------------------------------------------------------------------*/

	return 0;                                   /* return to operating system    */

}                                               /* end MouseInterpreter          */


