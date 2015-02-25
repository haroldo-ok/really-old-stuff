#include <gb.h>
#include <cgb.h>
#include "cosin.h"
#include "melee.h"

void main()
{
  UBYTE i, j;

  disable_interrupts();
  DISPLAY_OFF;
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

  /* Set palettes */
  BGP_REG =  0xD8U;
  OBP0_REG = 0xE4U; 
  OBP1_REG = 0xD8U;

  melee_init();

  set_melee_colors();

  DISPLAY_ON;
  enable_interrupts();

  while(1) {
    wait_vbl_done();

    draw_ships();

    update_status_bar();

    calc_scroll();

    i = joypad();
    joy_status = i;
    //
    control_ship_joy(i,&ship[0]);
    control_ship_joy(i,&ship[1]);
    //
    handle_urquan(&ship[0]);
    handle_urquan(&ship[1]);
    //
    shot_life_delay = (shot_life_delay-1)&0x03;
  }
}
