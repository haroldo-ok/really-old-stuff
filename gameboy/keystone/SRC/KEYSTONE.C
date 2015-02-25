
#include <gb.h>
#include "border.h"	  // a borda do Super Gameboy
#include "gamedata.h" // dados e fun‡äes usadas no jogo
#include "speedup.h"  // rotina tirada do jogo Crazy Zone, aumenta velocidade
#include "keystone.h" // include principal do jogo
#include "title.h"	  // tela-t¡tulo do jogo
#include "levels.h"   // mapas das fases do jogo

UBYTE elev_frame_map[]={
0x00,0x01,0x02,0x03,0x04,0x05,0xF6,0x05,0x04,0x03,0x03,0x02,0x01,0x00
};

UBYTE map_columns[][2]={
{0,0},{0,1},{0,2},{0,3},{0,4},
{1,0},{1,1},{1,2},{1,3},{1,4},
{2,0},{2,1},{2,2},{2,3},{2,4},
{3,0},{3,1},{3,2},{3,3},{3,4},
{4,0},{4,1},{4,2},{4,3},{4,4},
{5,0},{5,1},{5,2},{5,3},{5,4},
{6,0},{6,1},{6,2},{6,3},{6,4},
{7,0},{7,1},{7,2},{7,3},{7,4}
};

UBYTE map_room_column[]={0,20,8,28,16,4,24,12};

#define _CGB_RGB(R,G,B) ((B << 10)|(G << 5)|R)

UWORD default_bkg_palette[]={
_CGB_RGB(0x0DL,0x0FL,0x0FL),
//_CGB_RGB(0x12L,0x0DL,0x00L),
//_CGB_RGB(0x18L,0x16L,0x06L),
_CGB_RGB(0x0FL,0x00L,0x00L),
_CGB_RGB(0x12L,0x0DL,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

/*
UWORD sky_bkg_palette[]={
_CGB_RGB(0x1FL,0x1DL,0x04L),
_CGB_RGB(0x0FL,0x00L,0x00L),
_CGB_RGB(0x12L,0x0DL,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};
*/
UWORD sky_bkg_palette[]={
_CGB_RGB(0x04L,0x04L,0x1FL),
_CGB_RGB(0x00L,0x00L,0x0FL),
_CGB_RGB(0x00L,0x04L,0x12L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD door_bkg_palette[]={
_CGB_RGB(0x0CL,0x12L,0x1FL),
_CGB_RGB(0x12L,0x10L,0x08L),
_CGB_RGB(0x18L,0x18L,0x18L),
_CGB_RGB(0x0AL,0x08L,0x03L)
};

UWORD kiosk_bkg_palette[]={
_CGB_RGB(0x0DL,0x0FL,0x0FL),
_CGB_RGB(0x1FL,0x00L,0x00L),
_CGB_RGB(0x1CL,0x1CL,0x1CL),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD kiosk2_bkg_palette[]={
_CGB_RGB(0x0DL,0x0FL,0x0FL),
_CGB_RGB(0x00L,0x00L,0x1FL),
_CGB_RGB(0x1CL,0x1CL,0x1CL),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD player_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x0CL,0x0CL,0x00L),
_CGB_RGB(0x18L,0x16L,0x08L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD thief_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x1FL),
_CGB_RGB(0x18L,0x16L,0x08L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD plane_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x0FL,0x0FL,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD ball_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x1FL,0x00L,0x00L),
_CGB_RGB(0x00L,0x1FL,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD car_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x08L,0x08L,0x08L),
_CGB_RGB(0x1FL,0x1FL,0x1FL),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD case_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x0FL,0x0AL,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD radio_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x08L,0x08L,0x08L),
_CGB_RGB(0x0FL,0x0AL,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UBYTE frame_ctrl,stair_frame_ctrl,elev_frame_ctrl;
UBYTE timer,subtimer;
UBYTE lives;
UWORD score,last_score,extra_life_at;
UBYTE sndmode,sndctrl;
WORD global_x,global_y;
WORD scn_x,scn_y;
WORD player_max_y;
WORD thief_max_y;
WORD global_max_y;
UBYTE current_room;
UBYTE player_floor;
UBYTE player_mode;
UBYTE player_death;
UBYTE thief_floor;
UBYTE thief_mode;
UBYTE thief_caught;
UBYTE thief_curr_waypoint;
Thief_AI *thief_waypoint_list;
UBYTE curr_level_num;
Level_Config *curr_level;
UWORD main_map[8][6];
elevator elevators[8];
side_wall wall_list[6];
stair stair_list[6];
WORD plane_spd,car_spd;
WORD ball_spd,ball_jheight;
enemy enemy_list[MAX_ENEMIES];
actor Player,Thief;
actor *actor_list[MAX_ACTORS];

UWORD junk; // vari vel reservada para debug

void draw_walk_sprite(WORD X, WORD Y, UBYTE spr, UBYTE frame, char mirror, UBYTE palette){
   UBYTE x,y;

   x = X + 8;   
   y = Y + 16;

   spr = spr << 2;
   frame = frame << 1;

   if (!mirror){
      set_sprite_prop(spr,palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x, y);
      spr++; frame++;

      set_sprite_prop(spr,palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x+8, y);
      spr++; frame+=15;

      set_sprite_prop(spr,palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x, y+8);
      spr++; frame++;

      set_sprite_prop(spr,palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x+8, y+8);
   }else{
      frame++;
      set_sprite_prop(spr,S_FLIPX|palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x, y);
      spr++; frame--;

      set_sprite_prop(spr,S_FLIPX|palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x+8, y);
      spr++; frame+=17;

      set_sprite_prop(spr,S_FLIPX|palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x, y+8);
      spr++; frame--;

      set_sprite_prop(spr,S_FLIPX|palette);
      set_sprite_tile(spr,frame);
      move_sprite(spr, x+8, y+8);
   }
}

void hide_walk_sprite(UBYTE spr){
   UBYTE i;
   spr = spr << 2;
   for(i = 0; i != 4; i++){
      move_sprite(spr++, 0, 0);
   }
}

void draw_actor(actor *Act){
   WORD X,Y;
   X = Act->X - global_x;
   Y = Act->Y - global_y;
   if((X > -17L)&&(X < 176L)){
      draw_walk_sprite(X,Y,Act->sprnum,Act->baseframe+Act->frame,(Act->XSpd > 0)^(Act->mirror==TRUE),Act->palette);
   }else{
      hide_walk_sprite(Act->sprnum);
   }
}

void draw_actors(){
   UBYTE i;
   for(i = 0; i != MAX_ACTORS; i++){
      if(actor_list[i]){
         draw_actor(actor_list[i]);
      }
   }
}

void init_actor_list(){
   UBYTE i,j;
   for(i = 0; i != MAX_ACTORS; i++){
      actor_list[i] = NULL;
      hide_walk_sprite(i);
   }
   actor_list[0] = &Player;
   actor_list[1] = &Thief;
   j = 2;
   for(i = 0; (i != MAX_ENEMIES)&&(j != MAX_ACTORS); i++){
      if(enemy_list[i].kind != _ENM_NONE){
         actor_list[j] = &enemy_list[i].enm_actor;
         j++;
      }
   }
}

void step_sound(){
//   NR41_REG = 0x36;
   NR41_REG = 0x3C;
   NR42_REG = 0xF1;
//   NR43_REG = 0x18;
   NR43_REG = 0x20;
   NR44_REG = 0xC0;
}

void jump_sound(){
   NR10_REG = 0x51;
   NR11_REG = 0x83;
   NR12_REG = 0xF0;
   NR13_REG = 0x21;
   NR14_REG = 0xC1;
}

void hit_sound(){
   NR10_REG = 0x00;
   NR11_REG = 0x84;
   NR12_REG = 0xF7;
   NR13_REG = 0x00;
   NR14_REG = 0x81;
}

void bonus_sound(UBYTE step){
   NR21_REG = 0x00;
   NR22_REG = 0xF7;
   NR23_REG = 0x00;
   NR24_REG = step|0x80;
   junk = step;
}

void dead_sound(){
   NR10_REG = 0xFF;
   NR11_REG = 0xC0;
   NR12_REG = 0xF7;
   NR13_REG = 0x00;
   NR14_REG = 0x86;
}

void time_bonus_sound(){
   NR10_REG = 0xF6;
   NR11_REG = 0xA6;
   NR12_REG = 0xF0;
   NR13_REG = 0x80;
   NR14_REG = 0xC7;
}

void xlife_sound(UBYTE step){
   NR21_REG = 0x00;
   NR22_REG = 0xF7;
   NR23_REG = 0x00;
   NR24_REG = step+20|0x80;
   junk = step;
}

void paused_sound(){
   NR10_REG = 0x15;
   NR11_REG = 0x80;
   NR12_REG = 0xF0;
   NR13_REG = 0x00;
   NR14_REG = 0xC6;
}

void sound_driver(){
   if(sndmode){
      NR50_REG=0xFF;
      NR51_REG=0xFF;
      NR52_REG=0xFF;
      switch(sndmode){
         case _SND_STEP:
            if(!sndctrl){
               step_sound();
            }else if(sndctrl > 70){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_JUMP:
            if(!sndctrl){
               jump_sound();
            }else if(sndctrl > 70){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_HIT:
            if(!sndctrl){
               hit_sound();
            }else if(sndctrl > 120){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_BONUS:
            if(sndctrl < 0x28){
               if(!(sndctrl&0x07)){
                  bonus_sound((sndctrl >> 3)+1);
               }
            }else if(sndctrl > 0x30){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_DEAD:
            if(!sndctrl){
               dead_sound();
            }else if(sndctrl > 120){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_TIMBN:
            if(!sndctrl){
               time_bonus_sound();
            }else if(sndctrl > 70){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_XLIFE:
            if(sndctrl < 0x28){
               if(!(sndctrl&0x07)){
                  xlife_sound((sndctrl >> 3)+1);
               }
            }else if(sndctrl > 0x30){
               sndmode = _SND_NONE;
            }
         break;
         case _SND_PAUSE:
            if(!sndctrl){
               paused_sound();
            }else if(sndctrl > 70){
               sndmode = _SND_NONE;
            }
         break;
      }
      sndctrl++;
   }else{
      NR50_REG=0x00;
      NR51_REG=0x00;
      NR52_REG=0x00;
   }
}

void install_sound_driver(){
   sndmode = _SND_NONE;
   sndctrl = 0;
   add_vbl(sound_driver);
}

void do_sound(UBYTE id){
   switch(sndmode){
      case _SND_BONUS:
         if(id == _SND_XLIFE){
            sndmode = id;
            sndctrl = 0;
         }
      break;
      case _SND_XLIFE:
      break;
      default:
         sndmode = id;
         sndctrl = 0;
      break;
   }
}

void draw_block(UBYTE X, UBYTE Y, UBYTE block, UBYTE sub_block){
   set_bkg_tiles(X, Y, 4, 5, block_map[block][sub_block]);
   if(_cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(X, Y, 4, 5, block_color[block][sub_block]);
      VBK_REG = 0;
   }
}

void set_bkg_tiles_vh(UBYTE X,UBYTE Y,UBYTE W,UBYTE H,unsigned char *tiles){
   UBYTE i;
   for(i = 0; i != W; i++){
      X &= 0x1F;
      set_bkg_tiles(X, Y, 1, H, tiles);
      X++;
      tiles += H;
   }
}

void draw_stair(UBYTE X, UBYTE Y, UBYTE kind){
   UBYTE tmp;
   X &= 0x1F;
   switch(kind){
      case _STAIR_NO:
      break;
      case _STAIR_LU:
         set_bkg_tiles_vh(X, Y, 6, 5, lstair_map[stair_frame_ctrl]);
         set_bkg_tiles_vh(X-1, Y-2, 4, 2, lstair_top);
      break;
      case _STAIR_LD:
         tmp = 2; // MERDA DE COMPILADOR!!!!!!!!
         tmp -= stair_frame_ctrl;
         set_bkg_tiles_vh(X, Y, 6, 5, lstair_map[tmp]);
         set_bkg_tiles_vh(X-1, Y-2, 4, 2, lstair_top);
      break;
      case _STAIR_RU:
         set_bkg_tiles_vh(X, Y, 6, 5, rstair_map);
         set_bkg_tiles_vh(X+3, Y-2, 4, 2, rstair_top);
      break;
      case _STAIR_RD:
         set_bkg_tiles_vh(X, Y, 6, 5, rstair_map);
         set_bkg_tiles_vh(X+3, Y-2, 4, 2, rstair_top);
      break;
   }
}

void draw_stairs(){
   UBYTE i;
   if(!(frame_ctrl&0x03)){
      stair_frame_ctrl++;
      if(stair_frame_ctrl == 3){
         stair_frame_ctrl = 0;
      }
      for(i = 0; i != 6; i++){
         draw_stair(stair_list[i].X,stair_list[i].Y,stair_list[i].kind);
      }
   }
}

void update_stairs(){
   UBYTE i;
   UWORD map_attr;
   for(i = 0; i != 6; i++){
      stair_list[i].kind = _STAIR_NO;
      map_attr = main_map[current_room][i] >> _MAP_BKG_BITS;
      switch(map_attr&_MAP_OBJ_MASK){
         case _MAP_STAIR_LU:
            stair_list[i].X = map_room_column[current_room]+4;
            stair_list[i].Y = i*5;
            stair_list[i].kind = _STAIR_LU;
         break;
         case _MAP_STAIR_LD:
            stair_list[i].X = map_room_column[current_room]+8;
            stair_list[i].Y = i*5;
            stair_list[i].kind = _STAIR_LD;
         break;
         case _MAP_STAIR_RU:
            stair_list[i].X = map_room_column[current_room]+8;
            stair_list[i].Y = i*5;
            stair_list[i].kind = _STAIR_RU;
         break;
         case _MAP_STAIR_RD:
            stair_list[i].X = map_room_column[current_room]+4;
            stair_list[i].Y = i*5;
            stair_list[i].kind = _STAIR_RD;
         break;
      }
   }
}

void draw_elevator(UBYTE X, UBYTE Y, UBYTE frame){
   set_bkg_tiles(X, Y, 2, 2, elevator_map[frame]);
}

void update_elevators(){
   UBYTE i,j;
   UWORD map_attr;
   //
   for(i=0; i != 8; i++){
      //
      elevators[i].curr_floor = 0;
      elevators[i].updown = 0;
      elevators[i].curr_frame = 0;
      elevators[i].delay = 0;
      for(j=0; j != 6; j++){
         elevators[i].floors[j] = FALSE;
      }
      //
      for(j=0; j != 6; j++){
         map_attr = main_map[i][j] >> _MAP_BKG_BITS;
         while(map_attr){
            switch(map_attr&_MAP_OBJ_MASK){
               case _MAP_ELEV:
                  elevators[i].updown++;
                  elevators[i].floors[j] = TRUE;
               break;
            }
            map_attr = map_attr >> _MAP_OBJ_BITS;
         }
      }
      //
      if(elevators[i].updown > 1){
         elevators[i].updown = 1;
      }else{
         elevators[i].updown = 0;
      }
   }
}

void draw_elevators(){
   UBYTE i;
   elevator *elev;
   //
   for(i = 0; i != 6; i++){
      elev = &elevators[current_room];
      if(elev->floors[i]){
         if(i == elev->curr_floor){
            draw_elevator((map_room_column[current_room]+9)&0x1F,(i*5)+2,
                           elev_frame_map[elev->curr_frame]&0x0F);
         }else{
            draw_elevator((map_room_column[current_room]+9)&0x1F,(i*5)+2,0);
         }
      }
   }
}

void move_elevators(){
   UBYTE i,j;
   BYTE next_floor;
   elevator *elev;
   //
   if(!elev_frame_ctrl){
      elev_frame_ctrl = 5;
   }else{
      elev_frame_ctrl--;
      return;
   }
   //
   for(i = 0; i != 8; i++){
      elev = &elevators[i];
      if((elev->updown != 0)&&(!elev->delay)){
         if(!elev->curr_frame){
            next_floor = elev->curr_floor;
            //
            j = 12;
            while(((!elev->floors[next_floor])||
                   (next_floor == elev->curr_floor)
                  )&&(j)){
               next_floor += elev->updown;
               if(next_floor == -1){
                  elev->updown = 1;
                  next_floor = 0;
               }else if(next_floor == 6){
                  elev->updown = -1;
                  next_floor = 5;
               }
               j--;
            }
            //
            elev->curr_floor = next_floor;
            elev->curr_frame = sizeof(elev_frame_map)-1;
            elev->delay = 32;
         }else{
            elev->curr_frame--;
            elev->delay = (elev_frame_map[elev->curr_frame] >> 4);
         }
      }else{
         elev->delay--;
      }
   }
}

void update_enemies(){
   UBYTE i,j;
   UWORD map_attr;
   UBYTE sprnum;
   //
   for(i = 0; i != MAX_ENEMIES; i++){
      enemy_list[i].kind = _ENM_NONE;
   }
   for(i = 0; i != 5; i++){
      wall_list[i].kind = _WAL_NONE;
   }
   //
   if(global_x > scn_x){ // Sa¡da pela direita
      current_room = map_columns[((UWORD)global_x+160) >> 5][0];
   }else{ // Sa¡da pela esquerda
      current_room = map_columns[((UWORD)global_x) >> 5][0];
   }
   sprnum = 2;
   j = 0;
   for(i = 0; i != 6; i++){
      map_attr = main_map[current_room][i] >> _MAP_BKG_BITS;
      while(map_attr){
         enemy_list[j].kind = _ENM_NONE;
         enemy_list[j].max_y = (i*5*8L)+(2*8);
         enemy_list[j].enm_actor.Y = i;
         enemy_list[j].enm_actor.Y *= (5*8);
         enemy_list[j].enm_actor.Y += 16;
         enemy_list[j].enm_actor.X = current_room;
         enemy_list[j].enm_actor.X *= 160;
         enemy_list[j].enm_actor.X -= 8;
         enemy_list[j].enm_actor.XSpd = 0;
         enemy_list[j].enm_actor.YSpd = 0;
         enemy_list[j].enm_actor.mirror = TRUE;
         switch(map_attr&_MAP_OBJ_MASK){
            case _MAP_ENM_CAR:
               enemy_list[j].kind = _ENM_CAR;
               enemy_list[j].enm_actor.sprnum = sprnum++;
               enemy_list[j].enm_actor.baseframe = 32;
               enemy_list[j].enm_actor.frame = 0;
               enemy_list[j].enm_actor.palette = 4;
               if(global_x > scn_x){
                  enemy_list[j].enm_actor.X += 160;
                  enemy_list[j].enm_actor.XSpd = -1*car_spd;
               }else{
                  enemy_list[j].enm_actor.XSpd = 1*car_spd;
               }
               j++;
            break;
            case _MAP_ENM_BALL:
               enemy_list[j].kind = _ENM_BALL;
               enemy_list[j].enm_actor.sprnum = sprnum++;
               enemy_list[j].enm_actor.baseframe = 33;
               enemy_list[j].enm_actor.frame = 0;
               enemy_list[j].enm_actor.palette = 3;
               enemy_list[j].max_y += 4;
               enemy_list[j].enm_actor.YSpd = -2;
               if(global_x > scn_x){
                  enemy_list[j].enm_actor.X += 160;
                  enemy_list[j].enm_actor.XSpd = -1*ball_spd;
               }else{
                  enemy_list[j].enm_actor.XSpd = 1*ball_spd;
               }
               j++;
            break;
            case _MAP_ENM_RAD:
               enemy_list[j].kind = _ENM_RADIO;
               enemy_list[j].enm_actor.sprnum = sprnum++;
               enemy_list[j].enm_actor.baseframe = 37;
               enemy_list[j].enm_actor.frame = 0;
               enemy_list[j].enm_actor.palette = 6;
               enemy_list[j].enm_actor.X += 80;
               j++;
            break;
            case _MAP_ENM_PLNE:
               enemy_list[j].kind = _ENM_PLANE;
               enemy_list[j].enm_actor.sprnum = sprnum++;
               enemy_list[j].enm_actor.baseframe = 38;
               enemy_list[j].enm_actor.frame = 0;
               enemy_list[j].enm_actor.palette = 2;
               enemy_list[j].enm_actor.Y -= 12;
               if(global_x > scn_x){
                  enemy_list[j].enm_actor.X += 160;
                  enemy_list[j].enm_actor.XSpd = -1*plane_spd;
               }else{
                  enemy_list[j].enm_actor.XSpd = 1*plane_spd;
               }
               j++;
            break;
            case _MAP_ITM_CASE:
               enemy_list[j].kind = _ENM_CASE;
               enemy_list[j].enm_actor.sprnum = sprnum++;
               enemy_list[j].enm_actor.baseframe = 48;
               enemy_list[j].enm_actor.frame = 0;
               enemy_list[j].enm_actor.palette = 5;
               enemy_list[j].enm_actor.X += 80;
               j++;
            break;
            case _MAP_ITM_MNY:
               enemy_list[j].kind = _ENM_MONEY;
               enemy_list[j].enm_actor.sprnum = sprnum++;
               enemy_list[j].enm_actor.baseframe = 49;
               enemy_list[j].enm_actor.frame = 0;
               enemy_list[j].enm_actor.palette = 5;
               enemy_list[j].enm_actor.X += 80;
               j++;
            break;
            default:
               enemy_list[j].kind = _ENM_NONE;
			   enemy_list[j].enm_actor.baseframe = 8;
               enemy_list[j].enm_actor.X = -800;
            break;
            case _MAP_WALL_L:
               wall_list[i].kind = _WAL_LEFT;
            break;
            case _MAP_WALL_R:
               wall_list[i].kind = _WAL_RIGHT;
            break;
         }
         map_attr = map_attr >> _MAP_OBJ_BITS;
      }
   }
   init_actor_list();
}

unsigned char check_col(WORD X1,WORD Y1,WORD X2,WORD Y2,WORD W,WORD H){
//   return ((labs(X1-X2) < W)&&(labs(Y1-Y2) < H)); // MERDA DE COMPILADOR!!!
   if(X1 > X2){
      X1 = (X1 - X2);
   }else{
      X1 = (X2 - X1);
   }
   if(Y1 > Y2){
      Y1 = (Y1 - Y2);
   }else{
      Y1 = (Y2 - Y1);
   }
   if((X1 < W)&&(Y1 < H)){
      return 1;
   }else{
      return 0;
   }
}

void delete_map_obj(UBYTE room, UBYTE floor, UBYTE objtype){
   UWORD mask,obj,*data;
   //
   mask = _MAP_OBJ_MASK;
   mask = mask << _MAP_BKG_BITS;
   //
   obj = objtype & _MAP_OBJ_MASK;
   obj = obj << _MAP_BKG_BITS;
   //
   data = &main_map[room][floor];
   //
   while(mask != 0x0000L){
      if( ((*data) & mask) == obj ){
         (*data) &= (~mask);
      }
      mask = mask << _MAP_OBJ_BITS;
      obj = obj << _MAP_OBJ_BITS;
   }
}

void move_enemies(){
   UBYTE i,j;
   enemy *enm;
   actor *enm_act;
   for(i = 0; i != MAX_ENEMIES; i++){
      enm = &enemy_list[i];
      enm_act = &enm->enm_actor;
      //
      enm_act->X += enm_act->XSpd;
      enm_act->Y += enm_act->YSpd;
      //
      if(enm_act->XSpd < 0){
         if((enm_act->X-global_x) < -16){
            enm_act->X = global_x + 160;
         }
      }else if(enm_act->XSpd > 0){
         if((enm_act->X-global_x) > 160){
            enm_act->X = global_x - 16;
         }
      }
      //
      switch(enm->kind){
         case _ENM_BALL:
            if(!(frame_ctrl&0x03)){
               enm_act->YSpd++;
               enm_act->frame &= 0x01;
               if(labs(enm_act->YSpd) == 2){
                  enm_act->frame |= 0x02;
               }
            }
            if(enm_act->Y > enm->max_y){
               enm_act->Y = enm->max_y;
               enm_act->YSpd = -ball_jheight;
               enm_act->frame |= 0x02;
            }
            if(!(frame_ctrl&0x03)){
               enm_act->frame ^= 0x01;
            }
         break;
         case _ENM_PLANE:
            if(!(frame_ctrl&0x03)){
               enm_act->frame ^= 0x01;
            }
         break;
      }
      //
      switch(enemy_list[i].kind){
         case _ENM_CAR:
         case _ENM_BALL:
         case _ENM_RADIO:
            if(player_mode != _PLY_MODE_NORM){
               //
            }else if(Player.frame == 6){ // Jogador agachado
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y+4,16,12)){
                  enm->kind = _ENM_NONE;
                  do_sound(_SND_HIT);
                  timer -= 10;
                  init_actor_list();
               }
            }else if(Player.YSpd == 0){ // Jogador parado/jogador correndo
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y,16,16)){
                  enm->kind = _ENM_NONE;
                  do_sound(_SND_HIT);
                  timer -= 10;
                  subtimer = 0;
                  init_actor_list();
               }
            }else{ // Jogador pulando
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y-4,16,12)){
                  enm->kind = _ENM_NONE;
                  do_sound(_SND_HIT);
                  timer -= 10;
                  subtimer = 0;
                  init_actor_list();
               }
            }
         break;
         //
         case _ENM_PLANE:
            if(player_mode != _PLY_MODE_NORM){
               //
            }else if(Player.frame == 6){ // Jogador agachado
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y+4,16,12)){
                  do_sound(_SND_DEAD);
                  player_death = 140;
               }
            }else if(Player.YSpd == 0){ // Jogador parado/jogador correndo
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y,16,16)){
                  do_sound(_SND_DEAD);
                  player_death = 140;
               }
            }else{ // Jogador pulando
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y-4,16,12)){
                  do_sound(_SND_DEAD);
                  player_death = 140;
               }
            }
         break;
         //
         case _ENM_CASE:
         case _ENM_MONEY:
            if(player_mode != _PLY_MODE_NORM){
               //
            }else if(Player.YSpd == 0){ // Jogador parado/jogador correndo
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y,16,16)){
                  enm->kind = _ENM_NONE;
                  delete_map_obj(current_room,player_floor,_MAP_ITM_CASE);
                  delete_map_obj(current_room,player_floor,_MAP_ITM_MNY);
                  do_sound(_SND_BONUS);
                  score += 200;
                  init_actor_list();
               }
            }else{ // Jogador pulando
               if(check_col(enm_act->X,enm_act->Y,Player.X,Player.Y-4,16,12)){
                  enm->kind = _ENM_NONE;
                  delete_map_obj(current_room,player_floor,_MAP_ITM_CASE);
                  delete_map_obj(current_room,player_floor,_MAP_ITM_MNY);
                  do_sound(_SND_BONUS);
                  score += 200;
                  init_actor_list();
               }
            }
         break;
      }
   }
}

void scroll_scn(){ //Obs: por enquanto, s¢ suporta scrolling horizontal
   UBYTE i,j;
   UBYTE stx,edx;
   UWORD map_attr;
   //
   if((scn_x != global_x)||(scn_y != global_y)){
      if(scn_x < global_x){ // Movendo para a direita
         stx = ((UWORD)scn_x+160L) >> 5;
         edx = ((UWORD)global_x+191L) >> 5;
      }else{ // Movendo para a esquerda
         stx = ((UWORD)global_x) >> 5;
         edx = ((UWORD)scn_x) >> 5;
      }
      //
      for(i = 0; i != 5; i++){
         for(j = stx; j != edx; j++){
            map_attr = main_map[map_columns[j][0]][i];
            draw_block((j << 2)&0x1F,i*5,map_attr&_MAP_BKG_MASK,map_columns[j][1]);
            map_attr = map_attr >> _MAP_BKG_BITS;
            while(map_attr){
               switch(map_attr&_MAP_OBJ_MASK){
                  case _MAP_STAIR_LU:
                     if((map_columns[j][1] == 1)||(map_columns[j][1] == 2)){
                        draw_stair(map_room_column[map_columns[j][0]]+4,i*5,_STAIR_LU);
                     }
                  break;
                  case _MAP_STAIR_LD:
                     if((map_columns[j][1] == 2)||(map_columns[j][1] == 3)){
                        draw_stair(map_room_column[map_columns[j][0]]+8,i*5,_STAIR_LD);
                     }
                  break;
                  case _MAP_STAIR_RU:
                     if((map_columns[j][1] == 2)||(map_columns[j][1] == 3)){
                        draw_stair(map_room_column[map_columns[j][0]]+8,i*5,_STAIR_RU);
                     }
                  break;
                  case _MAP_STAIR_RD:
                     if((map_columns[j][1] == 1)||(map_columns[j][1] == 2)){
                        draw_stair(map_room_column[map_columns[j][0]]+4,i*5,_STAIR_RD);
                     }
                  break;
                  case _MAP_WALL_L:
                     if(map_columns[j][1] == 0){
                        set_bkg_tiles(map_room_column[map_columns[j][0]], i*5, 1, 5, wall_map);
                     }
                  break;
                  case _MAP_WALL_R:
                     if(map_columns[j][1] == 4){
                        set_bkg_tiles((map_room_column[map_columns[j][0]]+19)&0x1F, i*5, 1, 5, wall_map);
                     }
                  break;
               }
               map_attr = map_attr >> _MAP_OBJ_BITS;
            }
         }
      }
      //
      SCX_REG = (global_x & 0xFF);
      SCY_REG = ((global_y+2) & 0xFF);
      scn_x = global_x;
      scn_y = global_y;
   }
}

void calc_scroll(){
   UBYTE i,j;
   if((Player.X-global_x) < -8L){
      for(i = 0; i != (160/4); i++){
         global_x -= 4;
         wait_vbl_done();
         if(i == (36)){
            update_enemies();
         }
         scroll_scn();
         draw_actors();
      }
      current_room = map_columns[((UWORD)global_x) >> 5][0];
      update_stairs();
   }else if((Player.X-global_x) > 152L){
      j = 0;
      for(i = 0; i != (160/4); i++){
         global_x += 4;
         wait_vbl_done();
         if(i == (4)){
            update_enemies();
         }
         scroll_scn();
         draw_actors();
      }
      current_room = map_columns[((UWORD)global_x) >> 5][0];
      update_stairs();
   }
   global_y = Player.Y-100+3;
   if(global_y < 0){
      global_y = 0;
   }else if(global_y > global_max_y){
      global_y = global_max_y;
   }
   SCY_REG = ((global_y+2) & 0xFF);
}

void update_timer(){
   unsigned char buf[2];
   if((BYTE)timer < 0){ // Checagem de sanidade
      timer = 0;
   }
   if(!subtimer){ // Se passou um segundo...
      timer--;
      buf[0] = (timer / 10)|0x80; //Dezenas
      buf[1] = (timer % 10)|0x80; //Unidades
      set_win_tiles(8,0,2,1,buf);
      subtimer = 70;
   }
   subtimer--;
}

void update_lives(){
   unsigned char buf[1];
   buf[0] = lives|0x80;
   set_win_tiles(2,0,1,1,buf);
}

void update_score(){
   unsigned char buf[5];
   UWORD tmp;
   UBYTE i;
   //
   if(score != last_score){
      tmp = score;
      for(i = 4;i != 255; i--){
         buf[i] = (tmp % 10)|0x80;
         tmp /= 10;
      }
      for(i = 0; (i != 4)&&(buf[i] == 0x80); i++){ // Limpa os zeros … esquerda
         buf[i] = 0x8A;
      }
      set_win_tiles(5,1,5,1,buf);
      last_score = score;
      if(score > extra_life_at){
         lives++;
         do_sound(_SND_XLIFE);
         update_lives();
         extra_life_at += (extra_life_at >> 1) + 3000;
      }
   }
}

void update_debug(){
   unsigned char buf[2];
   //
   buf[0] = (elevators[current_room].curr_floor / 10)|0x80; //Dezenas
   buf[1] = (elevators[current_room].curr_floor % 10)|0x80; //Unidades
   set_win_tiles(1,1,2,1,buf);
}

void read_level(UBYTE level){
   UWORD *src,*dst;
   UBYTE i;
   //
   curr_level = &levels[(level % MAX_LEVELS)];
   //
   src = curr_level->map;
   dst = main_map[0];
   memcpy(dst,src,(8*6*2L));
   //
   thief_waypoint_list = curr_level->AI;
   //
   plane_spd = (level / 10)+1;
   car_spd = (level / 5)+1;
   ball_spd = (level / 8)+1;
   if(level < 9){
      ball_jheight = 2;
   }else{
      ball_jheight = 4;
   }
}

void restart_level(){
  disable_interrupts();
  DISPLAY_OFF;

  read_level(curr_level_num);

  player_floor = curr_level->ply_start_floor;

  player_max_y = (player_floor*5*8L)+(2*8);
  player_mode = _PLY_MODE_NORM;

  Player.X = (160L*curr_level->ply_start_room)+72;
  Player.Y = player_max_y;
  Player.sprnum = 0;
  Player.baseframe = 0;
  Player.frame = 0;
  Player.XSpd = 0;
  Player.YSpd = 0;
  Player.mirror = FALSE;
  Player.palette = 0;

  thief_floor = curr_level->thief_start_floor;

  thief_max_y = (thief_floor*5*8L)+(2*8);
  thief_mode = _PLY_MODE_NORM;

  thief_curr_waypoint = 0;

  Thief.X = (160L*curr_level->thief_start_room)+80;
  Thief.Y = (thief_floor*5*8L)+(2*8);
  Thief.sprnum = 1;
  Thief.baseframe = 16;
  Thief.frame = 0;
  Thief.XSpd = 0;
  Thief.YSpd = 0;
  Thief.mirror = FALSE;
  Thief.palette = 1;

  init_actor_list();

  global_x = (160L*curr_level->ply_start_room);
  global_y = 0;

  global_max_y = (curr_level->floor_count*5*8L)-120L;

  update_enemies();

  frame_ctrl = 0;
  stair_frame_ctrl = 0;
  elev_frame_ctrl = 0;

  scn_x = global_x+0xFF;
  scn_y = global_y+0xFF;
  scroll_scn();

  current_room = map_columns[((UWORD)global_x) >> 5][0];
  timer = 100;
  subtimer = 0;
  update_stairs();
  update_enemies();
  update_timer();
  update_lives();
  update_score();

  DISPLAY_ON;
  enable_interrupts();
}

void play_game(){
  UBYTE i, j;

  DISPLAY_OFF;

  BGP_REG = 0xD8U;
  OBP0_REG = 0xD8U;
  OBP1_REG = 0xE4U;

  set_bkg_data(0x00, 0xFF, background_tiles);

  WX_REG = 7;
  WY_REG = MAXWNDPOSY-(3*8)+1;

  set_win_tiles(0, 0, 20, 5, window_map);
  if(_cpu == 0x11){
     VBK_REG = 1;
     set_win_tiles(0, 0, 20, 5, window_color_map);
     VBK_REG = 0;
  }

  /* Initialize the sprite */
  set_sprite_data(0x00, 0x80, main_sprites);

  if(_cpu == 0x11){	// Configura para CGB
     set_sprite_palette(7,1,player_palette);
     set_sprite_palette(6,1,thief_palette);
     set_sprite_palette(5,1,plane_palette);
     set_sprite_palette(4,1,ball_palette);
     set_sprite_palette(3,1,car_palette);
     set_sprite_palette(2,1,case_palette);
     set_sprite_palette(1,1,radio_palette);
     set_bkg_palette(7,1,default_bkg_palette);
     set_bkg_palette(6,1,sky_bkg_palette);
     set_bkg_palette(5,1,door_bkg_palette);
     set_bkg_palette(4,1,kiosk_bkg_palette);
     set_bkg_palette(3,1,kiosk2_bkg_palette);
  }

  NR50_REG=0xFF;
  NR51_REG=0xFF;
  NR52_REG=0xFF;

//  DISPLAY_ON;
  enable_interrupts();

  lives = 3;
  score = 0;
  last_score = 1;
  extra_life_at = 3000;
  curr_level_num = 0;

  thief_caught = FALSE;

  read_level(curr_level_num);
  update_elevators();

  while(lives){
     player_death = 0;

     restart_level();

     while((!player_death)&&(!thief_caught)){
        wait_vbl_done();
        frame_ctrl++;
        //
        move_player();
        move_thief();
        move_enemies();
        move_elevators();
        calc_scroll();
        draw_elevators();
        draw_stairs();
        draw_actors();
        update_timer();
        update_score();
//        update_debug();
        if(timer == 0){
           do_sound(_SND_DEAD);
           player_death = 140;
        }
        if(player_floor == thief_floor){
           if(player_mode != _PLY_MODE_NORM){
              //
           }else if(check_col(Player.X,Player.Y,
                        Thief.X,Thief.Y,16,16)){
              thief_caught = TRUE;
           }
        }
        //
        i = joypad();
        if(i & J_START){
           WX_REG = 7;
           WY_REG = MAXWNDPOSY-(4*8)-4;
           while(i & J_START) i = joypad();
           do_sound(_SND_PAUSE);
           while(!(i & J_START)) i = joypad();
           WX_REG = 7;
           WY_REG = MAXWNDPOSY-(3*8)+1;
           while(i & J_START) i = joypad();
           do_sound(_SND_PAUSE);
        }
        if(i & J_SELECT){
//           for(i = 0; i != MAX_ACTORS; i++){
   //           junk = actor_list[i]->Y;
//           }
           if(i & J_B){
              thief_caught = TRUE; // *** DEBUG ***
           }
           if(i & J_A){
              lives++;
              do_sound(_SND_XLIFE);
           }
        }
     }
     //
     if(player_death){
        while(player_death){
           wait_vbl_done();
           player_death--;
        }
        lives--;
        update_lives();
     }
     //
     if(thief_caught){
        while(timer){
           wait_vbl_done();
           wait_vbl_done();
           subtimer=0;
           update_timer();
           do_sound(_SND_TIMBN);
           score += 5;
           update_score();
        }
        thief_caught = FALSE;
        curr_level_num++;
        read_level(curr_level_num);
        update_elevators();
     }
  }
}

void main()
{
  UBYTE i, j;

  SWITCH_ROM_MBC1(3);
  draw_border();

  if(_cpu == 0x11){
     SpeedUp();
  }

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
  BGP_REG = 0xD8U;
  OBP0_REG = 0xD8U;
  OBP1_REG = 0xE4U;

  SCX_REG = 0;
  SCY_REG = 0;

  /* Instala driver de som */
  install_sound_driver();

  while(1){
     SWITCH_ROM_MBC1(2);
     show_title();

     SWITCH_ROM_MBC1(1);
     play_game();
  }
}
