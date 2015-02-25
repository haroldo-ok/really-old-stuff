#include <gb.h>
#include <string.h>
#include "raycaste.h"
#include "textures.h"
#include "speedup.h"

UBYTE curr_bank;

void texline();
void texline_maskout();
void cleantexline();

extern UWORD txl_tex;

// Gambiarra necess ria
void do_texline(UBYTE tex_x,UBYTE tex_y){
   SWITCH_ROM_MBC1(2);
   txl_tex = textures[tex_x][tex_y];
   texline();
   SWITCH_ROM_MBC1(curr_bank);
}

void do_texline_maskout(UBYTE tex_x,UBYTE tex_y){
   SWITCH_ROM_MBC1(2);
   txl_tex = tex_masks[tex_x][tex_y];
   texline_maskout();
   SWITCH_ROM_MBC1(curr_bank);
}

void do_cleantexline(){
   SWITCH_ROM_MBC1(2);
   cleantexline();
   SWITCH_ROM_MBC1(curr_bank);
}

void main()
{

  if(_cpu == 0x11){ // Color GameBoy
     SpeedUp();
  }

  disable_interrupts();
  DISPLAY_OFF;
  LCDC_REG = 0x67;
  /*
   * LCD        = Off
   * WindowBank = 0x9C00
   * Window     = On
   * BG Chr     = 0x8800
   * BG Bank    = 0x9800
   * OBJ        = 8x16
   * OBJ        = On
   * BG         = On
   */

  /* Set palettes */
  BGP_REG = OBP0_REG = OBP1_REG = 0xE4U;

  /* Initialize the background */
//  SCX_REG = 256-16;
//  SCY_REG = 256-8;
  SCX_REG = 0;
  SCY_REG = 0;

  /* Initialize the window */
  WX_REG = MAXWNDPOSX;
  WY_REG = MAXWNDPOSY;

  DISPLAY_ON;
  enable_interrupts();

  curr_bank = 1;
  SWITCH_ROM_MBC1(curr_bank);

  init_raycast();

  while(1){
     raycast();
  }
}
