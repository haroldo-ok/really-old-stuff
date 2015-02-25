/****************************************************************************/
/** Alphanumeric "Keyboard" Routines for Vision-8 GB                       **/
/** by Haroldo de Oliveira Pinheiro                                        **/
/****************************************************************************/

#include <gb.h>
#include <string.h>
#include "keybmap.h"
#include "keybatr.h"

void draw_keyboard(){
   set_bkg_tiles(0,12,32,6,keyboard_map);
   load_wallpaper();
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,12,32,6,keyboard_attrs);
      VBK_REG = 0;
   }
}

void read_string(char *s, UBYTE maxlen){
   char str[20],*strp,len;
   UBYTE cr_x,cr_y;
   UBYTE done;
   UBYTE joy;
   char chr;

   memset(str,3,20UL);
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,11,20,1,(unsigned char*)str);
      VBK_REG = 0;
   }

   memset(str,0,20UL);
   strcpy(str,s);
   set_bkg_tiles(0,11,20,1,(unsigned char*)str);

   strp = str;
   len = 0;
   while((*strp)&&(len != maxlen)){
      strp++;
      len++;
   }

   cr_x = 0;
   cr_y = 0;
   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);
   move_sprite(0,cr_x*8+(2*8+4),cr_y*8+(15*8+4));

   done = 0;
   while(!done){
      while(joypad());
      while(!joypad());

      joy = joypad();
      if(joy & J_LEFT){
         if(cr_x){
            cr_x--;
         }else{
            cr_x = 17;
         }
      }
      if(joy & J_RIGHT){
         if(cr_x != 17){
            cr_x++;
         }else{
            cr_x = 0;
         }
      }
      if(joy & J_UP){
         if(cr_y){
            cr_y--;
         }else{
            cr_y = 3;
         }
      }
      if(joy & J_DOWN){
         if(cr_y != 3){
            cr_y++;
         }else{
            cr_y = 0;
         }
      }
      if(joy & J_A){
         chr = keyboard_map[((UWORD)cr_y*32UL)+(UWORD)cr_x+33UL];
         if(chr&&(len != maxlen)){
            *strp = chr;
            strp++;
            len++;
         }
         set_bkg_tiles(0,11,20,1,(unsigned char*)str);
      }
      if(joy & J_B){
         if(len){
            strp--;
            len--;
            *strp = 0;
         }
         set_bkg_tiles(0,11,20,1,(unsigned char*)str);
      }
      if(joy & J_START){
         done = 1;
      }
      if(joy & J_SELECT){
         done = 2;
      }

      move_sprite(0,cr_x*8+(2*8+4),cr_y*8+(15*8+4));
   }

   if(done == 1){
      strcpy(s,str);
   }

   while(joypad());
   move_sprite(0,0,0);
}
