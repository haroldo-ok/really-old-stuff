/** Vision8: CHIP8 emulator *************************************************/
/**                                                                        **/
/**                                CHIP8.c                                 **/
/**                                                                        **/
/** This file contains the portable CHIP8 emulation engine                 **/
/**                                                                        **/
/** Copyright (C) Marcel de Kogel 1997                                     **/
/**     You are not allowed to distribute this software commercially       **/
/**     Please, notify me, if you make any changes to this file            **/
/****************************************************************************/

/****************************************************************************/
/** Ported to GameBoy by Haroldo de Oliveira Pinheiro                      **/
/****************************************************************************/

#include "CHIP8.h"

#include <stdlib.h>
#include <string.h>
#include <gb.h>

byte chip8_mem[64][64];
#define read_mem(a)     (chip8_mem[0][((word)a)&4095U])
#define write_mem(a,v)  (chip8_mem[0][((word)a)&4095U]=(v))

byte chip8_iperiod;

#ifdef DEBUG
byte chip8_trace;
word chip8_trap;
#endif

struct chip8_regs_struct chip8_regs;

static byte chip8_key_pressed;
byte chip8_keys[16];
byte chip8_display[32][64];
byte chip8_running;
byte chip8_redraw;

#define get_reg_offset(opcode)          (chip8_regs.alg+(opcode>>8))
#define get_reg_value(opcode)           (*get_reg_offset(opcode))
#define get_reg_offset_2(opcode)        (chip8_regs.alg+((opcode>>4)&0x0f))
#define get_reg_value_2(opcode)         (*get_reg_offset_2(opcode))

typedef void (*opcode_fn) (word opcode);
typedef void (*math_fn) (byte *reg1,byte reg2);

static void op_call (word opcode)
{
 chip8_regs.sp--;
 write_mem (chip8_regs.sp,chip8_regs.pc&0xff);
 chip8_regs.sp--;
 write_mem (chip8_regs.sp,chip8_regs.pc>>8);
 chip8_regs.pc=opcode;
}

static void op_jmp (word opcode)
{
 chip8_regs.pc=opcode;
}

static void op_key (word opcode)
{
 byte key_value,cp_value;
 if ((opcode&0xff)==0x9e)
  cp_value=1;
 else if ((opcode&0xff)==0xa1)
  cp_value=0;
 else
  return;
 key_value=chip8_keys[get_reg_value(opcode)&0x0f];
 if (cp_value==key_value) chip8_regs.pc+=2;
}

static void op_skeq_const (word opcode)
{
 if (get_reg_value(opcode)==(opcode&0xff)) chip8_regs.pc+=2;
}

static void op_skne_const (word opcode)
{
 if (get_reg_value(opcode)!=(opcode&0xff)) chip8_regs.pc+=2;
}

static void op_skeq_reg (word opcode)
{
 if (get_reg_value(opcode)==get_reg_value_2(opcode)) chip8_regs.pc+=2;
}

static void op_skne_reg (word opcode)
{
 if (get_reg_value(opcode)!=get_reg_value_2(opcode)) chip8_regs.pc+=2;
}

static void op_mov_const (word opcode)
{
 *get_reg_offset(opcode)=opcode&0xff;
}

static void op_add_const (word opcode)
{
 *get_reg_offset(opcode)+=opcode&0xff;
}

static void op_mvi (word opcode)
{
 chip8_regs.i=opcode;
}

static void op_jmi (word opcode)
{
 chip8_regs.pc=opcode+chip8_regs.alg[0];
}

static void op_rand (word opcode)
{
 *get_reg_offset(opcode)=rand()&(opcode&0xff);
}

static void math_or (byte *reg1,byte reg2)
{
 *reg1|=reg2;
}

static void math_mov (byte *reg1,byte reg2)
{
 *reg1=reg2;
}

static void math_nop (byte *reg1,byte reg2)
{
}

static void math_and (byte *reg1,byte reg2)
{
 *reg1&=reg2;
}

static void math_xor (byte *reg1,byte reg2)
{
 *reg1^=reg2;
}

static void math_add (byte *reg1,byte reg2)
{
 word tmp;
 tmp=(word)*reg1+(word)reg2;
 *reg1=(byte)tmp;
 chip8_regs.alg[15]=tmp>>8;
}

static void math_sub (byte *reg1,byte reg2)
{
 word tmp;
 tmp=(word)*reg1-(word)reg2;
 *reg1=(byte)tmp;
 chip8_regs.alg[15]=((byte)(tmp>>8))+1;
}

static void math_shr (byte *reg1,byte reg2)
{
 chip8_regs.alg[15]=*reg1&1;
 *reg1>>=1;
}

static void math_shl (byte *reg1,byte reg2)
{
 chip8_regs.alg[15]=*reg1>>7;
 *reg1<<=1;
}

static void math_rsb (byte *reg1,byte reg2)
{
 word tmp;
 tmp=(word)reg2-(word)*reg1;
 *reg1=(byte)tmp;
 chip8_regs.alg[15]=((byte)(tmp>>8))+1;
}

static void op_system (word opcode)
{
 byte i;
 switch ((byte)opcode)
 {
  case 0xe0:
   memset (chip8_display[0],0,sizeof(chip8_display));
   chip8_redraw = 1;
   break;
  case 0xee:
   chip8_regs.pc=(word)read_mem(chip8_regs.sp)<<8;
   chip8_regs.sp++;
   chip8_regs.pc+=read_mem(chip8_regs.sp);
   chip8_regs.sp++;
   break;
 }
}

static void op_misc (word opcode)
{
 byte *reg,i,j;
 reg=get_reg_offset(opcode);
 switch ((byte)opcode)
 {
  case 0x07:
   *reg=chip8_regs.delay;
   break;
  case 0x0a:
   if (chip8_key_pressed)
    *reg=chip8_key_pressed-1;
   else
    chip8_regs.pc-=2;
   break;
  case 0x15:
   chip8_regs.delay=*reg;
   break;
  case 0x18:
   chip8_regs.sound=*reg;
   if (chip8_regs.sound) chip8_sound_on();
   break;
  case 0x1e:
   chip8_regs.i+=(*reg);
   break;
  case 0x29:
   chip8_regs.i=((word)(*reg&0x0f))*5;
   break;
  case 0x33:
   i=*reg;
   for (j=0;i>=100;i-=100) j++;
   write_mem (chip8_regs.i,j);
   for (j=0;i>=10;i-=10) j++;
   write_mem (chip8_regs.i+1,j);
   write_mem (chip8_regs.i+2,i);
   break;
  case 0x55:
   for (i=0,j=(opcode>>8)&0x0f;i<=j;++i)
    write_mem(chip8_regs.i+i,chip8_regs.alg[i]);
   break;
  case 0x65:
   for (i=0,j=(opcode>>8)&0x0f;i<=j;++i)
    chip8_regs.alg[i]=read_mem(chip8_regs.i+i);
   break;
 }
}

static void op_sprite (word opcode)
{
 byte *q;
 byte n,x,x2,y,collision;
 word p;
 word tmp;
 byte i,j;
 x=get_reg_value(opcode)&63;
 y=get_reg_value_2(opcode)&31;

/*
 p=chip8_regs.i;
 n=opcode&0x0f;
 if (n+y>32) n=32-y;
 collision=1;
 for(i = 0; i != n; i++){
    x2 = read_mem(p++);
    for(j = 0; j != 8; j++){
       if(x2 & 0x80){
          plot((x+j)&63,y+i,BLACK,XOR);
       }
       x2 += x2;
    }
 }
*/

 p=chip8_regs.i;
 q=chip8_display[0]+((word)y*64UL);
 n=opcode&0x0f;
 if (n+y>32) n=32-y;
 for (collision=1;n;--n,q+=64L)
 {
  for (y=read_mem(p++),x2=x;y;y<<=1,x2=(x2+1)&63)
   if (y&0x80) collision&=(q[x2]^= 0x01);
 }

 chip8_regs.alg[15]=collision^1;

 chip8_redraw = 1;
}

static math_fn math_opcodes[16]=
{
 math_mov,
 math_or,
 math_and,
 math_xor,
 math_add,
 math_sub,
 math_shr,
 math_rsb,
 math_nop,
 math_nop,
 math_nop,
 math_nop,
 math_nop,
 math_nop,
 math_shl,
 math_nop
};

static void op_math (word opcode)
{
 (*(math_opcodes[opcode&0x0f]))
        (get_reg_offset(opcode),get_reg_value_2(opcode));
}

static opcode_fn main_opcodes[16]=
{
 op_system,
 op_jmp,
 op_call,
 op_skeq_const,
 op_skne_const,
 op_skeq_reg,
 op_mov_const,
 op_add_const,
 op_math,
 op_skne_reg,
 op_mvi,
 op_jmi,
 op_rand,
 op_sprite,
 op_key,
 op_misc
};

/****************************************************************************/
/* Execute chip8_iperiod opcodes                                            */
/****************************************************************************/
void chip8_execute (void)
{
 byte i;
 byte key_pressed=0;
 fixed opcode;
 for (i=chip8_iperiod;i;--i)
 {
  /* Fetch the opcode */
//  opcode=((word)read_mem(chip8_regs.pc)<<8)+read_mem(chip8_regs.pc+1);
  opcode.b.h=read_mem(chip8_regs.pc);
  opcode.b.l=read_mem(chip8_regs.pc+1);
#ifdef DEBUG
  /* Check if trap address has been reached */
  if ((chip8_regs.pc&4095)==chip8_trap) chip8_trace=1;
  /* Call the debugger if chip8_trace!=0 */
  if (chip8_trace) chip8_debug (opcode.w,&chip8_regs);
#endif
  chip8_regs.pc+=2;
  /* Emulate this opcode */
  (*(main_opcodes[opcode.w>>12]))(opcode.w&0x0fff);
 }
 /* Update timers */
 if (chip8_regs.delay) --chip8_regs.delay;
 if (chip8_regs.sound)
  if (!--chip8_regs.sound) chip8_sound_off();
 /* Update the machine status */
 chip8_interrupt ();
 for (i=key_pressed=0;i<16;++i)                 /* check if a key was first */
  if (chip8_keys[i]) key_pressed=i+1;           /* pressed                  */
 if (key_pressed && key_pressed!=chip8_key_pressed)
  chip8_key_pressed=key_pressed;
 else
  chip8_key_pressed=0;
}

/****************************************************************************/
/* Reset the virtual chip8 machine                                          */
/****************************************************************************/
void chip8_reset (void)
{
 static byte chip8_sprites[16*5]=
 {
  0xf9,0x99,0xf2,0x62,0x27,
  0xf1,0xf8,0xff,0x1f,0x1f,
  0x99,0xf1,0x1f,0x8f,0x1f,
  0xf8,0xf9,0xff,0x12,0x44,
  0xf9,0xf9,0xff,0x9f,0x1f,
  0xf9,0xf9,0x9e,0x9e,0x9e,
  0xf8,0x88,0xfe,0x99,0x9e,
  0xf8,0xf8,0xff,0x8f,0x88,
 };
 byte i;
 for (i=0;i<16*5;++i)
 {
  write_mem (i<<1,chip8_sprites[i]&0xf0);
  write_mem ((i<<1)+1,chip8_sprites[i]<<4);
 }
 memset (chip8_regs.alg,0,sizeof(chip8_regs.alg));
 memset (chip8_keys,0,sizeof(chip8_keys));
 chip8_key_pressed=0;
 memset (chip8_display,0,sizeof(chip8_display));
 chip8_regs.delay=chip8_regs.sound=chip8_regs.i=0;
 chip8_regs.sp=0x1e0;
 chip8_regs.pc=0x200;
 chip8_sound_off ();
 chip8_running=1;
 chip8_redraw=1;
#ifdef DEBUG
 chip8_trace=0;
#endif
}

/****************************************************************************/
/* Start CHIP8 emulation                                                    */
/****************************************************************************/
void chip8 (void)
{
 chip8_reset ();
 while (chip8_running) chip8_execute ();
}
