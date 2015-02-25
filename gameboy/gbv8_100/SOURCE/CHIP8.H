/** Vision8: CHIP8 emulator *************************************************/
/**                                                                        **/
/**                                CHIP8.h                                 **/
/**                                                                        **/
/** This file contains the portable CHIP8 emulation engine definitions     **/
/**                                                                        **/
/** Copyright (C) Marcel de Kogel 1997                                     **/
/**     You are not allowed to distribute this software commercially       **/
/**     Please, notify me, if you make any changes to this file            **/
/****************************************************************************/

#ifndef __CHIP8_H
#define __CHIP8_H

#include <gb.h>

typedef UBYTE byte;                     /* sizeof(byte)==1          */
typedef UWORD word;                    /* sizeof(word)>=2          */

struct chip8_regs_struct
{
 byte alg[16];                                  /* 16 general registers     */
 byte delay,sound;                              /* delay and sound timer    */
 word i;                                        /* index register           */
 word pc;                                       /* program counter          */
 word sp;                                       /* stack pointer            */
};

extern struct chip8_regs_struct chip8_regs;

extern byte chip8_iperiod;                      /* number of opcodes per    */
                                                /* timeslice (1/50sec.)     */
extern byte chip8_keys[16];                     /* if 1, key is held down   */
extern byte chip8_display[32][64];               /* 0xff if pixel is set,    */
                                                /* 0x00 otherwise           */
extern byte chip8_mem[64][64];                    /* machine memory. program  */
                                                /* is loaded at 0x200       */
extern byte chip8_running;                      /* if 0, emulation stops    */

extern byte chip8_redraw;                      /* if 1, must update screen (Haroldo/2001) */

void chip8_execute (void);                      /* execute chip8_iperiod    */
                                                /* opcodes                  */
void chip8_reset (void);                        /* reset virtual machine    */
void chip8 (void);                              /* start chip8 emulation    */

void chip8_sound_on (void);                     /* turn sound on            */
void chip8_sound_off (void);                    /* turn sound off           */
void chip8_interrupt (void);                    /* update keyboard,         */
                                                /* display, etc.            */

#ifdef DEBUG
extern byte chip8_trace;                        /* if 1, call debugger      */
                                                /* every opcode             */
extern word chip8_trap;                         /* if pc==trap, set trace   */
                                                /* flag                     */
void chip8_debug (word opcode,struct chip8_regs_struct *regs);
#endif

#endif          /* __CHIP8_H */

