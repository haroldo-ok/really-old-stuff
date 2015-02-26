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

#include <stdio.h>
#include <stdlib.h>
#include "rdt_cons.h"

/*****************************************************************************/
/*                                                                           */
/*  rdt_display_envyro()                                                     */
/*                                                                           */
/*  Display an environment; used for reporting errors and tracing.           */
/*  This routine displays a line of code centered on the given pointer, with */
/*  a ^ pointing to the character at the pointer.                            */
/*                                                                           */
/*****************************************************************************/

void rdt_display_envyro(cheese_envyro *envyro, CHEESE_PTR charpos) {
	CHEESE_PTR  pos;                            /* loop index                    */
	CHEESE_PTR  j;
	int halfwidth = (rdt_interface_getw(envyro) >> 1) - 1;

	for (pos = charpos - halfwidth;             /* for HALFWIDTH chars centered..*/
	pos <= charpos + halfwidth; pos++)          /*..on current position..        */
	{
		if ((pos >= 0) && (pos < envyro->proglen)      /* if within program bounds..    */
				&& (envyro->prog[pos] >= ' '))         /*..and printable character..    */
			rdt_display_char(envyro, envyro->prog[pos]);           /* print program character       */
		else                                           /* otherwise,                    */
			rdt_display_char(envyro, ' ');             /* just print a space            */
	}
	rdt_display_char(envyro, '\n');                              /* end of line                   */
	for (j=0; j<halfwidth; j++)                 /* print spaces to position ^    */
		rdt_display_char(envyro, ' ');
	rdt_display_str(envyro, "^\n");             /* print ^ pointer               */
}                                               /* end rdt_display_envyro        */


/*****************************************************************************/
/*                                                                           */
/*  rdt_display_error()                                                      */
/*                                                                           */
/*  Report an error and set "disaster" flag to stop the interpreter.         */
/*                                                                           */
/*****************************************************************************/

void rdt_display_error(cheese_envyro *envyro, short code) {
	short  tsp;                                 /* loop counter                  */

	rdt_display_str(envyro, "\nEnvironment:\n");                 /* start new line                */
	for (tsp = 0; tsp < envyro->esp; tsp++) {   /* for each entry in env stack.. */
		rdt_display_envyro(envyro, envyro->envstack[tsp].charpos);  /* display the code at that entry*/
    }

	rdt_display_str(envyro, "Instruction pointer:\n");           /* display code at instruct ptr  */
	rdt_display_envyro(envyro, envyro->charpos);

	rdt_display_str(envyro, "Stack:");                           /* display stack contents        */
	for (tsp = 0; tsp < envyro->sp; tsp++) {
        rdt_display_char(envyro, '[');
        rdt_display_int(envyro, envyro->stack[tsp]);
        rdt_display_char(envyro, ']');
    }
    rdt_display_char(envyro, '\n');

	rdt_display_str(envyro, "***** Error ");
    rdt_display_int(envyro, code);          /* print error message           */
	rdt_display_str(envyro, ": ");

	switch (code) {                             /* select err message from list  */
	case 1 :  rdt_display_str(envyro, "Ran off end of program");           break;
	case 2 :  rdt_display_str(envyro, "Calculation stack overflowed");     break;
	case 3 :  rdt_display_str(envyro, "Calculation stack underflowed");    break;
	case 4 :  rdt_display_str(envyro, "Attempted to divide by zero");      break;
	case 5 :  rdt_display_str(envyro, "Attempted to find modulus by zero");break;
	case 6 :  rdt_display_str(envyro, "Undefined macro");                  break;
	case 7 :  rdt_display_str(envyro, "Illegal character follows \"#\"");  break;
	case 8 :  rdt_display_str(envyro, "Environment stack overflowed");     break;
	case 9 :  rdt_display_str(envyro, "Environment stack underflowed");    break;
	case 10 : rdt_display_str(envyro, "Data space exhausted");             break;
	case 11 : rdt_display_str(envyro, "Illegal character ");   
              rdt_display_char(envyro, envyro->ch);   
    break;
	case 12 : rdt_display_str(envyro, "Function name too long");           break;
	case 13 : rdt_display_str(envyro, "Unknown function");                 break;
	}  /* end case */
	rdt_display_char(envyro, '\n');
	envyro->disaster = 1;                       /* set disaster flag             */
}                                               /* end rdt_display_error         */


void rdt_display_str(cheese_envyro *envyro, char *s) {
    char *p;
    
    for (p = s; *p; p++) {
        rdt_display_char(envyro, *p);
    }
}


void rdt_display_char(cheese_envyro *envyro, char c) {
    rdt_interface_outputchar(envyro, c);
}


void rdt_display_int(cheese_envyro *envyro, int n) {
    char str[16];
    char *p = str+15;
    int neg = 0;
    int num = n;

    if (num < 0) {
        neg = 1;
        num = -num;
    }

    *p = 0;
    p--;
    *p = '0';
    
    if (n) {
        for (; num; p--, num /= 10) {
            *p = '0' + (num % 10);
        }
        
        if (neg) {
            *p = '-';
            p--;
        }
        
        p++;
    }
    
    rdt_display_str(envyro, p);
}

char rdt_input_char(cheese_envyro *envyro) {
    return rdt_interface_inputchar(envyro);
}


CHEESE_WORD rdt_input_int(cheese_envyro *envyro) {
    return rdt_interface_inputint(envyro);
}

