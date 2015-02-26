#ifndef _RDT_INTR_H_
#define _RDT_INTR_H_

/*****************************************************************************/
/*  #includes                                                                */
/*****************************************************************************/

#include "rdt_conf.h"                       /* Language configurations       */
#include "rdt_defs.h"                       /* Language definitions          */

/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  FUNCTION_SIZE 10                   /* Maximum size for function names */
#define  BACKSPACE     envyro->charpos--            /* backspace one char in program */
#define  VALUE(digit)  (digit - '0')        /* convert char to corresp digit */
#define  UPPERCASE     envyro->ch = toupper(envyro->ch)     /* convert ch to uppercase       */

/*****************************************************************************/
/*  function prototypes                                                      */
/*****************************************************************************/

extern void rdt_get_progchar(cheese_envyro *envyro);                /* get next character in program */
extern void rdt_push(cheese_envyro *envyro, CHEESE_WORD datum);     /* push item onto calc stack     */
extern CHEESE_WORD rdt_pop(cheese_envyro *envyro);                  /* pop item from calc stack      */
extern void rdt_skipstring(cheese_envyro *envyro);                  /* skip over a string            */
extern void rdt_skip(cheese_envyro *envyro, char lch, char rch);    /* skip bracketed sequences      */
extern void rdt_pushhenv (cheese_envyro *envyro, enum tagtype tag); /* push an environment on env stk*/
extern void rdt_popenv (cheese_envyro *envyro);                     /* pop an environmnt from env stk*/
extern void rdt_makedeftable(cheese_envyro *envyro);                /* create macro definition table */
extern void rdt_interpret(cheese_envyro *envyro);                   /* interpreter: runs program code*/
extern void rdt_process_amp(cheese_envyro *envyro);                 /* parse an extended function    */
extern void rdt_process_string(cheese_envyro *envyro);              /* parse string                  */


#endif /*  _RDT_INTR_H_ */
