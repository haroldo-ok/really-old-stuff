#ifndef _RDT_FNCI_H_
#define _RDT_FNCI_H_

/*****************************************************************************/
/*  type definitions                                                         */
/*****************************************************************************/

typedef void rdt_extended_function(cheese_envyro *, char *); /* Extended function signature */

/*****************************************************************************/
/*  pointer table references                                                 */
/*****************************************************************************/

extern int extended_function_count;
extern char *function_names[];
extern rdt_extended_function *function_pointers[];

#endif /*  _RDT_FNCI_H_ */
