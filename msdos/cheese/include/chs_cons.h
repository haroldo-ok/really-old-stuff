#ifndef _CHS_DISP_H_
#define _CHS_DISP_H_

#include "chs_defs.h"

/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/
#define  HALFWIDTH       39                 /* a number < half screen width  */

/*****************************************************************************/
/*  function prototypes                                                      */
/*****************************************************************************/
extern void chs_display_envyro(cheese_envyro *envyro, CHEESE_PTR charpos);   /* display an environment        */
extern void chs_display_error(cheese_envyro *envyro, short code);             /* report error; stop interpreter*/
extern void chs_display_str(cheese_envyro *envyro, char *s);
extern void chs_display_char(cheese_envyro *envyro, char c);
extern void chs_display_int(cheese_envyro *envyro, CHEESE_WORD n);
extern char chs_input_char(cheese_envyro *envyro);
extern CHEESE_WORD chs_input_int(cheese_envyro *envyro);

#endif /* _CHS_DISP_H_ */
