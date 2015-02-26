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

#include "chs_conf.h"                       /* Language configurations       */
#include "chs_defs.h"                       /* Language definitions          */
#include "chs_cons.h"                       /* Console routines              */
#include "chs_fnci.h"                       /* Function implementations      */
#include "chs_func.h"                       /* Extended functions            */

void chs_func_about(cheese_envyro *envyro, char *name) {
    chs_display_str(envyro, "Cheese VM v0.01\n");
}

void chs_func_ok(cheese_envyro *envyro, char *name) {
    chs_display_str(envyro, "OK!\n");
}

/*****************************************************************************/
/*  pointer tables                                                           */
/*****************************************************************************/

char *function_names[] = {"about","ok"};
chs_extended_function *function_pointers[] = {chs_func_about, chs_func_ok};
int extended_function_count = (sizeof(function_names) / sizeof(char *));
