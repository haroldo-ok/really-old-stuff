#ifndef _CHS_FNCI_H_
#define _CHS_FNCI_H_

/*****************************************************************************/
/*  type definitions                                                         */
/*****************************************************************************/

typedef void chs_extended_function(cheese_envyro *, char *); /* Extended function signature */

/*****************************************************************************/
/*  pointer table references                                                 */
/*****************************************************************************/

extern int extended_function_count;
extern char *function_names[];
extern chs_extended_function *function_pointers[];

#endif /*  _CHS_FNCI_H_ */
