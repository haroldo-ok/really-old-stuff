#include <gb.h>
#include "cosin.h"
#include "melee.h"
#include "urq_data.h"
#include "stbarmp.h"
#include "stbartl.h"
#include "scor.h"

/*
      |
   3  |  0
      |
-------------
      |
   2  |  1
      |
*/

UBYTE ship_frames[4][9]={
{ 0,  1,  2,
 15, 16, 17,
 30, 31, 32},
//
{30, 31, 32,
 15, 16, 17,
  0,  1,  2},
//
{32, 31, 30,
 17, 16, 15,
  2,  1,  0},
//
{ 2,  1,  0,
 17, 16, 15,
 32, 31, 30}
};
UBYTE ship_props[4]={0x00,0x40,0x60,0x20};
UBYTE ship_angles[16][2]={
{0, 0},
{0, 3},
{0, 6},
{0, 9},
{0,12},
{1, 9},
{1, 6},
{1, 3},
{1, 0},
{2, 3},
{2, 6},
{2, 9},
{2,12},
{3, 9},
{3, 6},
{3, 3}
};
UBYTE small_ship_angles[16]={0,1,2,3,4,3,2,1,0,1,2,3,4,3,2,1};

unsigned char bgstars[]={
0x18,0x19,0x1A,0x18,0x18,0x18,0x18,0x1A,
0x1A,0x1C,0x18,0x1B,0x18,0x1C,0x18,0x18,
0x18,0x1C,0x1B,0x18,0x1A,0x18,0x19,0x18,
0x1B,0x18,0x19,0x1B,0x18,0x1C,0x1B,0x1C
};

unsigned char bgstars_c[]={
0x04,0x05,0x06,0x04,
0x06,0x04,0x05,0x06,
0x05,0x05,0x04,0x04,
0x05,0x06,0x05,0x06
};

unsigned char stbar_colors[]={
0x80,0x80,0x80,0x80,0x81,0x81,0x80,0x81,0x81,0x80,
0x80,0x80,0x80,0x81,0x81,0x80,0x81,0x81,0x80,0x80,
//
0x80,0x80,0x80,0x80,0x82,0x02,0x80,0x82,0x82,0x80,
0x80,0x80,0x80,0x82,0x82,0x80,0x82,0x82,0x80,0x80
};

/*
UWORD stars_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x06L,0x06L,0x0BL),
_CGB_RGB(0x09L,0x09L,0x10L),
_CGB_RGB(0x00L,0x00L,0x07L),
//
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x06L,0x0BL,0x06L),
_CGB_RGB(0x09L,0x10L,0x09L),
_CGB_RGB(0x00L,0x07L,0x00L),
//
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x0BL,0x0BL,0x06L),
_CGB_RGB(0x10L,0x10L,0x09L),
_CGB_RGB(0x07L,0x07L,0x00L)
};
*/
UWORD stars_palette[]={
_CGB_RGB(0x00L,0x00L,0x07L),
_CGB_RGB(0x09L,0x09L,0x10L),
_CGB_RGB(0x06L,0x06L,0x0BL),
_CGB_RGB(0x00L,0x00L,0x00L),
//
_CGB_RGB(0x00L,0x07L,0x00L),
_CGB_RGB(0x09L,0x10L,0x09L),
_CGB_RGB(0x06L,0x0BL,0x06L),
_CGB_RGB(0x00L,0x00L,0x00L),
//
_CGB_RGB(0x0BL,0x0BL,0x06L),
_CGB_RGB(0x07L,0x07L,0x00L),
_CGB_RGB(0x10L,0x10L,0x09L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD stbar_palette[]={
_CGB_RGB(0x1FL,0x1FL,0x1FL),
_CGB_RGB(0x0AL,0x0AL,0x03L),
_CGB_RGB(0x14L,0x14L,0x05L),
_CGB_RGB(0x06L,0x06L,0x03L),
//
_CGB_RGB(0x1FL,0x1FL,0x1FL),
_CGB_RGB(0x0AL,0x0AL,0x0AL),
_CGB_RGB(0x14L,0x14L,0x14L),
_CGB_RGB(0x06L,0x06L,0x06L),
//
_CGB_RGB(0x1FL,0x1FL,0x1FL),
_CGB_RGB(0x0AL,0x0AL,0x0AL),
_CGB_RGB(0x14L,0x14L,0x05L),
_CGB_RGB(0x06L,0x06L,0x03L)
};

fixed bkg_x,bkg_y;
fixed cntr_x,cntr_y;
ship_rec ship[2];
UBYTE aux_buffer[2][0x7F];
char small_ships;
UBYTE joy_status;
UBYTE shot_life_delay;

void draw_ship(UBYTE X, UBYTE Y, ship_rec *ship){
   UBYTE angle;
   UBYTE *frames,props;
   UBYTE ang,subang;
   UBYTE spr,data;
   UBYTE i;

   angle = (ship->angle.b.h & 0x0F);
   spr = ship->first_sprite;
   data = ship->sprite_data;

   ang = ship_angles[angle][0];
   subang = ship_angles[angle][1];

   frames = ship_frames[ang];
   props  = ship_props[ang];

   for(i=0;i != 9;i++){
      set_sprite_prop(spr+i, props);
      set_sprite_tile(spr+i, data+(frames[i])+subang);
   }

   if ((Y-8) < MAXWNDPOSY){
      move_sprite(spr++, X-8, Y-8);
      move_sprite(spr++, X  , Y-8);
      move_sprite(spr++, X+8, Y-8);
   }else{
      move_sprite(spr++, 0, 0);
      move_sprite(spr++, 0, 0);
      move_sprite(spr++, 0, 0);
   }
   //
   if (Y < MAXWNDPOSY){
      move_sprite(spr++, X-8, Y  );
      move_sprite(spr++, X  , Y  );
      move_sprite(spr++, X+8, Y  );
   }else{
      move_sprite(spr++, 0, 0);
      move_sprite(spr++, 0, 0);
      move_sprite(spr++, 0, 0);
   }
   //
   if ((Y+8) < MAXWNDPOSY){
      move_sprite(spr++, X-8, Y+8);
      move_sprite(spr++, X  , Y+8);
      move_sprite(spr++, X+8, Y+8);
   }else{
      move_sprite(spr++, 0, 0);
      move_sprite(spr++, 0, 0);
      move_sprite(spr++, 0, 0);
   }
}

void draw_small_ship(UBYTE X, UBYTE Y, ship_rec *ship){
   UBYTE angle;
   UBYTE props;
   UBYTE ang,subang;
   UBYTE spr,data;
   UBYTE i;

   angle = (ship->angle.b.h & 0x0F);
   spr = ship->first_sprite;
   data = ship->sprite_data;

   ang = ship_angles[angle][0];
   subang = small_ship_angles[angle];

   props  = ship_props[ang];

   for(i=0;i != 4;i++){
      move_sprite(spr+i, 0, 0);
   }
   for(i=5;i != 9;i++){
      move_sprite(spr+i, 0, 0);
   }
   set_sprite_prop(spr+4, props);
   set_sprite_tile(spr+4, data+45+subang);
   if (Y < MAXWNDPOSY){
      move_sprite(spr+4, X, Y);
   }else{
      move_sprite(spr+4, 0, 0);
   }
}

void draw_missile(UBYTE X, UBYTE Y, UBYTE angle){
   UBYTE props;
   UBYTE ang,subang;
   UBYTE i;

   ang = ship_angles[angle][0];
   subang = small_ship_angles[angle];

   props  = ship_props[ang];

   set_sprite_prop(0, props);
   set_sprite_tile(0, subang);
   if (Y < MAXWNDPOSY){
      move_sprite(0, X, Y);
   }else{
      move_sprite(0, 0, 0);
   }
}

void draw_shot(UBYTE X, UBYTE Y, shot_rec *shot){
   UBYTE angle;
   UBYTE props;
   UBYTE ang,subang;
   UBYTE spr,data;

   angle = (shot->angle.b.h & 0x0F);
   spr = shot->first_sprite;
   data = shot->sprite_data;

   ang = ship_angles[angle][0];
   subang = small_ship_angles[angle];

   props  = ship_props[ang];

   set_sprite_prop(spr, props);
   set_sprite_tile(spr, data+subang);
   if (Y < MAXWNDPOSY){
      move_sprite(spr, X, Y);
   }else{
      move_sprite(spr, 0, 0);
   }
}

void accelerate_ship(ship_rec *ship, UBYTE dir){
   //
   ship->ship_accel.w += ship->max_speed.w;
   //
   ship->speed_x.w = (WORD)ship->speed_x.w >> 4;
   ship->speed_y.w = (WORD)ship->speed_y.w >> 4;
   //
   ship->speed_x.w += ship->speed_x.w + ship->speed_x.w;
   ship->speed_x.w += (ship->speed_x.w << 2);
   ship->speed_x.w -= (WORD)((_COS(ship->angle.b.h+4+dir) >> 4)*ship->ship_accel.b.h) >> 5;
   //
   ship->speed_y.w += ship->speed_y.w + ship->speed_y.w;
   ship->speed_y.w += (ship->speed_y.w << 2);
   ship->speed_y.w += (WORD)((_SIN(ship->angle.b.h+4+dir) >> 4)*ship->ship_accel.b.h) >> 5;
   //
   ship->ship_accel.b.h = 0;
}

void accelerate_shot(shot_rec *shot, UBYTE dir){
   //
   shot->shot_accel.w += shot->max_speed.w;
   //
   shot->speed_x.w = (WORD)shot->speed_x.w >> 4;
   shot->speed_y.w = (WORD)shot->speed_y.w >> 4;
   //
   shot->speed_x.w += shot->speed_x.w + shot->speed_x.w;
   shot->speed_x.w += (shot->speed_x.w << 2);
   shot->speed_x.w -= (WORD)((_COS(shot->angle.b.h+4+dir) >> 4)*shot->shot_accel.b.h) >> 4;
   //
   shot->speed_y.w += shot->speed_y.w + shot->speed_y.w;
   shot->speed_y.w += (shot->speed_y.w << 2);
   shot->speed_y.w += (WORD)((_SIN(shot->angle.b.h+4+dir) >> 4)*shot->shot_accel.b.h) >> 4;
   //
   shot->shot_accel.b.h = 0;
}

void control_ship_joy(UBYTE joy, ship_rec *ship){
  if(joy & J_LEFT){
     ship->angle.w-=64;
  }
  if(joy & J_RIGHT){
     ship->angle.w+=64;
  }
  //
  if(joy & J_UP){
     accelerate_ship(ship,0);
  }
  if(joy & J_DOWN){
     accelerate_ship(ship,8);
  }
  //
  ship->ship_x.w += ship->speed_x.w;
  ship->ship_y.w += ship->speed_y.w;
}

void recenter_shot(shot_rec *shot){
   shot->shot_x.w -= cntr_x.w;
   shot->shot_y.w -= cntr_y.w;
}

void calc_scroll(){
   WORD A,B;
   UBYTE i;
   //
   A = (WORD)ship[0].ship_x.w >> 1;
   B = (WORD)ship[1].ship_x.w >> 1;
   cntr_x.w = A+B;
   bkg_x.w += cntr_x.w;
   SCX_REG = bkg_x.b.h;
   //
   A = (WORD)ship[0].ship_y.w >> 1;
   B = (WORD)ship[1].ship_y.w >> 1;
   cntr_y.w = A+B;
   bkg_y.w += cntr_y.w;
   SCY_REG = bkg_y.b.h;
   //
   for(i = 0; i < 2; i++){
      ship[i].ship_x.w -= cntr_x.w;
      ship[i].ship_y.w -= cntr_y.w;
   }
   //
   small_ships = (abs((BYTE)ship[0].ship_x.b.h) > 0x3F) || (abs((BYTE)ship[0].ship_y.b.h) > 0x3F);
}

void calc_pos_scr(fixed *rel_x, fixed *rel_y, UBYTE *scr_x, UBYTE *scr_y, char *Ok){
   WORD X,Y;
   if (!small_ships){
      X = (BYTE)rel_x->b.h;
   }else{
      X = (BYTE)rel_x->b.h >> 1;
   }
   X += 80;
   //
   if(!small_ships){
      Y = (BYTE)rel_y->b.h;
   }else{
      Y = (BYTE)rel_y->b.h >> 1;
   }
   Y += 72;
   //
   if((X < 0) || (X > 160) || (Y < 0) || (Y > MAXWNDPOSY)){
	  *Ok = FALSE;
   }else{
      *scr_x = X;
      *scr_y = Y;
	  *Ok = TRUE;
   }
}

void draw_ships(){
   WORD X,Y;
   UBYTE i;
   for(i = 0; i != 2; i++){
      if (!small_ships){
         X = (BYTE)ship[i].ship_x.b.h;
      }else{
         X = (BYTE)ship[i].ship_x.b.h >> 1;
      }
      X += 80;
      //
      if(!small_ships){
         Y = (BYTE)ship[i].ship_y.b.h;
      }else{
         Y = (BYTE)ship[i].ship_y.b.h >> 1;
      }
      Y += 72;
      //
      if(X < 0){
         X+=160;
      }else if(X > 160){
         X-=160;
      }
      //
      if(Y < 0){
         Y+=MAXWNDPOSY;
      }else if(Y > MAXWNDPOSY){
         X-=MAXWNDPOSY;
      }
      //
      if(!small_ships){
         draw_ship(X, Y, &ship[i]);
      }else{
         draw_small_ship(X, Y, &ship[i]);
      }
   }
}

void status_bar_number(UBYTE X, UBYTE Y, UBYTE crew_batt){
   unsigned char digits[2];
   digits[1] = scor_table[crew_batt][0] + STATUS_BAR_1ST_DIGIT;
   digits[0] = scor_table[crew_batt][1] + STATUS_BAR_1ST_DIGIT;
   set_win_tiles(X, Y, 2, 1, digits);
}

void update_status_bar(){
   UBYTE i;
   status_bar_number(4, 0, ship[0].ship_crew);
   status_bar_number(7, 0, ship[0].ship_battery.b.h);
   status_bar_number(13, 0, ship[1].ship_crew);
   status_bar_number(16, 0, ship[1].ship_battery.b.h);
   //
   for(i = 0; i < 2; i++){
      if(ship[i].ship_battery.b.h < ship[i].max_battery){
         ship[i].ship_battery.w += ship[i].recharge_rate.w;
      } //else{
//         ship[i].ship_battery.b.h = 0; //***DEBUG***
//      }
   }
}

void set_melee_colors(){
   UBYTE i, j;
   //
   BGP_REG =  0xD8U;
   OBP0_REG = 0x90U;
   OBP1_REG = 0xD8U;
   //
   if(_cpu == 0x11){ //S¢ executa as rotinas abaixo no CGB
      set_sprite_palette(7,1,urquan_palette);
      //
      set_bkg_palette(3,3,stars_palette);
      //
      set_bkg_palette(7,3,stbar_palette);
      //
      VBK_REG = 1; 
      for(i = 0;i !=8;i++){
         for(j = 0;j !=8;j++){
            set_bkg_tiles(i << 2, j << 2, 4, 4, bgstars_c);
         }
      }
      set_win_tiles(0, 0, 20, 2, stbar_colors);
      VBK_REG = 0; 
   }
}

void melee_init(){
  UBYTE i, j;

  for(i = 0;i !=4;i++){
     for(j = 0;j !=8;j++){
        set_bkg_tiles(i << 3, j << 2, 8, 4, bgstars);
     }
  }
  SCX_REG = 0;
  SCY_REG = 0;

  set_win_data(0x00, 0x20, status_bar_tiles);
  set_win_tiles(0, 0, 32, 2, status_bar_map);
  WX_REG = 7;
  WY_REG = (MAXWNDPOSY - 15);

  set_sprite_data(SHIP1_SPRITE_DATA, URQUAN_SPR_TILE_COUNT, urquan_ship);
  set_sprite_data(SHIP2_SPRITE_DATA, URQUAN_SPR_TILE_COUNT, urquan_ship);

  ship[0].angle.w = 0;
  ship[0].ship_x.w = 0x2000;
  ship[0].ship_y.w = 0x2000;
  ship[0].speed_x.w = 0x0000;
  ship[0].speed_y.w = 0x0000;
  ship[0].ship_accel.w = 0x0000;
  ship[0].max_speed.w = 0x70FF;
  ship[0].sprite_data = SHIP1_SPRITE_DATA;
  ship[0].first_sprite = SHIP1_1ST_SPRITE;
  ship[0].ID = 1;
  ship[0].ship_crew = 0x32;
  ship[0].ship_battery.w = 0x0F00;
  ship[0].recharge_rate.w = 0x0010;
  ship[0].max_battery = 0x0F;
  ship[0].aux_data = &aux_buffer[0][0];
  urquan_init(&ship[0]);

  ship[1].angle.w = 0x0700;
  ship[1].ship_x.w = 0x5000;
  ship[1].ship_y.w = 0x5000;
  ship[1].speed_x.w = 0x0000;
  ship[1].speed_y.w = 0x0000;
  ship[1].ship_accel.w = 0x0000;
  ship[1].max_speed.w = 0x70FF;
  ship[1].sprite_data = SHIP2_SPRITE_DATA;
  ship[1].first_sprite = SHIP2_1ST_SPRITE;
  ship[1].ID = 2;
  ship[1].ship_crew = 0x32;
  ship[1].ship_battery.w = 0x0F00;
  ship[1].recharge_rate.w = 0x0010;
  ship[1].max_battery = 0x0F;
  ship[1].aux_data = &aux_buffer[1][0];
  urquan_init(&ship[1]);
}
