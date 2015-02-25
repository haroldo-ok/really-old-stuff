/****************************************************************************/
/** "Desktop Manager" Routines for Vision-8 GB                             **/
/** by Haroldo de Oliveira Pinheiro                                        **/
/****************************************************************************/

#include "CHIP8.h"

#include <gb.h>
#include <string.h>
#include <drawing.h>

#include "c8dskm.h"
#include "c8dska.h"
#include "c8kyset.h"
#include "c8kyseta.h"
#include "charset.h"

char *hex_str[]={
"0","1","2","3",
"4","5","6","7",
"8","9","A","B",
"C","D","E","F"
};

extern UBYTE emu_state,selected_game;
extern unsigned char chip8_bk_tiles[];
extern char prog_names[7][12];
extern UBYTE chip8_key_conf[8];
extern UBYTE background_number;
extern UWORD wallpaper_palettes[];

void status_line(char *str){
   char tmp[20],*p;
   
   memset(tmp,0,20L);
   p = tmp;
   strcpy(tmp,str);
   set_bkg_tiles(0,17,20,1,(unsigned char *)tmp);
}

void putsxy(UBYTE X, UBYTE Y, char *str){
   set_bkg_tiles(X,Y,strlen(str),1,(unsigned char *)str);
}

void load_wallpaper(){
   set_bkg_data(0x80,0x01,(chip8_bk_tiles+0x0700)+(background_number << 4));
   if(_cpu == 0x11){
      set_bkg_palette(7,1,&wallpaper_palettes[background_number << 2]);
   }
}

void do_desktop(){
   UBYTE cr_x,cr_y,cr_sel;
   UBYTE i,joydelay;
   UBYTE done;

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

   load_save_sysconf(FALSE);

   set_bkg_data(0x80,0x80,chip8_bk_tiles);
   set_bkg_data(0x00,0x80,character_set);
   set_bkg_tiles(0,0,32,18,chip8_desktop_map);
   status_line("Vision-8 GB");
   load_wallpaper();
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,0,32,18,chip8_desktop_attr);
      VBK_REG = 0;
   }

   cr_x = 0;
   cr_y = 0;
   cr_sel = 0;

   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);
   move_sprite(0,cr_x*(5*8)+24,cr_y*(4*8)+32);

   WY_REG = MAXWNDPOSY+1;

   preload_headers();

   enable_interrupts();
   DISPLAY_ON;

   while(joypad());

   joydelay = 0;
   done = FALSE;
   while(!done){
      i = joypad();

      if(!i){
         joydelay = 0;
      }else if (joydelay){
         joydelay--;
      }else{
         if(i&J_UP){
            cr_y--;
            cr_y &= 0x03;
         }
         if(i&J_DOWN){
            cr_y++;
            cr_y &= 0x03;
         }
         if(i&J_LEFT){
            cr_x--;
            cr_x &= 0x03;
         }
         if(i&J_RIGHT){
            cr_x++;
            cr_x &= 0x03;
         }
         if(i&(J_A|J_B|J_START|J_SELECT)){
            switch(cr_sel){
               case 0:
               case 1:
               case 2:
               case 3:
               case 4:
               case 5:
               case 6:
                  selected_game = cr_sel+1;
                  emu_state = 1;
                  done = TRUE;
               break;
               case 8:
                  emu_state = 2;
                  done = TRUE;
               break;
               case 9:
                  emu_state = 3;
                  done = TRUE;
               break;
               case 10:
                  emu_state = 4;
                  done = TRUE;
               break;
               case 11:
                  emu_state = 5;
                  done = TRUE;
               break;
            }
         }

         cr_sel = (cr_y << 2)|cr_x;
         move_sprite(0,cr_x*(5*8)+24,cr_y*(4*8)+32);
         switch(cr_sel){
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
               status_line(prog_names[cr_sel]);
            break;
            case 8:
               status_line("System Config");
            break;
            case 9:
               status_line("Keyboard Config");
            break;
            case 10:
               status_line("Rename");
            break;
            case 11:
               status_line("GB Game Link");
            break;
            default:
               status_line("Vision-8 GB");
            break;
         }
         joydelay = 45;
      }

      wait_vbl_done();
   }

   while(joypad());
   move_sprite(0,0,0);
}

UBYTE get_menu_choice(UBYTE X, UBYTE Y, UBYTE count, UBYTE okcancel){
   UBYTE i;
   UBYTE opt;
   UBYTE joydelay;
   UBYTE count2;

   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);
   move_sprite(0,X,Y);

   count2 = count;
   if(okcancel){
      count2 += 2;
   }

   i = joypad();
   opt = 0;
   joydelay = 0;
   while(!(i&(J_A|J_B|J_START|J_SELECT))){
      if(!i){
         joydelay = 0;
      }else if(joydelay){
         joydelay--;
      }else{
         if(i&(J_UP|J_LEFT)){
            if(opt){
               opt--;
            }else{
               opt = count2-1;
            }
         }
         if(i&(J_DOWN|J_RIGHT)){
            opt++;
            opt %= count2;
         }
         if(okcancel&&(opt >= count)){
            if(opt == count){
               move_sprite(0,10*8,(18*8)+4);
            }else{
               move_sprite(0,13*8,(18*8)+4);
            }
         }else{
            move_sprite(0,X,(opt*8)+Y);
         }
         joydelay = 45;
      }

      wait_vbl_done();
      check_io_requests();
      i = joypad();
   }

   move_sprite(0,0,0);

   return opt;
}

UBYTE read_keypad(UBYTE X, UBYTE Y){
   UBYTE row,col;
   UBYTE joydelay;
   UBYTE i;

   row = 0;
   col = 0;
   joydelay = 0;

   move_sprite(0,X,Y);
   while(joypad());

   i = 0;
   while(!(i&(J_A|J_B|J_START|J_SELECT))){
      if(!i){
         joydelay = 0;
      }else if(joydelay){
         joydelay--;
      }else{
         if(i&J_UP){
            row--;
            row &= 0x03;
         }
         if(i&J_DOWN){
            row++;
            row &= 0x03;
         }
         if(i&J_LEFT){
            col--;
            col &= 0x03;
         }
         if(i&J_RIGHT){
            col++;
            col &= 0x03;
         }
         move_sprite(0,(col*8)+X,(row*8)+Y);
         joydelay = 45;
      }

      wait_vbl_done();
      i = joypad();
   }

   while(joypad());
   return ((row << 2)|col);
}

void do_keyboard_setup(){
   UBYTE i;
   UBYTE opt;

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
   set_bkg_data(0x00,0x80,character_set);
   set_bkg_tiles(0,0,32,18,chip8_key_setup);
   load_wallpaper();
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,0,32,18,chip8_key_setup_attr);
      VBK_REG = 0;
   }

   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);

   WY_REG = MAXWNDPOSY+1;

   preload_headers();
   for(i = 0; i != 7; i++){
      putsxy(2,i+3,prog_names[i]);
   }

   enable_interrupts();
   DISPLAY_ON;

   while(joypad());

   selected_game = get_menu_choice(10*8,(5*8)+4,7,FALSE);

   while(joypad());

   load_save_chip8_keys(selected_game+1,FALSE);

   set_bkg_tiles(0,0,32,18,chip8_key_setup);
   putsxy(2,2,prog_names[selected_game]);
   putsxy(2,3,"Up:");
   putsxy(2,4,"Down:");
   putsxy(2,5,"Left:");
   putsxy(2,6,"Right:");
   putsxy(2,7,"A:");
   putsxy(2,8,"B:");
   putsxy(2,9,"Start:");
   putsxy(2,10,"Select:");

   opt = 0;
   while(opt < 8){
      for(i = 0; i != 8; i++){
         putsxy(10,i+3,hex_str[chip8_key_conf[i]]);
      }

      opt = get_menu_choice(12*8,(5*8)+4,8,TRUE);

      if(opt < 8){
         chip8_key_conf[opt] = read_keypad((3*8)+4,(15*8)+4);
      }
   }

   if(opt == 8){
      load_save_chip8_keys(selected_game+1,TRUE);
   }

   while(joypad());
   move_sprite(0,0,0);
   emu_state = 0;
}

void do_system_setup(){
   UBYTE i;
   UBYTE opt;
   UBYTE done;
   UBYTE joy,joydelay;

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
   set_bkg_data(0x00,0x80,character_set);
   set_bkg_tiles(0,0,32,18,chip8_key_setup);
   load_wallpaper();
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,0,32,18,chip8_key_setup_attr);
      VBK_REG = 0;
   }

   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);

   WY_REG = MAXWNDPOSY+1;

   load_save_sysconf(FALSE);
   putsxy(2,2,"Walpaper:");
   putsxy(2,3,"\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF");
   if(_cpu == 0x11){
      VBK_REG = 1;
      putsxy(2,3,"\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03");
      VBK_REG = 0;
   }

   enable_interrupts();
   DISPLAY_ON;

   while(joypad());

   opt = 0;
   done = FALSE;
   joydelay = 0;
   while(!done){
      wait_vbl_done();
      joy = joypad();
      if(!joy){
         joydelay = 0;
      }else if(joydelay){
         joy = 0;
         joydelay--;
      }else{
         joydelay = 45;
      }
      switch(opt){
         case 0:
            move_sprite(0,((3*8)+4)+(background_number << 3),((8*5)+4));
            if(joy & J_LEFT){
               background_number--;
               background_number &= 0x0F;
            }
            if(joy & J_RIGHT){
               background_number++;
               background_number &= 0x0F;
            }
         break;
         case 1:
            move_sprite(0,10*8,(18*8)+4);
         break;
         case 2:
            move_sprite(0,13*8,(18*8)+4);
         break;
      }
      if(joy & J_UP){
         if(!opt){
            opt = 2;
         }else{
            opt--;
         }
      }
      if(joy & J_DOWN){
         if(opt == 2){
            opt = 0;
         }else{
            opt++;
         }
      }
      if(joy & (J_A|J_B|J_START|J_SELECT)){
         if(opt >= 1){
            done = TRUE;
         }
      }
   }

   while(joypad());

   if(opt == 1){
      load_save_sysconf(TRUE);
   }else{
      load_save_sysconf(FALSE);
   }

   while(joypad());
   move_sprite(0,0,0);
   emu_state = 0;
}

void do_rename(){
   UBYTE i;
   UBYTE opt;

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
   set_bkg_data(0x00,0x80,character_set);
   set_bkg_tiles(0,0,32,18,chip8_key_setup);
   load_wallpaper();
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,0,32,18,chip8_key_setup_attr);
      VBK_REG = 0;
   }
   draw_keyboard();

   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);

   WY_REG = MAXWNDPOSY+1;

   preload_headers();
   for(i = 0; i != 7; i++){
      putsxy(2,i+3,prog_names[i]);
   }

   enable_interrupts();
   DISPLAY_ON;

   while(joypad());

   selected_game = get_menu_choice(10*8,(5*8)+4,7,FALSE);

   while(joypad());

   read_string(prog_names[selected_game],10);

   if(*prog_names[selected_game]){
      save_chip8_name(selected_game+1,prog_names[selected_game]);
   }

   while(joypad());
   move_sprite(0,0,0);
   emu_state = 0;
}

void do_communication(){
   UBYTE i;
   UBYTE opt;
   char name[16];
   UWORD size;

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
   set_bkg_data(0x00,0x80,character_set);
   set_bkg_tiles(0,0,32,18,chip8_key_setup);
   load_wallpaper();
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0,0,32,18,chip8_key_setup_attr);
      VBK_REG = 0;
   }

   set_sprite_tile(0,0xAF);
   set_sprite_prop(0,0);

   WY_REG = MAXWNDPOSY+1;

   enable_interrupts();
   DISPLAY_ON;

   putsxy(2,2,"Connecting...");
   negotiate_connect();
   request_remote_list();
   putsxy(2,2,"Select program");
   for(i = 0; i != 7; i++){
      putsxy(2,i+3,prog_names[i]);
   }

   while(joypad()) check_io_requests();;

   selected_game = get_menu_choice(10*8,(5*8)+4,7,TRUE);
   while(selected_game < 7){
      opt = selected_game;
      strcpy(name,prog_names[opt]);

      while(joypad()) check_io_requests();
      set_bkg_tiles(0,0,32,18,chip8_key_setup);
      preload_headers();
      putsxy(2,2,"Select slot   ");
      for(i = 0; i != 7; i++){
         putsxy(2,i+3,prog_names[i]);
      }
      selected_game = get_menu_choice(10*8,(5*8)+4,7,TRUE);

      if(selected_game < 7){
         set_bkg_tiles(0,0,32,18,chip8_key_setup);
         putsxy(2,2,"Downloading");
         putsxy(2,3,name);
         putsxy(2,4,"Please, wait.");
         request_remote_program(opt+1,&size);
         putsxy(2,5,"Saving...");
         save_chip8_prog(selected_game+1,size,name);

         while(joypad()) check_io_requests();
         set_bkg_tiles(0,0,32,18,chip8_key_setup);
         request_remote_list();
         putsxy(2,2,"Select program");
         for(i = 0; i != 7; i++){
            putsxy(2,i+3,prog_names[i]);
         }
         selected_game = get_menu_choice(10*8,(5*8)+4,7,TRUE);
      }
   }

   while(joypad()) check_io_requests();
   move_sprite(0,0,0);
   emu_state = 0;
}
