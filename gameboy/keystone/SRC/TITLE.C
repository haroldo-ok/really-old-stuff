#include <gb.h>
#include "title.h"
#include "titltil.h"
#include "titlmap.h"
#include "titlcdat.h"

void Show_Title(){
   UBYTE i,j;

   display_off();

   BGP_REG = 0xE4U;

   SCX_REG = 0;
   SCY_REG = 0;

   WX_REG = MAXWNDPOSX+1;
   WY_REG = MAXWNDPOSY+1;

   if(_cpu == 0x11){ // Color gameboy
      set_bkg_data(0x00, 0xFF, titl_cgb_tiles1);
      set_bkg_data(0xFF, 0x01, titl_cgb_tiles1+0x00F0L);
      VBK_REG = 1;
      set_bkg_data(0x00, 0xFF, titl_cgb_tiles2);
      VBK_REG = 0;
      set_bkg_tiles(0,0,20,18,titl_cgb_map);
      VBK_REG = 1;
      set_bkg_tiles(0,0,20,18,titl_cgb_attrs);
      VBK_REG = 0;
      set_bkg_palette(7,1,titl_cgb_pal[0]);
      set_bkg_palette(6,1,titl_cgb_pal[1]);
      set_bkg_palette(5,1,titl_cgb_pal[2]);
      set_bkg_palette(4,1,titl_cgb_pal[3]);
      set_bkg_palette(3,1,titl_cgb_pal[4]);
      set_bkg_palette(2,1,titl_cgb_pal[5]);
      set_bkg_palette(1,1,titl_cgb_pal[6]);
      set_bkg_palette(0,1,titl_cgb_pal[7]);
   }else{ // Gameboy normal
      set_bkg_data(0x00, 0xFF, tiledata);
      set_bkg_tiles(0,0,20,18,tilemap);
   }

   for(i = 0; i != 40; i++){
      move_sprite(i,0,0);
   }

   DISPLAY_ON;

   i = 0;
   while(!(i & J_START)){
      i = joypad();
   }
   while(i & J_START){
      i = joypad();
   }
}
