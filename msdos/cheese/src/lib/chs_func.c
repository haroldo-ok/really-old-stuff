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
#include "chs_fnci.h"                       /* Function implementations      */
#include "chs_func.h"                       /* Extended functions            */


chs_extended_function *chs_find_function(char *name) {
    int i, min, max, cmp;
    char *p;
    
    i = -1;
    min = 0;
    max = extended_function_count;
    while (i != min) {
        i = (min + max) >> 1;
        p = function_names[i];
        cmp = strcmp(name, p);
        if (!cmp) {
            return function_pointers[i];
        } else if (cmp < 0) {
            max = i;
        } else {
            min = i;
        }
    }
    
    return NULL;
}

void chs_execute_function(cheese_envyro *envyro, char *name) {
    chs_extended_function *func = chs_find_function(name);
    if (func) {
        (*func)(envyro, name);
    } else {
        chs_display_error(envyro, 13);
    }   
}
