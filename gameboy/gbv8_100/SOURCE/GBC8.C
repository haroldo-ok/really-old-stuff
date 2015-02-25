/** Vision8: CHIP8 emulator *************************************************/
/**                                                                        **/
/**                                MSDOS.c                                 **/
/**                                                                        **/
/** This file contains the MS-DOS implementation                           **/
/**                                                                        **/
/** Copyright (C) Marcel de Kogel 1997                                     **/
/**     You are not allowed to distribute this software commercially       **/
/**     Please, notify me, if you make any changes to this file            **/
/**                                                                        **/
/** Ported to GameBoy by Haroldo de Oliveira Pinheiro                      **/
/****************************************************************************/

#include "CHIP8.h"

#include <gb.h>
#include <string.h>
#include <drawing.h>
#include "dblspeed.h"

#include "c8bkt.h"
#include "c8bkm.h"
#include "c8bka.h"

#define _C8_JOY_UP      0
#define _C8_JOY_DOWN    1
#define _C8_JOY_LEFT    2
#define _C8_JOY_RIGHT   3
#define _C8_JOY_A       4
#define _C8_JOY_B       5
#define _C8_JOY_START   6
#define _C8_JOY_SELECT  7
#define C8_JOY(n) (chip8_keys[chip8_key_conf[n]])
UBYTE chip8_key_conf[8];

extern UWORD default_bkg_palette[];

/****************************************************************************/
/* Turn sound on                                                            */
/****************************************************************************/
void chip8_sound_on (void)
{
   NR10_REG = 0x00;
   NR11_REG = 0x80;
   NR12_REG = 0xF0;
   NR13_REG = 0x00;
   NR14_REG = 0x83;

   NR50_REG=0x77;
   NR51_REG=0xFF;
   NR52_REG=0xFF;
}

/****************************************************************************/
/* Turn sound off                                                           */
/****************************************************************************/
void chip8_sound_off (void)
{
   NR52_REG=0x00;
}

/****************************************************************************/
/* Hardware timer								                            */
/****************************************************************************/
#define VBL_INCREMENT 0x00C9UL
fixed timer_ctrl;
void c8emu_VBL(){
   timer_ctrl.w += VBL_INCREMENT; // Tenta "converter" o timer de 70Hz em um de 55Hz
}

/****************************************************************************/
/* Update the display                                                       */
/****************************************************************************/

extern void toscreen_64_32();
UBYTE *Junk;
static void update_display (void)
{
   UBYTE i,j;

#ifdef OLDWAY
   Junk = chip8_display[0];
   for (i=0; i != 32; i++){                             /* 32 rows                  */
      for (j=0; j != 64; j++){                            /* 64 columns               */
         if(*Junk != 0){
            plot(j,i,BLACK,SOLID);
         }else{
            plot(j,i,WHITE,SOLID);
         }
	     Junk++;
      }
   }
#endif
   toscreen_64_32();
}

/****************************************************************************/
/* Update CHIP8 keyboard status                                             */
/****************************************************************************/
static void check_keys (void)
{
   UBYTE i, j, k, l;
   /* start with all keys up */
   memset (chip8_keys,0,sizeof(chip8_keys));
   for(i = 0; i != 16; i++){
      move_sprite(i,0,0);
   }
   /* Lˆ o joystick */
   i = joypad();
   if(i & J_UP){
      C8_JOY(_C8_JOY_UP) = 1;
      move_sprite(0,10*8,15*8);
   }
   if(i & J_DOWN){
      C8_JOY(_C8_JOY_DOWN) = 1;
      move_sprite(1,10*8,17*8);
   }
   if(i & J_LEFT){
      C8_JOY(_C8_JOY_LEFT) = 1;
      move_sprite(2,9*8,16*8);
   }
   if(i & J_RIGHT){
      C8_JOY(_C8_JOY_RIGHT) = 1;
      move_sprite(3,11*8,16*8);
   }
   if(i & J_A){
      C8_JOY(_C8_JOY_A) = 1;
      move_sprite(4,17*8,16*8);
   }
   if(i & J_B){
      C8_JOY(_C8_JOY_B) = 1;
      move_sprite(5,19*8,16*8);
   }
   if(i & J_START){
      C8_JOY(_C8_JOY_START) = 1;
      move_sprite(6,14*8,15*8);
   }
   if(i & J_SELECT){
      C8_JOY(_C8_JOY_SELECT) = 1;
      move_sprite(7,15*8,15*8);
   }
   if((i & J_START) && (i & J_SELECT)){
      chip8_running = 0;
   }
   /* Mostra as teclas pressionadas */
   j = 8;
   k = 0;
   l = 0;
   for(i = 0; i != 16; i++){
      if(chip8_keys[i]){
         move_sprite(j++,k+(2*8),l+(15*8));
      }
      k = (k+8) & 0x1F;
      if(!k){
         l += 8;
      }
   }
}

/****************************************************************************/
/* Update keyboard and display, sync emulation with hardware timer          */
/****************************************************************************/
UBYTE frame_skip;
void chip8_interrupt (void)
{
   if(chip8_redraw&&!frame_skip){
      update_display ();
      chip8_redraw = 0;
      frame_skip = timer_ctrl.b.h;
   }
   if(frame_skip){
      frame_skip--;
   }

   check_keys ();

   while(!timer_ctrl.b.h);
   timer_ctrl.b.h--;
}

/****************************************************************************/
/* Parse command line options and start emulation                           */
/****************************************************************************/
unsigned char bkg_map[]={
0x00,0x08,0x10,0x18,0x20,0x28,0x30,0x38,0x40,0x48,0x50,0x58,0x60,0x68,0x70,0x78,
0x01,0x09,0x11,0x19,0x21,0x29,0x31,0x39,0x41,0x49,0x51,0x59,0x61,0x69,0x71,0x79,
0x02,0x0A,0x12,0x1A,0x22,0x2A,0x32,0x3A,0x42,0x4A,0x52,0x5A,0x62,0x6A,0x72,0x7A,
0x03,0x0B,0x13,0x1B,0x23,0x2B,0x33,0x3B,0x43,0x4B,0x53,0x5B,0x63,0x6B,0x73,0x7B,
0x04,0x0C,0x14,0x1C,0x24,0x2C,0x34,0x3C,0x44,0x4C,0x54,0x5C,0x64,0x6C,0x74,0x7C,
0x05,0x0D,0x15,0x1D,0x25,0x2D,0x35,0x3D,0x45,0x4D,0x55,0x5D,0x65,0x6D,0x75,0x7D,
0x06,0x0E,0x16,0x1E,0x26,0x2E,0x36,0x3E,0x46,0x4E,0x56,0x5E,0x66,0x6E,0x76,0x7E,
0x07,0x0F,0x17,0x1F,0x27,0x2F,0x37,0x3F,0x47,0x4F,0x57,0x5F,0x67,0x6F,0x77,0x7F
};

UBYTE emu_state,selected_game;

void do_emulation(){
   UBYTE i;

   DISPLAY_OFF;
   disable_interrupts();
   LCDC_REG = 0x63;
  /*
   * LCD        = Off
   * WindowBank = 0x9C00
   * Window     = On
   * BG Chr     = 0x8800
   * BG Bank    = 0x9800
   * OBJ        = 8x8
   * OBJ        = On
   * BG         = On
   */
   set_bkg_data(0x80,0x80,chip8_bk_tiles);
   set_bkg_tiles(0,0,32,18,chip8_bk_map);
   load_wallpaper();

   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,0,32,18,chip8_bk_attr);
      VBK_REG = 0;
   }

   set_bkg_tiles(2,2,16,8,bkg_map);
   WY_REG = MAXWNDPOSY+1;

   for(i = 0; i != 16; i++){
      set_sprite_tile(i,0xAB);
      set_sprite_prop(i,0);
      move_sprite(i,0,0);
   }
   chip8_key_conf[0] = 0;
   chip8_key_conf[1] = 1;
   chip8_key_conf[2] = 0x4;
   chip8_key_conf[3] = 0x6;
   chip8_key_conf[4] = 0;
   chip8_key_conf[5] = 0x5;
   chip8_key_conf[6] = 2;
   chip8_key_conf[7] = 3;

   enable_interrupts();
   DISPLAY_ON;

   timer_ctrl.w = 0x0000UL;
   frame_skip = 0;

   chip8_iperiod=15;

   load_chip8_prog(selected_game);
   chip8 ();                                      /* start emulation          */

   chip8_sound_off();

   for(i = 0; i != 16; i++){
      move_sprite(i,0,0);
   }
   emu_state = 0;
}

int main (int argc,char *argv[])
{
  UBYTE i;

  DISPLAY_OFF;
  disable_interrupts();
  LCDC_REG = 0x63;
  /*
   * LCD        = Off
   * WindowBank = 0x9C00
   * Window     = On
   * BG Chr     = 0x8800
   * BG Bank    = 0x9800
   * OBJ        = 8x8
   * OBJ        = On
   * BG         = On
   */

  if(_cpu == 0x11){
     SwitchSpeed();
     load_default_pal();
  }

  add_VBL(c8emu_VBL);

  init_comm();

  enable_interrupts();
  DISPLAY_ON;

  if(!check_signature()){
     while(1);
  }
  emu_state = 0;

  while(1){
     switch(emu_state){
        case 0:
           do_desktop();
        break;
        case 1:
           do_emulation();
        break;
        case 2:
           do_system_setup();
        break;
        case 3:
           do_keyboard_setup();
        break;
        case 4:
           do_rename();
        break;
        case 5:
           do_communication();
        break;
        default:
           emu_state = 0;
        break;
     }
  }

  return 0;                                      /* all done                 */
}
