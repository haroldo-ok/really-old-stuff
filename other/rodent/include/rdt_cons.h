#ifndef _RDT_DISP_H_
#define _RDT_DISP_H_

#include "rdt_defs.h"

/*****************************************************************************/
/*  function prototypes                                                      */
/*****************************************************************************/
extern void rdt_display_envyro(cheese_envyro *envyro, CHEESE_PTR charpos);   /* display an environment        */
extern void rdt_display_error(cheese_envyro *envyro, short code);             /* report error; stop interpreter*/
extern void rdt_display_str(cheese_envyro *envyro, char *s);
extern void rdt_display_char(cheese_envyro *envyro, char c);
extern void rdt_display_int(cheese_envyro *envyro, CHEESE_WORD n);
extern char rdt_input_char(cheese_envyro *envyro);
extern CHEESE_WORD rdt_input_int(cheese_envyro *envyro);

#endif /* _RDT_DISP_H_ */
