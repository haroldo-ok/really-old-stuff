#include <stdio.h>                          /* standard i/o                  */
#include <stdlib.h>                         /* standard library              */
#include <string.h>                         /* string functions              */
#include <ctype.h>                          /* character functions           */
#include <sms.h>                            /* Sega Master System hw funcs   */

#include "rdt_conf.h"                       /* Language configurations       */
#include "rdt_defs.h"                       /* Language definitions          */
#include "rdt_cons.h"                       /* Console routines              */
#include "rdt_load.h"                       /* Program loader                */
#include "rdt_itfc.h"                       /* Machine-dependant interface   */
#include "mfs.h"                            /* SMS virtual file system       */

/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  CHEESE_EXT      ".chs"              /* default source file extension */

unsigned char pal1[] = {0x00, 0xFF, 0x08, 0x28, 0x02, 0x22, 0x0A, 0x2A,
				0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F};

void rdt_interface_init(cheese_envyro *envyro) {
	set_vdp_reg(VDP_REG_FLAGS1, VDP_REG_FLAGS1_SCREEN);
	load_tiles(standard_font, 0, 255, 1);
	load_palette(pal1, 0, 16);
	load_palette(pal1, 16, 16);
}

void rdt_interface_loadprog(cheese_envyro *envyro, char *name) {
    char fname[16];
    mfs_dir_entry *dir;
	mfs_pointer dest;

    strcpy(fname, name);
    strcat(fname, ".cho");
    strupr(fname);
    dir = mfs_find_dir_entry(fname);
    if (!dir) {
       rdt_display_str(envyro, fname);
       rdt_display_str(envyro, " not found.");
    }
    
	mfs_decode_entry(&dest, dir);
	envyro->prog = mfs_fetch(&dest);
	envyro->proglen = dir->len;
}

void rdt_interface_runprog(cheese_envyro *envyro, char *name) {
	envyro->prog = NULL;	
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
    return 32;
}

int rdt_interface_geth(cheese_envyro *envyro) {
}

void rdt_interface_outputchar(cheese_envyro *envyro, char c) {
    fputc_cons(c);
}

char rdt_interface_inputchar(cheese_envyro *envyro) {
}

int rdt_interface_inputint(cheese_envyro *envyro) {
}

int rdt_interface_inputcursor(cheese_envyro *envyro) {
}
