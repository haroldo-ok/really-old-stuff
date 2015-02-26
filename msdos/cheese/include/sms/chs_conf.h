#ifndef _CHS_CONF_H_
#define _CHS_CONF_H_

/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  MAXPROGLEN   10000                 /* max length of Mouse program   */
#define  STACKSIZE       16                 /* maximum depth of calc stack   */
#define  ENVSTACKSIZE    16                 /* maximum depth of env stack    */
#define  LOCSIZE         26                 /* size of local variable space  */
#define  MAXADDR       1300                 /* 10 local variable spaces      */

#define  CHEESE_PTR    int                  /* Type internally used as pointers by the interpreter */
#define  CHEESE_WORD   int                  /* Type used for the variables                         */

#endif /*_CHS_CONF_H_*/
