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

#include <stdio.h>
#include "chs_cons.h"

/*****************************************************************************/
/*                                                                           */
/*  chs_display_envyro()                                                     */
/*                                                                           */
/*  Display an environment; used for reporting errors and tracing.           */
/*  This routine displays a line of code centered on the given pointer, with */
/*  a ^ pointing to the character at the pointer.                            */
/*                                                                           */
/*****************************************************************************/

void chs_display_envyro(cheese_envyro *envyro, CHEESE_PTR charpos) {
	CHEESE_PTR  pos;                            /* loop index                    */
	CHEESE_PTR  j;

	for (pos = charpos - HALFWIDTH;             /* for HALFWIDTH chars centered..*/
	pos <= charpos + HALFWIDTH; pos++)          /*..on current position..        */
	{
		if ((pos >= 0) && (pos < envyro->proglen)      /* if within program bounds..    */
				&& (envyro->prog[pos] >= ' '))         /*..and printable character..    */
			printf("%c", envyro->prog[pos]);           /* print program character       */
		else                                           /* otherwise,                    */
			printf(" ");                               /* just print a space            */
	}
	printf ("\n");                              /* end of line                   */
	for (j=0; j<HALFWIDTH; j++)                 /* print spaces to position ^    */
		printf(" ");
	printf("^\n");                              /* print ^ pointer               */
}                                               /* end chs_display_envyro        */


/*****************************************************************************/
/*                                                                           */
/*  chs_display_error()                                                      */
/*                                                                           */
/*  Report an error and set "disaster" flag to stop the interpreter.         */
/*                                                                           */
/*****************************************************************************/

void chs_display_error(cheese_envyro *envyro, short code) {
	short  tsp;                                 /* loop counter                  */

	printf("\nEnvironment:\n");                 /* start new line                */
	for (tsp = 0; tsp < envyro->esp; tsp++) {   /* for each entry in env stack.. */
		chs_display_envyro(envyro, envyro->envstack[tsp].charpos);  /* display the code at that entry*/
    }

	printf("Instruction pointer:\n");           /* display code at instruct ptr  */
	chs_display_envyro(envyro, envyro->charpos);

	printf("Stack:");                           /* display stack contents        */
	for (tsp = 0; tsp < envyro->sp; tsp++) {
		printf(" [%1d]", envyro->stack[tsp]);
    }
	printf("\n");

	printf ("***** Error %d: ", code);          /* print error message           */
	switch (code) {                             /* select err message from list  */
	case 1 :  printf("Ran off end of program");             break;
	case 2 :  printf("Calculation stack overflowed");       break;
	case 3 :  printf("Calculation stack underflowed");      break;
	case 4 :  printf("Attempted to divide by zero");        break;
	case 5 :  printf("Attempted to find modulus by zero");  break;
	case 6 :  printf("Undefined macro");                    break;
	case 7 :  printf("Illegal character follows \"#\"");    break;
	case 8 :  printf("Environment stack overflowed");       break;
	case 9 :  printf("Environment stack underflowed");      break;
	case 10 : printf("Data space exhausted");               break;
	case 11 : printf("Illegal character %d", envyro->ch);   break;
	case 12 : printf("Function name too long");             break;
	case 13 : printf("Unknown function");                   break;
	}  /* end case */
	printf("\n");
	envyro->disaster = 1;                       /* set disaster flag             */
}                                               /* end chs_display_error         */


void chs_display_str(cheese_envyro *envyro, char *s) {
    printf(s);
}


void chs_display_char(cheese_envyro *envyro, char c) {
    printf("%c", c);
}


void chs_display_int(cheese_envyro *envyro, int n) {
    printf("%1d", n);
}

char chs_input_char(cheese_envyro *envyro) {
	char instr[26];                      /* input string                  */
	char ch;

    fgets(instr, 25, stdin);             /*         read as a string      */
    sscanf(instr, "%c", &(ch));          /*         read character        */

    return ch;
}


CHEESE_WORD chs_input_int(cheese_envyro *envyro) {
	char instr[26];                      /* input string                  */
	CHEESE_WORD temp;

    fgets(instr, 25, stdin);             /*         read as a string      */
    sscanf(instr, "%d", &(temp));        /*         read number           */

    return temp;
}

