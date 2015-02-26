/*****************************************************************************/
/*                                                                           */
/*                             M O U S E                                     */
/*                                                                           */
/*  Program:      MOUSE                                                      */
/*                                                                           */
/*  Programmer:   David G. Simpson                                           */
/*                Laurel, Maryland                                           */
/*                February 3, 2002                                           */
/*                                                                           */
/*  Language:     ANSI Standard C                                            */
/*                                                                           */
/*  Description:  This is an interpreter for the Mouse-83 programming        */
/*                language.                                                  */
/*                                                                           */
/*  Version:      9                                                          */
/*                                                                           */
/*  Notes:        This interpreter is based on the original Pascal           */
/*                implementation in "Mouse: A Language for Microcomputers"   */
/*                by Peter Grogono.                                          */
/*                                                                           */
/*                Syntax:   MOUSE  <filename>                                */
/*                                                                           */
/*                If no file extension is given, an extension of ".mou" is   */
/*                assumed.                                                   */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/*  #includes                                                                */
/*****************************************************************************/

#include <stdio.h>                          /* standard i/o                  */
#include <stdlib.h>                         /* standard library              */
#include <string.h>                         /* string functions              */
#include <ctype.h>                          /* character functions           */



/*****************************************************************************/
/*  #defines                                                                 */
/*****************************************************************************/

#define  MAXPROGLEN   10000                 /* max length of Mouse program   */
#define  STACKSIZE     1024                 /* maximum depth of calc stack   */
#define  ENVSTACKSIZE  1024                 /* maximum depth of env stack    */
#define  LOCSIZE         26                 /* size of local variable space  */
#define  MAXADDR       1300                 /* 10 local variable spaces      */
#define  HALFWIDTH       39                 /* a number < half screen width  */
#define  MOUSE_EXT      ".mou"              /* default source file extension */

#define  BACKSPACE     charpos--            /* backspace one char in program */
#define  VALUE(digit)  (digit - '0')        /* convert char to corresp digit */
#define  UPPERCASE     ch = toupper(ch)     /* convert ch to uppercase       */


/*****************************************************************************/
/*  type definitions                                                         */
/*****************************************************************************/

enum  tagtype {macro, parameter, loop};     /* tag type for environmnt stack */

typedef struct {                            /* environment stack entry type  */
   enum tagtype  tag;                       /* type of entry                 */
   long     charpos;                        /* instruction pointer           */
   long     offset;                         /* variable offset level         */
   } environment;



/*****************************************************************************/
/*  global variables                                                         */
/*****************************************************************************/

FILE         *progfile;                     /* pointer to Mouse source file  */

char         prog[MAXPROGLEN];              /* array to hold program         */
long         stack[STACKSIZE];              /* calculation stack             */
environment  envstack[ENVSTACKSIZE];        /* environment stack             */
long         data[MAXADDR];                 /* variables                     */
long         macdefs[26];                   /* macro definitions             */

char         ch;                            /* current character in program  */
long         charpos;                       /* instruction pointer           */
long         proglen;                       /* total length of program code  */
long         sp;                            /* calculation stack pointer     */
long         esp;                           /* environment stack pointer     */
long         tsp;                           /* temporary stack pointer       */
long         offset;                        /* variable offset               */
long         nextfree;                      /* next free variable address    */
long         temp;                          /* temporary integer             */
long         parbal;                        /* matches pairs in env stack    */
long         parnum;                        /* macro parameter number        */
int          tracing;                       /* tracing on/off flag           */
int          disaster;                      /* disaster flag; 1=disaster     */
int          j;                             /* loop index                    */
char         filename[101];                 /* Mouse source file name        */
long         temp;                          /* temporary integer             */


/*****************************************************************************/
/*  function prototypes                                                      */
/*****************************************************************************/

void display (long charpos);                /* display an environment        */
void error (short code);                    /* report error; stop interpreter*/
void Getchar(void);                         /* get next character in program */
void push (int datum);                      /* push item onto calc stack     */
int pop (void);                             /* pop item from calc stack      */
void skipstring(void);                      /* skip over a string            */
void skip (char lch, char rch);             /* skip bracketed sequences      */
void pushenv (enum tagtype tag);            /* push an environment on env stk*/
void popenv (void);                         /* pop an environmnt from env stk*/
void load (void);                           /* loader: loads program code    */
void makedeftable (void);                   /* create macro definition table */
void interpret (void);                      /* interpreter: runs program code*/







/*****************************************************************************/
/*                                                                           */
/*  main()                                                                   */
/*                                                                           */
/*****************************************************************************/

int main (int argc, char *argv[])
{
/*---------------------------------------------------------------------------*/
/*  Check command-line arguments.                                            */
/*---------------------------------------------------------------------------*/

if (argc != 2)                              /* check for 1 cmd line argument */
   {
   printf("Syntax:  MOUSE <filename>\n");   /* if not, print help message    */
   exit(0);                                 /* and return to oper system     */
   }


/*---------------------------------------------------------------------------*/
/*  If no file extension given, add the default extension to filename.       */
/*---------------------------------------------------------------------------*/

strcpy(filename, argv[1]);                  /* copy cmd line argument        */
if (strchr(filename, (int)'.') == NULL)     /* if no file extension given..  */
   strcat(filename, MOUSE_EXT);             /* ..append default extension    */


/*---------------------------------------------------------------------------*/
/*  Open mouse source file.                                                  */
/*---------------------------------------------------------------------------*/

if ((progfile=fopen(filename,"rb"))==NULL)  /* open Mouse source file        */
   {
   printf("Error opening file %s\n",        /* if open error, print err msg  */
          filename);
   exit(1);                                 /* and return to operating sys   */
   }

/*---------------------------------------------------------------------------*/
/*  Load Mouse source file into memory, then close the source file.          */
/*---------------------------------------------------------------------------*/

load();                                     /* load program into memory      */
fclose(progfile);                           /* close Mouse source file       */

/*---------------------------------------------------------------------------*/
/*  If load went OK, then define macros and run the interpreter.             */
/*---------------------------------------------------------------------------*/

if (!disaster)                              /* if no load problems..         */
   {
   makedeftable();                          /* create macro definition table */
   interpret();                             /* and run interpreter           */
   }

/*---------------------------------------------------------------------------*/
/*  All done.  Return to operating system.
/*---------------------------------------------------------------------------*/

return 0;                                   /* return to operating system    */

}                                           /* end MouseInterpreter          */






/*****************************************************************************/
/*                                                                           */
/*  display()                                                                */
/*                                                                           */
/*  Display an environment; used for reporting errors and tracing.           */
/*  This routine displays a line of code centered on the given pointer, with */
/*  a ^ pointing to the character at the pointer.                            */
/*                                                                           */
/*****************************************************************************/

void display (long charpos)
{
long  pos;                                  /* loop index                    */

for (pos = charpos - HALFWIDTH;             /* for HALFWIDTH chars centered..*/
     pos <= charpos + HALFWIDTH; pos++)     /*..on current position..        */
   {
   if ((pos >= 0) && (pos < proglen)        /* if within program bounds..    */
              && (prog[pos] >= ' '))        /*..and printable character..    */
      printf("%c", prog[pos]);              /* print program character       */
   else                                     /* otherwise,                    */
      printf(" ");                          /* just print a space            */
   }
printf ("\n");                              /* end of line                   */
for (j=0; j<HALFWIDTH; j++)                 /* print spaces to position ^    */
   printf(" ");
printf("^\n");                              /* print ^ pointer               */
}                                           /* end display                   */





/*****************************************************************************/
/*                                                                           */
/*  error()                                                                  */
/*                                                                           */
/*  Report an error and set "disaster" flag to stop the interpreter.         */
/*                                                                           */
/*****************************************************************************/

void error (short code)
{
short  tsp;                                 /* loop counter                  */

printf("\nEnvironment:\n");                 /* start new line                */
for (tsp = 0; tsp < esp; tsp++)             /* for each entry in env stack.. */
   display(envstack[tsp].charpos);          /* display the code at that entry*/

printf("Instruction pointer:\n");           /* display code at instruct ptr  */
display(charpos);

printf("Stack:");                           /* display stack contents        */
for (tsp = 0; tsp < sp; tsp++)
   printf(" [%1d]", stack[tsp]);
printf("\n");

printf ("***** Error %d: ", code);          /* print error message           */
switch (code)                               /* select err message from list  */
   {
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
   case 11 : printf("Illegal character %d", ch);           break;
   }  /* end case */
printf("\n");
disaster = 1;                               /* set disaster flag             */
}                                           /* end error                     */





/*****************************************************************************/
/*                                                                           */
/*  Getchar()                                                                */
/*                                                                           */
/*  Get next character from program buffer and check for end of program.     */
/*                                                                           */
/*****************************************************************************/

void Getchar(void)
{
if (charpos < proglen-1)                    /* if next chr is within program */
   {
   charpos++;                               /* increment instruction pointer */
   ch = prog[charpos];                      /* put next char into ch         */
   }
else                                        /* else ran off end of program   */
   error(1);                                /* print error message           */
}                                           /* end Getchar                   */





/*****************************************************************************/
/*                                                                           */
/*  push()                                                                   */
/*                                                                           */
/*  Push an item onto the calculation stack and check for stack overflow.    */
/*                                                                           */
/*****************************************************************************/

void push (int datum)
{
if (sp < STACKSIZE-1)                       /* if enough room on calc stack..*/
   {
   sp++;                                    /* increment stack pointer       */
   stack[sp] = datum;                       /* store data item on stack      */
   }
else                                        /* else calc stack filled up     */
   error(2);                                /* print error message           */
}                                           /* end push                      */





/*****************************************************************************/
/*                                                                           */
/*  pop()                                                                    */
/*                                                                           */
/*  Pop an item from the calculation stack; check for underflow.             */
/*                                                                           */
/*****************************************************************************/

int pop (void)
{
int result;                                 /* returned stack value          */

if (sp >= 0)                                /* if an item is avail on stack..*/
   {
   result = stack[sp];                      /* get value on top of stack     */
   sp--;                                    /* decrement stack pointer       */
   }
else                                        /* otherwise stack underflow     */
   error(3);                                /* print error message           */
return result;
}                                           /* end pop                       */





/*****************************************************************************/
/*                                                                           */
/*  skipstring()                                                             */
/*                                                                           */
/*  Skip over a string; " has been scanned on entry.                         */
/*                                                                           */
/*****************************************************************************/

void skipstring(void)
{
do {                                        /* do until we find ending "     */
   Getchar();                               /* read program character        */
   } while (ch != '"');                     /* stop when ending " found      */
}                                           /* end skipstring                */





/*****************************************************************************/
/*                                                                           */
/*  skip()                                                                   */
/*                                                                           */
/*  Skip bracketed sequences; lch has been scanned on entry.                 */
/*                                                                           */
/*****************************************************************************/

void skip (char lch, char rch)
{
short  count;                               /* counter used for matching     */

count = 1;                                  /* one bracket already read      */
do {                                        /* do until matching end bracket */
   Getchar();                               /* read program character        */
   if (ch == '"')                           /* if it starts a string..       */
      skipstring();                         /* ..then skip to end of string  */
   else if (ch == lch)                      /* if another 'left' character.. */
      count++;                              /* ..then increment counter      */
   else if (ch == rch)                      /* if closing 'right' character..*/
      count--;                              /* ..then decrement counter      */
   } while (count != 0);                    /* repeat until matching right ch*/
}                                           /* end skip                      */





/*****************************************************************************/
/*                                                                           */
/*  pushenv()                                                                */
/*                                                                           */
/*  Push an environment; check for environment stack overflow.               */
/*                                                                           */
/*****************************************************************************/

void pushenv (enum tagtype tag)
   {
if (esp < ENVSTACKSIZE-1)                   /* if room avail on env stack..  */
   {
   esp++;                                   /* ..increment env stack pointer */
   envstack[esp].tag = tag;                 /* save tag type                 */
   envstack[esp].charpos = charpos;         /* save instruction pointer      */
   envstack[esp].offset = offset;           /* save variable offset          */
   }
else                                        /* otherwise, env stack overflow */
   error(8);                                /* print error message           */
}                                           /* end pushenv                   */





/*****************************************************************************/
/*                                                                           */
/*  popenv()                                                                 */
/*                                                                           */
/*  Pop an environment; check for environment stack underflow.               */
/*                                                                           */
/*****************************************************************************/

void popenv(void)
{
if (esp >= 0)                               /* if item avail on env stack..  */
   {
   charpos = envstack[esp].charpos;         /* pop instruction pointer       */
   offset = envstack[esp].offset;           /* pop variable offset           */
   esp--;                                   /* decrement stack pointer       */
   }
else                                        /* otherwise stack underflow     */
   error(9);                                /* print error message           */
}                                           /* end popenv                    */





/*****************************************************************************/
/*                                                                           */
/*  load()                                                                   */
/*                                                                           */
/*  The Loader.                                                              */
/*  This version of the loader has been optimized to remove all spaces       */
/*  except for spaces within strings and spaces separating numbers (for      */
/*  which all but one space is removed).  It also eliminates all CR/LF       */
/*  characters.  Optimizing the loader to eliminate all unnecessary          */
/*  characters greatly improves the execution speed of the interpreter.      */
/*                                                                           */
/*****************************************************************************/

void load (void)
{
char  lastchr;                              /* previously loaded character   */
char  in = 0;                               /* 1=within a string             */

for (charpos = 0; charpos < MAXPROGLEN;     /* init entire program array..   */
     charpos++)
   prog[charpos] = ' ';                     /* ..to all spaces               */
rewind(progfile);                           /* position to beginning of file */
charpos = -1;                               /* init ptr to start of memory   */
disaster = 0;                               /* clear disaster flag           */
ch = '~';                                   /* init first character to ~     */
while (!(feof(progfile) || disaster))       /* while not eof and loading OK..*/
   {
   lastchr = ch;                            /* save previously loaded char   */
   fread(&ch, 1, 1, progfile);              /* read one char from Mouse file */
   if (feof(progfile))                      /* if end of Mouse file..        */
      break;                                /* then break out of loop        */
   if (ch == '~')                           /* if start of comment..         */
      do {
         fread(&ch, 1, 1, progfile);        /* ..read characters..           */
         } while (ch != '\n');              /* ..until next newline          */
   else if (charpos < MAXPROGLEN-1)         /* else if program memory left.. */
      {
      charpos++;                            /* increment pointer to memory   */
      prog[charpos] = ch;                   /* save read character to memory */
      if (ch == '\"')                       /* if current char is "          */
         in = !in;                          /* then toggle quote flag        */
      if (ch==10 || ch==13 || ch=='\n'      /* if CR or LF or newline..      */
          || ch=='\t' || ch=='\r')          /* ..or tab or \r..              */
         prog[charpos] = ch = ' ';          /* ..replace with space          */
      if (ch==' ' && !in &&                 /* if a space not in string..    */
           !isdigit(lastchr) &&             /* ..and not after a number..    */
           (lastchr != '\''))               /* ..and not after a '..         */
         {
         charpos--;                         /* then backspace pointer        */
         ch = prog[charpos];                /* update last read character    */
         }
      else if (!in && lastchr == ' ' &&     /* if last char was a space and..*/
             !isdigit(ch) && ch != '\"'     /*..this char isn't a digit..    */
             && prog[charpos-2] != '\'')    /*..and it isn't a quote-space.. */
         prog[--charpos] = ch;              /* then remove the last space    */
      }
   else                                     /* if no program memory left..   */
      {
      printf("Program is too long\n");      /* print error message           */
      disaster = 1;                         /* and set disaster flag         */
      }
   }                                        /* end while                     */
proglen = charpos + 1;                      /* set total program length      */

}                                           /* end load                      */





/*****************************************************************************/
/*                                                                           */
/*  makedeftable()                                                           */
/*                                                                           */
/*  Construct macro definition table.                                        */
/*                                                                           */
/*****************************************************************************/

void makedeftable (void)
{
for (ch = 'A' ; ch <= 'Z'; ch++)            /* for all macro table entries.. */
   macdefs[ch-'A'] = 0;                     /*..initialize all entries to 0  */
charpos = -1;                               /* init ptr to start of memory   */
do {                                        /* for all program characters    */
   Getchar();                               /* read next program character   */
   if (ch=='$' && charpos < proglen-1)      /* if this is a $ (macro defn..  */
      {                                     /* ..or end of program           */
      Getchar();                            /* read next char (macro letter) */
      UPPERCASE;                            /* convert it to uppercase       */
      if ((ch >= 'A') && (ch <= 'Z'))       /* if it's a macro definition..  */
         macdefs[ch-'A'] = charpos;         /* save pointer in macro def tbl */
      }
   } while (charpos < proglen-1);           /* repeat until end of program   */
}                                           /* end makedeftable              */





/*****************************************************************************/
/*                                                                           */
/*  interpret()                                                              */
/*                                                                           */
/*  The Interpreter.                                                         */
/*                                                                           */
/*****************************************************************************/

void interpret (void)
{
char instr[26];                             /* input string                  */

charpos = -1;                               /* init instruction pointer      */
sp = -1;                                    /* init stack pointer            */
esp = -1;                                   /* init environ stack pointer    */
offset = 0;                                 /* init variable offset          */
nextfree = LOCSIZE;                         /* init next free variable addr  */

do {                                        /* repeat until end of program   */
   Getchar();                               /* read next program character   */
   if (ch == ' ')                           /* if it's a space..             */
      continue;                             /* ..skip to end of loop         */

   if (tracing)                             /* if tracing on..               */
      display(charpos);                     /* ..display code w/ curr posn   */

   if (isdigit(ch))                         /* if char is a digit..          */
      {                                     /* ..encode a decimal number     */
      temp = 0;                             /* init decimal number to 0      */
      while (isdigit(ch))                   /* repeat for each digit         */
         {
         temp = 10 * temp + VALUE(ch);      /* add digit to number           */
         Getchar();                         /* get next character            */
         }                                  /* end while                     */
      push(temp);                           /* push final number onto stack  */
      BACKSPACE;                            /* backspace to last digit       */
      }

   else if ((ch >= 'A') && (ch <= 'Z'))     /* if A to Z..                   */
      push(ch - 'A' + offset);              /* put 0 to 25 + offset on stack */

   else if ((ch >= 'a') && (ch <= 'z'))     /* if a to z..                   */
      push(ch - 'a' + offset);              /* put 0 to 25 + offset on stack */

   else                                     /* if not alphanumeric..         */

      switch (ch)                           /* big switch on current char    */
         {

         case '$' :                         /*  $   macro defn / end of prog */
            break;                          /*         no action             */

         case '+' :                         /*  +   add                      */
            push(pop() + pop());
            break;

         case  '-' :                        /*  -   subtract                 */
            temp = pop();
            push(pop() - temp);
            break;

         case '*' :                         /*  *   multiply                 */
            push(pop() * pop());
            break;

         case '/' :                         /*  /   divide with zero check   */
            temp = pop();
            if (temp != 0)                  /*         check for div by zero */
               push(pop() / temp);          /*         push if not div by 0  */
            else
               error(4);                    /*         error if div by zero  */
            break;

         case '\\' :                        /*  \   remainder w/ zero check  */
            temp = pop();
            if (temp != 0)                  /*         check for rem by zero */
               push(pop() % temp);          /*         push if not rem by 0  */
            else
               error(5);                    /*         error if rem by zero  */
            break;

         case '?' :                         /*  ?   read from keyboard       */
            Getchar();
            if (ch == '\'')                 /*  ?'   read character          */
               {
               fgets(instr, 25, stdin);     /*         read as a string      */
               sscanf(instr, "%c", &ch);    /*         read character        */
               push(ch);                    /*         push onto stack       */
               }
            else                            /*  ?    read number             */
               {
               fgets(instr, 25, stdin);     /*         read as a string      */
               sscanf(instr, "%d", &temp);  /*         read number           */
               push(temp);                  /*         push onto stack       */
               BACKSPACE;
               }
            break;

         case '!' :                         /*  !   display on screen        */
            Getchar();
            if (ch == '\'')                 /*  !'   display character       */
               printf("%c", pop());
            else                            /*  !    display number          */
               {
               printf("%1d", pop());
               BACKSPACE;
               }
            break;

         case '"' :                         /*  "   display string on screen */
            do {
               Getchar();
               if (ch == '!')               /*         check for newline     */
                  printf("\n");             /*         print newline         */
               else if (ch != '"')          /*         check for end of str  */
                  printf ("%c", ch);        /*         print if not "        */
               } while (ch != '"');
            break;

         case ':' :                         /*  :   assignment               */
            temp = pop();
            data[temp] = pop();
            break;

         case '.' :                         /*  .   dereference              */
            push(data[pop()]);
            break;

         case '<' :                         /*  <   less than                */
            temp = pop();
            push ((pop() < temp) ? 1 : 0);
            break;

         case '=' :                         /*  =   equal to                 */
            push ((pop()==pop()) ? 1 : 0);
            break;

         case '>' :                         /*  >   greater than             */
            temp = pop();
            push ((pop() > temp) ? 1 : 0);
            break;

         case '[' :                         /*  [   conditional statement    */
            if (pop() <= 0)                 /*         true if > 0           */
               skip('[',']');
            break;

         case ']' :                         /*  ]   end of conditional       */
            break;                          /*         no action             */

         case '(' :                         /*  (   begin loop               */
            pushenv(loop);
            break;

         case ')' :                         /*  )   end loop                 */
            charpos=envstack[esp].charpos;
            break;

         case '^' :                         /*  ^   exit loop                */
            if (pop() <= 0)
               {
               popenv();
               skip('(',')');
               }
            break;

         case '#':                          /*  #   macro call               */
            Getchar();                      /*         get macro letter      */
            UPPERCASE;                      /*         convert to uppercase  */
            if ((ch>='A') && (ch<='Z'))     /*         if A to Z..           */
               {
               if (macdefs[ch-'A'] > 0)     /*         if macro defined..    */
                  {
                  pushenv(macro);           /*         push env stack frame  */
                  charpos=macdefs[ch-'A'];  /*         instruct ptr to macro */
                  if (nextfree + LOCSIZE    /*         if variables avail..  */
                          <= MAXADDR)
                     {
                     offset = nextfree;     /*         increment offset      */
                     nextfree += LOCSIZE;   /*         increment nextfree    */
                     }
                  else                      /*         out of variable space */
                     error(10);             /*         print error message   */
                  }
               else                         /*         macro not defined     */
                  error(6);                 /*         print error message   */
               }
            else                            /*         invalid char after #  */
               error(7);                    /*         print error message   */
            break;

         case '@':                          /*  @   return from macro        */
            popenv();                       /*         pop env stack frame   */
            skip('#',';');                  /*         skip to ;             */
            nextfree -= LOCSIZE;            /*         decrement nextfree    */
            break;

         case '%':                          /*  %   replace formal by actual */
            pushenv(parameter);             /*         push stack frame      */
            parbal = 1;                     /*         1 stack already pushed*/
            tsp = esp;                      /*         temp env stack pointer*/
            do {                            /*         loop thru env stack   */
               tsp--;                       /*         decrement stack ptr   */
               switch (envstack[tsp].tag)   /*         check tag type        */
                  {
                  case macro :              /*         if macro (#)..        */
                     parbal--;              /*         decrement counter     */
                     break;
                  case parameter :          /*         if parameter (%)..    */
                     parbal++;              /*         nest another level    */
                     break;
                  case loop :               /*         if loop [ ( ]..       */
                     break;                 /*         keep searching        */
                  }
               } while (parbal != 0);       /*        til calling macro found*/
            charpos=envstack[tsp].charpos;  /*        update instruct ptr    */
            offset = envstack[tsp].offset;  /*        pt to new variable set */
            parnum = pop();                 /*        get parameter number   */
            do {                            /*        look for actual param  */
               Getchar();                   /*        read program character */
               if (ch == '"')               /*         param contains string */
                  skipstring();             /*         skip string           */
               else if (ch == '#')          /*         param has macro call  */
                  skip('#',';');            /*         skip to end of macro  */
               else if (ch == ',')          /*         count commas          */
                  parnum--;                 /*         decrement comma ctr   */
               else if (ch == ';')          /*         param doesn't exist   */
                  {
                  parnum = 0;               /*         stop loop             */
                  popenv();                 /*         null parameter        */
                  }
               } while (parnum != 0);       /*         loop until param found*/
            break;

         case ',' :                         /*  ,   end of actual parameter  */
         case ';' :                         /*  ;   end of macro call        */
            popenv();
            break;

         case '\''  :                       /*  '   stack next character     */
            Getchar();
            push(ch);
            break;

         case '{' :                         /*  {   trace on                 */
            tracing = 1;
            break;

         case '}' :                         /*  }   trace off                */
            tracing = 0;
            break;

         case '`':                          /*      unused characters        */
         case '&':
         case '|':
         case '_' :
            error(11);                      /*         print error message   */
            break;

         default :                          /*      unused character         */
            error(11);                      /*         print error message   */
            break;
         }                                  /* end switch                    */

   } while (!((ch == '$') || disaster));    /* loop until end of program ($) */
}                                           /* end interpret                 */

