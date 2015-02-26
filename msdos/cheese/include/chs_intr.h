#ifndef _CHS_INTR_H_
#define _CHS_INTR_H_

/*****************************************************************************/
/*  #includes                                                                */
/*****************************************************************************/

#include "chs_conf.h"                       /* Language configurations       */
#include "chs_defs.h"                       /* Language definitions          */

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

extern void chs_get_progchar(cheese_envyro *envyro);                /* get next character in program */
extern void chs_push(cheese_envyro *envyro, CHEESE_WORD datum);     /* push item onto calc stack     */
extern CHEESE_WORD chs_pop(cheese_envyro *envyro);                  /* pop item from calc stack      */
extern void chs_skipstring(cheese_envyro *envyro);                  /* skip over a string            */
extern void chs_skip(cheese_envyro *envyro, char lch, char rch);    /* skip bracketed sequences      */
extern void chs_pushhenv (cheese_envyro *envyro, enum tagtype tag); /* push an environment on env stk*/
extern void chs_popenv (cheese_envyro *envyro);                     /* pop an environmnt from env stk*/
extern void chs_makedeftable(cheese_envyro *envyro);                /* create macro definition table */
extern void chs_interpret(cheese_envyro *envyro);                   /* interpreter: runs program code*/
extern void chs_process_amp(cheese_envyro *envyro);                 /* parse an extended function    */
extern void chs_process_string(cheese_envyro *envyro);              /* parse string                  */


#endif /*  _CHS_INTR_H_ */
