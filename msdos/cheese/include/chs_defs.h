#ifndef _CHS_DEFS_H_
#define _CHS_DEFS_H_

#include "chs_conf.h"                       /* Language configurations       */

/*****************************************************************************/
/*  type definitions                                                         */
/*****************************************************************************/

enum  tagtype {macro, parameter, loop};     /* tag type for environmnt stack */

typedef struct {                            /* environment stack entry type  */
	enum tagtype  tag;                       /* type of entry                 */
	CHEESE_PTR charpos;                      /* instruction pointer           */
	CHEESE_PTR offset;                       /* variable offset level         */
} env_stack_node;

typedef struct _cheese_envyro {             /* execution environment type    */
	char *prog;                             /* pointer to program code       */
	CHEESE_WORD    stack[STACKSIZE];        /* calculation stack             */
	env_stack_node envstack[ENVSTACKSIZE];  /* environment stack             */
	CHEESE_WORD    data[MAXADDR];           /* variables                     */
	CHEESE_PTR     macdefs[26];             /* macro definitions             */
	char           ch;                      /* current character in program  */
	CHEESE_PTR     charpos;                 /* instruction pointer           */
	CHEESE_PTR     proglen;                 /* total length of program code  */
	CHEESE_PTR     sp;                      /* calculation stack pointer     */
	CHEESE_PTR     esp;                     /* environment stack pointer     */
	CHEESE_PTR     tsp;                     /* temporary stack pointer       */
	CHEESE_PTR     offset;                  /* variable offset               */
	CHEESE_PTR     nextfree;                /* next free variable address    */
	CHEESE_PTR     parbal;                  /* matches pairs in env stack    */
	CHEESE_PTR     parnum;                  /* macro parameter number        */
	char           tracing;                 /* tracing on/off flag           */
	char           disaster;                /* disaster flag; 1=disaster     */
	void           *extra;                  /* additional data               */
} cheese_envyro;

#endif /* _CHS_DEFS_H_ */
