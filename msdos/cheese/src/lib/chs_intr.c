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
#include "chs_func.h"                       /* Extended functions            */
#include "chs_intr.h"                       /* The interpreter itself        */

/*****************************************************************************/
/*                                                                           */
/*  chs_get_progchar()                                                       */
/*                                                                           */
/*  Get next character from program buffer and check for end of program.     */
/*                                                                           */
/*****************************************************************************/

void chs_get_progchar(cheese_envyro *envyro) {
	if (envyro->charpos < envyro->proglen-1) {   /* if next chr is within program */
		envyro->charpos++;                       /* increment instruction pointer */
		envyro->ch = envyro->prog[envyro->charpos];      /* put next char into ch         */
	} else {                                     /* else ran off end of program   */
		chs_display_error(envyro, 1);            /* print error message           */
    }
}                                                /* end chs_get_progchar          */





/*****************************************************************************/
/*                                                                           */
/*  chs_push()                                                               */
/*                                                                           */
/*  Push an item onto the calculation stack and check for stack overflow.    */
/*                                                                           */
/*****************************************************************************/

void chs_push(cheese_envyro *envyro, CHEESE_WORD datum) {
	if (envyro->sp < STACKSIZE-1) {              /* if enough room on calc stack..*/
		envyro->sp++;                            /* increment stack pointer       */
		envyro->stack[envyro->sp] = datum;       /* store data item on stack      */
	} else {                                     /* else calc stack filled up     */
		chs_display_error(envyro, 2);            /* print error message           */
    }
}                                                /* end chs_push                  */





/*****************************************************************************/
/*                                                                           */
/*  chs_pop()                                                                */
/*                                                                           */
/*  Pop an item from the calculation stack; check for underflow.             */
/*                                                                           */
/*****************************************************************************/

CHEESE_WORD chs_pop(cheese_envyro *envyro) {
	CHEESE_WORD result;                                 /* returned stack value          */

	if (envyro->sp >= 0) {                              /* if an item is avail on stack..*/
		result = envyro->stack[envyro->sp];              /* get value on top of stack     */
		envyro->sp--;                                    /* decrement stack pointer       */
	} else {                                             /* otherwise stack underflow     */
		chs_display_error(envyro, 3);                    /* print error message           */
    }
	return result;
}                                                        /* end chs_pop                   */





/*****************************************************************************/
/*                                                                           */
/*  chs_skipstring()                                                         */
/*                                                                           */
/*  Skip over a string; " has been scanned on entry.                         */
/*                                                                           */
/*****************************************************************************/

void chs_skipstring(cheese_envyro *envyro) {
	do {                                     /* do until we find ending "     */
		chs_get_progchar(envyro);            /* read program character        */
		if (envyro->ch == '\\') {            /* treat \'s                     */
            chs_get_progchar(envyro);     
        }
	} while (envyro->ch != '"');             /* stop when ending " found      */
}                                            /* end chs_skipstring            */





/*****************************************************************************/
/*                                                                           */
/*  chs_skip()                                                               */
/*                                                                           */
/*  Skip bracketed sequences; lch has been scanned on entry.                 */
/*                                                                           */
/*****************************************************************************/

void chs_skip(cheese_envyro *envyro, char lch, char rch) {
	short  count;                           /* counter used for matching     */

	count = 1;                              /* one bracket already read      */
	do {                                    /* do until matching end bracket */
		chs_get_progchar(envyro);           /* read program character        */
		if (envyro->ch == '"')              /* if it starts a string..       */
			chs_skipstring(envyro);         /* ..then skip to end of string  */
		else if (envyro->ch == lch)         /* if another 'left' character.. */
			count++;                        /* ..then increment counter      */
		else if (envyro->ch == rch)         /* if closing 'right' character..*/
			count--;                        /* ..then decrement counter      */
	} while (count != 0);                   /* repeat until matching right ch*/
}                                           /* end chs_skip                  */


/*****************************************************************************/
/*                                                                           */
/*  chs_skip2()                                                              */
/*                                                                           */
/*  Skip bracketed sequences; lch has been scanned on entry.                 */
/*  End bracket is either rch1 or rch2.                                      */
/*                                                                           */
/*****************************************************************************/

void chs_skip2 (cheese_envyro *envyro, char lch, char rch1, char rch2) {
    short  count;                                /* counter used for matching     */

    count = 1;                                   /* one bracket already read      */
    do {                                         /* do until matching end bracket */
        chs_get_progchar(envyro);                /* read program character        */
        if (envyro->ch == '"') {                /* if it starts a string..       */
            chs_skipstring(envyro);              /* ..then skip to end of string  */
        } else if (envyro->ch == lch) {          /* if another 'left' character.. */
            count++;                             /* ..then increment counter      */
        } else if (envyro->ch == rch1 || envyro->ch == rch2) {   /* if closing 'right' character..*/
            count--;                             /* ..then decrement counter      */
        }
    } while (count != 0);                        /* repeat until matching right ch*/
}                                                /* end skip                      */




/*****************************************************************************/
/*                                                                           */
/*  chs_pushenv()                                                            */
/*                                                                           */
/*  Push an environment; check for environment stack overflow.               */
/*                                                                           */
/*****************************************************************************/

void chs_pushenv (cheese_envyro *envyro, enum tagtype tag) {
	if (envyro->esp < ENVSTACKSIZE-1) {                  /* if room avail on env stack..  */
		envyro->esp++;                                   /* ..increment env stack pointer */
		envyro->envstack[envyro->esp].tag = tag;         /* save tag type                 */
		envyro->envstack[envyro->esp].charpos = envyro->charpos; /* save instruction pointer      */
		envyro->envstack[envyro->esp].offset = envyro->offset;   /* save variable offset          */
	} else {                                             /* otherwise, env stack overflow */
		chs_display_error(envyro, 8);                    /* print error message           */
    }
}                                                        /* end chs_pushenv               */





/*****************************************************************************/
/*                                                                           */
/*  chs_popenv()                                                             */
/*                                                                           */
/*  Pop an environment; check for environment stack underflow.               */
/*                                                                           */
/*****************************************************************************/

void chs_popenv(cheese_envyro *envyro) {
	if (envyro->esp >= 0) {                              /* if item avail on env stack..  */
		envyro->charpos = envyro->envstack[envyro->esp].charpos;         /* pop instruction pointer       */
		envyro->offset = envyro->envstack[envyro->esp].offset;           /* pop variable offset           */
		envyro->esp--;                                   /* decrement stack pointer       */
	} else {                                             /* otherwise stack underflow     */
		chs_display_error(envyro, 9);                    /* print error message           */
    }
}                                                        /* end chs_popenv                */


/*****************************************************************************/
/*                                                                           */
/*  chs_makedeftable()                                                       */
/*                                                                           */
/*  Construct macro definition table.                                        */
/*                                                                           */
/*****************************************************************************/

void chs_makedeftable(cheese_envyro *envyro) {
	for (envyro->ch = 'A' ; envyro->ch <= 'Z'; envyro->ch++) {      /* for all macro table entries.. */
		envyro->macdefs[envyro->ch-'A'] = 0;                        /*..initialize all entries to 0  */
    }

	envyro->charpos = -1;                                           /* init ptr to start of memory   */
	do {                                                            /* for all program characters    */
		chs_get_progchar(envyro);                                   /* read next program character   */
		if (envyro->ch=='$' && envyro->charpos < envyro->proglen-1) {     /* if this is a $ (macro defn..  */
		                                                                  /* ..or end of program           */
			chs_get_progchar(envyro);                               /* read next char (macro letter) */
			UPPERCASE;                                              /* convert it to uppercase       */
			if ((envyro->ch >= 'A') && (envyro->ch <= 'Z'))         /* if it's a macro definition..  */
				envyro->macdefs[envyro->ch-'A'] = envyro->charpos;  /* save pointer in macro def tbl */
		}
	} while (envyro->charpos < envyro->proglen-1);                  /* repeat until end of program   */
}                                                                   /* end chs_makedeftable          */





/*****************************************************************************/
/*                                                                           */
/*  chs_interpret()                                                          */
/*                                                                           */
/*  The Interpreter.                                                         */
/*                                                                           */
/*****************************************************************************/

void chs_interpret(cheese_envyro *envyro) {
    CHEESE_WORD temp; 
     
	envyro->charpos = -1;                               /* init instruction pointer      */
	envyro->sp = -1;                                    /* init stack pointer            */
	envyro->esp = -1;                                   /* init environ stack pointer    */
	envyro->offset = 0;                                 /* init variable offset          */
	envyro->nextfree = LOCSIZE;                         /* init next free variable addr  */
	envyro->disaster = 0;                               /* No error, yet.                */

	do {                                        		/* repeat until end of program   */
		chs_get_progchar(envyro);                      	/* read next program character   */
		if (envyro->ch == ' ') {                        /* if it's a space..             */
			continue;                             		/* ..chs_skip to end of loop     */
        }

		if (envyro->tracing) {                          /* if tracing on..               */
			chs_display_envyro(envyro, envyro->charpos); /* ..display code w/ curr posn   */
        }

		if (isdigit(envyro->ch)) {                      /* if char is a digit..          */
		                                                /* ..encode a decimal number     */
			temp = 0;                                   /* init decimal number to 0      */
			while (isdigit(envyro->ch)) {               /* repeat for each digit         */
			    if (temp)  {
				   temp *= 10;                          /* decimal shift                 */
                }
                temp += VALUE(envyro->ch);              /* add digit to number           */
				chs_get_progchar(envyro);               /* get next character            */
			}                                           /* end while                     */
			chs_push(envyro, temp);                     /* push final number onto stack  */
			BACKSPACE;                                  /* backspace to last digit       */
		}

		else if ((envyro->ch >= 'A') && (envyro->ch <= 'Z')) {    /* if A to Z..                   */
			chs_push(envyro, envyro->ch - 'A' + envyro->offset);  /* put 0 to 25 + offset on stack */
        } else if ((envyro->ch >= 'a') && (envyro->ch <= 'z')) {  /* if a to z..                   */
			chs_push(envyro, envyro->ch - 'a' + envyro->offset);  /* put 0 to 25 + offset on stack */
        } else {                                                  /* if not alphanumeric..         */
			switch (envyro->ch) {                          /* big switch on current char    */
			case '$' :                                     /*  $   macro defn / end of prog */
				break;                                     /*         no action             */

            case '_' :                                     /*  _   change sign              */
                 chs_push(envyro, -chs_pop(envyro));
                 break;
    
			case '+' :                                     /*  +   add                      */
				chs_push(envyro, chs_pop(envyro) + chs_pop(envyro));
				break;

			case  '-' :                                    /*  -   subtract                 */
				temp = chs_pop(envyro);
				chs_push(envyro, chs_pop(envyro) - temp);
				break;

			case '*' :                                     /*  *   multiply                 */
				chs_push(envyro, chs_pop(envyro) * chs_pop(envyro));
				break;

			case '/' :                                     /*  /   divide with zero check   */
				temp = chs_pop(envyro);
				if (temp != 0) {                           /*         check for div by zero */
					chs_push(envyro, chs_pop(envyro) / temp);          /*         push if not div by 0  */
				} else {
					chs_display_error(envyro, 4);          /*         error if div by zero  */
                }
				break;

			case '\\' :                                    /*  \   remainder w/ zero check  */
				temp = chs_pop(envyro);
				if (temp != 0) {                           /*         check for rem by zero */
					chs_push(envyro, chs_pop(envyro) % temp);          /*         push if not rem by 0  */
				} else {
					chs_display_error(envyro, 5);          /*         error if rem by zero  */
                }
				break;

			case '?' :                                   /*  ?   read from keyboard       */
				chs_get_progchar(envyro);
				if (envyro->ch == '\'') {                /*  ?'   read character          */
					envyro->ch = chs_input_char(envyro); /*         read character        */
					chs_push(envyro, envyro->ch);        /*         push onto stack       */
				} else {                                 /*  ?    read number             */
					temp = chs_input_int(envyro);        /*         read number           */
					chs_push(envyro, temp);              /*         push onto stack       */
					BACKSPACE;
				}
				break;

			case '!' :                          /*  !   display on screen        */
				chs_get_progchar(envyro);
				if (envyro->ch == '\'') {       /*  !'   display character       */
					chs_display_char(envyro, chs_pop(envyro));
				} else {                        /*  !    display number          */
					chs_display_int(envyro, chs_pop(envyro));
					BACKSPACE;
				}
				break;

			case '"' :                         /*  "   display string on screen */
			    chs_process_string(envyro);
				break;

			case ':' :                         /*  :   assignment               */
				temp = chs_pop(envyro);
				envyro->data[temp] = chs_pop(envyro);
				break;

			case '.' :                         /*  .   dereference              */
				chs_push(envyro, envyro->data[chs_pop(envyro)]);
				break;

			case '<' :                         /*  <   less than                */
				temp = chs_pop(envyro);
				chs_push(envyro, (chs_pop(envyro) < temp) ? 1 : 0);
				break;

			case '=' :                         /*  =   equal to                 */
				chs_push(envyro, (chs_pop(envyro)==chs_pop(envyro)) ? 1 : 0);
				break;

			case '>' :                         /*  >   greater than             */
				temp = chs_pop(envyro);
				chs_push(envyro, (chs_pop(envyro) > temp) ? 1 : 0);
				break;

			case '[' :                         /*  [   conditional statement    */
				if (chs_pop(envyro) <= 0) {        /*         true if > 0           */
					chs_skip2(envyro, '[','|',']');
                }
				break;

			case ']' :                         /*  ]   end of conditional       */
				break;                          /*         no action             */

			case '|' :                         /*  [   conditional statement    */
			    chs_skip(envyro, '[',']');
				break;

			case '(' :                         /*  (   begin loop               */
				chs_pushenv(envyro, loop);
				break;

			case ')' :                         /*  )   end loop                 */
				envyro->charpos=envyro->envstack[envyro->esp].charpos;
				break;

			case '^' :                         /*  ^   exit loop                */
				if (chs_pop(envyro) <= 0) {
					chs_popenv(envyro);
					chs_skip(envyro, '(',')');
				}
				break;

			case '#':                          /*  #   macro call               */
				chs_get_progchar(envyro);                        /*         get macro letter      */
				UPPERCASE;                                       /*         convert to uppercase  */
				if ((envyro->ch>='A') && (envyro->ch<='Z')) {    /*         if A to Z..           */
					if (envyro->macdefs[envyro->ch-'A'] > 0) {   /*         if macro defined..    */
						chs_pushenv(envyro, macro);              /*         push env stack frame  */
						envyro->charpos=envyro->macdefs[envyro->ch-'A'];  /*         instruct ptr to macro */
						if (envyro->nextfree + LOCSIZE           /*         if variables avail..  */
								<= MAXADDR) {
							envyro->offset = envyro->nextfree;   /*         increment offset      */
							envyro->nextfree += LOCSIZE;         /*         increment nextfree    */
						} else {                                 /*         out of variable space */
							chs_display_error(envyro, 10);       /*         print error message   */
                        }
					} else {                                     /*         macro not defined     */
						chs_display_error(envyro, 6);            /*         print error message   */
                    }
				} else {                                         /*         invalid char after #  */
					chs_display_error(envyro, 7);                /*         print error message   */
                }
				break;

			case '@':                                   /*  @   return from macro        */
				chs_popenv(envyro);                     /*         pop env stack frame   */
				chs_skip(envyro, '#',';');              /*         skip to ;             */
				envyro->nextfree -= LOCSIZE;            /*         decrement nextfree    */
				break;

			case '%':                                   /*  %   replace formal by actual */
				chs_pushenv(envyro, parameter);         /*         push stack frame      */
				envyro->parbal = 1;                     /*         1 stack already pushed*/
				envyro->tsp = envyro->esp;              /*         temp env stack pointer*/
				do {                                    /*         loop thru env stack   */
					envyro->tsp--;                      /*         decrement stack ptr   */
					switch (envyro->envstack[envyro->tsp].tag) {  /*         check tag type        */
					case macro :                       /*         if macro (#)..        */
						envyro->parbal--;              /*         decrement counter     */
						break;
					case parameter :                   /*         if parameter (%)..    */
						envyro->parbal++;              /*         nest another level    */
						break;
					case loop :                        /*         if loop [ ( ]..       */
						break;                         /*         keep searching        */
					}
				} while (envyro->parbal != 0);         /*        til calling macro found*/
				envyro->charpos=envyro->envstack[envyro->tsp].charpos;  /*        update instruct ptr    */
				envyro->offset = envyro->envstack[envyro->tsp].offset;  /*        pt to new variable set */
				envyro->parnum = chs_pop(envyro);                       /*        get parameter number   */
				do {                                   /*        look for actual param  */
					chs_get_progchar(envyro);          /*        read program character */
					if (envyro->ch == '"') {           /*         param contains string */
						chs_skipstring(envyro);        /*         skip string           */
					} else if (envyro->ch == '#') {    /*         param has macro call  */
						chs_skip(envyro, '#',';');     /*         skip to end of macro  */
					} else if (envyro->ch == ',') {    /*         count commas          */
						envyro->parnum--;              /*         decrement comma ctr   */
					} else if (envyro->ch == ';') {    /*         param doesn't exist   */
							envyro->parnum = 0;        /*         stop loop             */
							chs_popenv(envyro);        /*         null parameter        */
					}
				} while (envyro->parnum != 0);         /*         loop until param found*/
				break;

			case ',' :                         /*  ,   end of actual parameter  */
			case ';' :                         /*  ;   end of macro call        */
				chs_popenv(envyro);
				break;

			case '\''  :                       /*  '   stack next character     */
				chs_get_progchar(envyro);
				chs_push(envyro, envyro->ch);
				break;

			case '{' :                         /*  {   trace on                 */
				envyro->tracing = 1;
				break;

			case '}' :                         /*  }   trace off                */
				envyro->tracing = 0;
				break;

            case '&':                          /*  &   & function               */
                chs_process_amp(envyro);
                break;
                
			case '`':                          /*      unused characters        */
				chs_display_error(envyro, 11); /*         print error message   */
				break;

			default :                          /*      unused character         */
				chs_display_error(envyro, 11); /*         print error message   */
			break;
			}                                  /* end switch                    */
        }
	} while (!((envyro->ch == '$') || envyro->disaster));    /* loop until end of program ($) */
}                                           /* end chs_interpret                */

void chs_process_amp(cheese_envyro *envyro) {
    char         amp_str[FUNCTION_SIZE + 1]; /* & function string             */
    char         *p;                         /* character pointer             */
    int          cnt;                        /* number of characters read     */

    p = amp_str;
    cnt = 0;
    
    chs_get_progchar(envyro);          /*         read 1st char after & */
    while (envyro->ch!='&' && envyro->ch!='$') {   /*         loop until end & or $ or <SPACE> */
        *p++ = tolower(envyro->ch);    /*         copy char to amp_str  */
        chs_get_progchar(envyro);      /*         read next char        */
        
        cnt++;                         
        if (cnt == FUNCTION_SIZE + 1) { /*         checks if function name size is within bounds */
            chs_display_error(envyro, 12); /*         print error message   */
        }        
    }
    *p = '\0';                         /*         add end-of-string     */
    chs_execute_function(envyro, amp_str); /*         call & subroutine     */
}

void chs_process_string(cheese_envyro *envyro) {
    char ch;
     
	do {
		chs_get_progchar(envyro);
		if (envyro->ch == '\\') {              /*         check for special chars */
            chs_get_progchar(envyro);          /*         read next char          */
            switch (envyro->ch) {
                case '0':                      /*         nul                     */
                    ch = '\0'; 
                    break;
                case 't':                      /*         tab                     */
                    ch = '\t'; 
                    break;
                case 'b':                      /*         backspace               */
                    ch = '\b'; 
                    break;
                case 'r':                      /*         carriage return         */
                    ch = '\r'; 
                    break;
                case 'n':                      /*         new line                */
                    ch = '\n'; 
                    break;
                case 'e':                      /*         escape                  */
                    ch = '\e'; 
                    break;
                case 'x':                      /*         Hex ascii code          */                    
                    chs_get_progchar(envyro);  /*  first digit                    */
                    if (envyro->ch <= '9') {
                        ch = envyro->ch - '0';
                    } else {
                        ch = envyro->ch - 'A' + 10;
                    }

                    ch <<= 4;

                    chs_get_progchar(envyro);  /*  second digit                   */
                    if (envyro->ch <= '9') {
                        ch |= envyro->ch - '0';
                    } else {
                        ch |= envyro->ch - 'A' + 10;
                    }
                    break;
                default:
                    ch = envyro->ch;
            }
			chs_display_char(envyro, ch);      /*         print character       */
		} else if (envyro->ch != '"') {        /*         check for end of str  */
			chs_display_char(envyro, envyro->ch); /*         print if not "        */
        }
	} while (envyro->ch != '"');
}
