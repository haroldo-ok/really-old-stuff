
#include <gb.h>
#include <string.h>
#include "raytable.h"
#include "speedup.h"
#include "bkgskin.h"
#include "digits.h"

extern UWORD txl_video;
extern UBYTE txl_scale;
extern UWORD txl_tex;
extern UBYTE txl_mask;

#define _CGB_RGB(R,G,B) ((B << 10)|(G << 5)|R)

UWORD raycast_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x00L,0x1FL,0x00L),
_CGB_RGB(0x0FL,0x1FL,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x00L)
};

UWORD skin_palette1[]={
_CGB_RGB(0x1CL,0x1CL,0x00L),
_CGB_RGB(0x0FL,0x0CL,0x03L),
_CGB_RGB(0x10L,0x10L,0x00L),
_CGB_RGB(0x00L,0x00L,0x00L)
};

UWORD skin_palette2[]={
_CGB_RGB(0x1CL,0x1CL,0x1FL),
_CGB_RGB(0x0CL,0x0CL,0x12L),
_CGB_RGB(0x10L,0x10L,0x18L),
_CGB_RGB(0x00L,0x00L,0x06L)
};

UWORD map_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x00L,0x1FL,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x00L),
_CGB_RGB(0x1FL,0x00L,0x00L)
};

UWORD digit_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x0AL,0x08L,0x08L),
_CGB_RGB(0x12L,0x0FL,0x0FL),
_CGB_RGB(0x1FL,0x00L,0x00L)
};

UWORD map_dot_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x08L,0x08L,0x00L),
_CGB_RGB(0x0FL,0x0FL,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x00L)
};

unsigned char canvas_map[]={
0x80,0x90,0xA0,0xB0,0xC0,0xD0,0xE0,0xF0,
0x00,0x10,0x20,0x30,0x40,0x50,0x60,0x70,
//
0x81,0x91,0xA1,0xB1,0xC1,0xD1,0xE1,0xF1,
0x01,0x11,0x21,0x31,0x41,0x51,0x61,0x71,
//
0x82,0x92,0xA2,0xB2,0xC2,0xD2,0xE2,0xF2,
0x02,0x12,0x22,0x32,0x42,0x52,0x62,0x72,
//
0x83,0x93,0xA3,0xB3,0xC3,0xD3,0xE3,0xF3,
0x03,0x13,0x23,0x33,0x43,0x53,0x63,0x73,
//
0x84,0x94,0xA4,0xB4,0xC4,0xD4,0xE4,0xF4,
0x04,0x14,0x24,0x34,0x44,0x54,0x64,0x74,
//
0x85,0x95,0xA5,0xB5,0xC5,0xD5,0xE5,0xF5,
0x05,0x15,0x25,0x35,0x45,0x55,0x65,0x75,
//
0x86,0x96,0xA6,0xB6,0xC6,0xD6,0xE6,0xF6,
0x06,0x16,0x26,0x36,0x46,0x56,0x66,0x76,
//
0x87,0x97,0xA7,0xB7,0xC7,0xD7,0xE7,0xF7,
0x07,0x17,0x27,0x37,0x47,0x57,0x67,0x77,
//
0x88,0x98,0xA8,0xB8,0xC8,0xD8,0xE8,0xF8,
0x08,0x18,0x28,0x38,0x48,0x58,0x68,0x78,
//
0x89,0x99,0xA9,0xB9,0xC9,0xD9,0xE9,0xF9,
0x09,0x19,0x29,0x39,0x49,0x59,0x69,0x79,
//
0x8A,0x9A,0xAA,0xBA,0xCA,0xDA,0xEA,0xFA,
0x0A,0x1A,0x2A,0x3A,0x4A,0x5A,0x6A,0x7A,
//
0x8B,0x9B,0xAB,0xBB,0xCB,0xDB,0xEB,0xFB,
0x0B,0x1B,0x2B,0x3B,0x4B,0x5B,0x6B,0x7B,
//
0x8C,0x9C,0xAC,0xBC,0xCC,0xDC,0xEC,0xFC,
0x0C,0x1C,0x2C,0x3C,0x4C,0x5C,0x6C,0x7C,
//
0x8D,0x9D,0xAD,0xBD,0xCD,0xDD,0xED,0xFD,
0x0D,0x1D,0x2D,0x3D,0x4D,0x5D,0x6D,0x7D
};

unsigned char col_mask[8]={
0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01
};

void init_canvas(){
   // Primeiro o fundo
   set_bkg_data(0x0C,4,skin_tiles_0);
   set_bkg_data(0x1C,4,skin_tiles_1);
   set_bkg_data(0x2C,4,skin_tiles_2);
   set_bkg_data(0x3C,4,skin_tiles_3);
   set_bkg_data(0x4C,4,skin_tiles_4);
   set_bkg_data(0x5C,4,skin_tiles_5);
   set_bkg_data(0x6C,4,skin_tiles_6);
   set_bkg_data(0x7C,4,skin_tiles_7);
   set_bkg_data(0x8C,4,skin_tiles_8);
   set_bkg_data(0x9C,4,skin_tiles_9);
   set_bkg_data(0xAC,4,skin_tiles_10);
   set_bkg_data(0xBC,4,skin_tiles_11);
   set_bkg_data(0xCC,4,skin_tiles_12);
   set_bkg_data(0xDC,4,skin_tiles_13);
   set_bkg_data(0xEC,4,skin_tiles_14);
   set_bkg_data(0xFC,4,skin_tiles_15);
   set_bkg_tiles(0, 0, 20, 18, skin_map);
   if( _cpu == 0x11){
      VBK_REG = 1;
      set_bkg_tiles(0, 0, 20, 18, skin_attrs);
      VBK_REG = 0;
   }

   // Agora, sim, o canvas
   set_bkg_tiles(2, 1, 16, 12, canvas_map);
}

void do_texline();
void do_texline_maskout();
void do_cleantexline();

UBYTE level1_map[32][32]={
{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,6},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,2,0,0,0,0,6},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,64,0,0,1,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,2,0,0,0,0,0,1},
{1,0,0,0,0,0,1,1,1,1,6,5,1,2,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4},
{1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5}
};

UBYTE level_map[32][32];

typedef struct _level_sprite{
   UBYTE X,Y;
   UBYTE first_frame, last_frame;
   UBYTE current_frame;
   UBYTE energy;
}level_sprite;

level_sprite level_sprites[32];

UBYTE level_sprite_count;

#define _BLIND_AREA  8
#define _BLIND_AREA2 0

UBYTE frame_buffer[16][12][16];

fixed ply_x,ply_y;
UBYTE ply_ang;
char  moving;

UBYTE ply_life;
UBYTE ply_ammo;

UBYTE map_x,map_y;

fixed xray_x,xray_y,xray_dist;
fixed yray_x,yray_y,yray_dist;
WORD  x_inc,y_inc,dist_inc;
UBYTE xtile,ytile;
fixed xspr_x,xspr_y,xspr_dist;
fixed yspr_x,yspr_y,yspr_dist;
UBYTE xsprt,ysprt;
UBYTE curr_scr_x;

void draw_digit(UBYTE X, UBYTE Y, UBYTE base_spr, UBYTE digit){
   digit = digit+digit+0x08;
   //
   move_sprite(base_spr, X, Y);
   set_sprite_tile(base_spr, digit);
   set_sprite_prop(base_spr,0x00);
   Y+=8;
   base_spr++;
   digit++;
   //
   move_sprite(base_spr, X, Y);
   set_sprite_tile(base_spr, digit);
   set_sprite_prop(base_spr,0x00);
}

void update_stbar(){
   UBYTE tmp;

   // Vida
   tmp = ply_life;
   draw_digit(28,138,5,tmp % 10);
   tmp /= 10;
   draw_digit(20,138,3,tmp % 10);
   tmp /= 10;
   draw_digit(12,138,1,tmp % 10);
   // Sinal de porcento
   move_sprite(7,36,146);
   set_sprite_tile(7,0x1C);
   set_sprite_prop(7,0x00);
   // Muni‡Æo
   tmp = ply_ammo;
   draw_digit(78,138,12,tmp % 10);
   tmp /= 10;
   draw_digit(70,138,10,tmp % 10);
   tmp /= 10;
   draw_digit(62,138,8,tmp % 10);
}

void auto_map(){
   unsigned char temp_buf[64],*buf_ptr;
   UBYTE i, j, k, l, m;
   UBYTE ply_dot_x,ply_dot_y;

   if(ply_x.b.h < 4){
      map_x = 0;
   }else if(ply_x.b.h > 27){
      map_x = 24;
   }else{
      map_x = ply_x.b.h - 4;
   }

   if(ply_y.b.h < 4){
      map_y = 0;
   }else if(ply_y.b.h > 27){
      map_y = 24;
   }else{
      map_y = ply_y.b.h - 4;
   }

   ply_dot_x = map_x - ply_x.b.h;
   ply_dot_y = map_y - ply_y.b.h;

   buf_ptr = temp_buf;
   for(m = 0; m != 2; m++){
      for(i = map_y; i != map_y + 8; i++){
         k = 0x00;
         l = 0x00;
         for(j = map_x; j != map_x + 4; j++){
            k <<= 2;
            l <<= 2;
            if(level_map[i][j]){
               k |= 0x03;
               if(level_map[i][j] & 0x40){
                  l |= 0x03;
               }
            }
         }
         *buf_ptr++ = k;
         *buf_ptr++ = l;
         *buf_ptr++ = k;
         *buf_ptr++ = l;
      }
      map_x+=4;
   }
   map_x-=8;

   buf_ptr = temp_buf;
   set_bkg_data(0xCF,1,buf_ptr);
   buf_ptr += 16;
   set_bkg_data(0xEF,1,buf_ptr);
   buf_ptr += 16;
   set_bkg_data(0xDF,1,buf_ptr);
   buf_ptr += 16;
   set_bkg_data(0xFF,1,buf_ptr);

   move_sprite(0,
               (ply_dot_x << 1) + 144,
               (ply_dot_y << 1) + 136);
   set_sprite_tile(0,((~ply_ang)+1) >> 5);
   set_sprite_prop(0,0x01);
}

WORD div2(WORD N){
   if(N&0x8000){
      return -((-N) >> 1);
   }else{
      return N >> 1;
   }
}

void x_spr(UBYTE i){
   fixed dist,x,y;

   if(((ply_ang >= ( 32+_BLIND_AREA2))&&(ply_ang < ( 96-_BLIND_AREA2)))||
      ((ply_ang >= (160+_BLIND_AREA2))&&(ply_ang < (223-_BLIND_AREA2)))) return;

   dist.w = xray_dist.w;
   if(dist.w < xspr_dist.w){
      xspr_dist.w = dist.w+div2(dist_inc);
      xspr_x.w = xray_x.w;
      xspr_y.w = xray_y.w;
      xsprt = xtile;
   }
}

void x_ray(UBYTE i){
   xray_x.w = ply_x.w;
   xray_y.w = ply_y.w;
   xray_dist.w = 0;
   xtile = level_map[xray_y.b.h][xray_x.b.h];

   if((i < _ANG_90-_BLIND_AREA)||(i > _ANG_270+_BLIND_AREA)){
      x_inc = 0x0100;
   }else if((i > _ANG_90+_BLIND_AREA)&&(i < _ANG_270-_BLIND_AREA)){
      x_inc = -0x0100;
   }else{ // Rejeita o raio
      xray_dist.w = 0xFFFF;
      xtile = 1;
   }
   y_inc = xray_tabl[i];
   dist_inc = xdist_tabl[i];

   xspr_dist.w = 0xFFFF;
   while(!xtile){
      xray_x.w += x_inc;
      xray_y.w += y_inc;
      xray_dist.w += dist_inc;
      xtile = level_map[xray_y.b.h&0x1F][xray_x.b.h&0x1F];
      if(xtile&0x40){
         x_spr(i);
         xtile = 0;
      }
   }
}

void y_spr(UBYTE i){
   fixed dist,x,y;

   if(((ply_ang < ( 32-_BLIND_AREA2))||(ply_ang >= (223+_BLIND_AREA2)))||
      ((ply_ang < (160-_BLIND_AREA2))&&(ply_ang >= ( 96+_BLIND_AREA2)))) return;

   dist.w = yray_dist.w;
   if(dist.w < yspr_dist.w){
      yspr_dist.w = dist.w+div2(dist_inc);
      yspr_x.w = yray_x.w;
      yspr_y.w = yray_y.w;
      ysprt = ytile;
   }
}

void y_ray(UBYTE i){
   yray_x.w = ply_x.w;
   yray_y.w = ply_y.w;
   yray_dist.w = 0;
   ytile = level_map[yray_y.b.h][yray_x.b.h];

   if((i > _ANG_0+_BLIND_AREA)&&(i < _ANG_180-_BLIND_AREA)){
      y_inc = 0x0100;
   }else if((i < 255-_BLIND_AREA)&&(i > _ANG_180+_BLIND_AREA)){
      y_inc = -0x0100;
   }else{ // Rejeita o raio
      yray_dist.w = 0xFFFF;
      ytile = 1;
   }
   x_inc = yray_tabl[i];
   dist_inc = ydist_tabl[i];

   yspr_dist.w = 0xFFFF;
   while(!ytile){
      yray_x.w += x_inc;
      yray_y.w += y_inc;
      yray_dist.w += dist_inc;
      ytile = level_map[yray_y.b.h&0x1F][yray_x.b.h&0x1F];
      if(ytile&0x40){
         y_spr(i);
         ytile = 0;
      }
   }
}

void thrust(UBYTE ang){
   ply_x.w += cos_tabl[ang&0xFF];
   ply_y.w -= cos_tabl[(ang+_ANG_90)&0xFF];
   if(level_map[ply_y.b.h&0x1F][ply_x.b.h&0x1F]){
      ply_x.w -= cos_tabl[ang&0xFF];
      ply_y.w += cos_tabl[(ang+_ANG_90)&0xFF];
   }
}

void handle_sprites(){
   level_sprite *spr;
   UBYTE cnt;
   UBYTE old_x,old_y;

   spr = level_sprites;
   cnt = level_sprite_count;
   while(cnt){
      old_x = spr->X;
      old_y = spr->Y;
      level_map[old_y][old_x] = 0;
      //
      if(spr->X < ply_x.b.h){
         spr->X++;
      }else if(spr->X > ply_x.b.h){
         spr->X--;
      }
      if(spr->Y < ply_y.b.h){
         spr->Y++;
      }else if(spr->Y > ply_y.b.h){
         spr->Y--;
      }
      if((level_map[spr->Y][old_x])||
         (level_map[old_y][spr->X])||
         (level_map[spr->Y][spr->X])||
         ((spr->X==ply_x.b.h)&&(spr->Y==ply_y.b.h))){
         spr->X = old_x;
         spr->Y = old_y;
      }
      //
      switch(spr->current_frame - spr->first_frame){
         case 0:
            spr->current_frame++;
         break;
         case 1:
            spr->current_frame--;
         break;
      }
      level_map[spr->Y][spr->X] = spr->current_frame;
      //
      spr++;
      cnt--;
   }
}

void raycast(){
   UBYTE joy;
   UBYTE i,j,mask;
   UBYTE increment,shift_val;

   ply_x.w = 0x0F00;
   ply_y.w = 0x0F00;

   joy = joypad();

   while(!(joy & J_START)){
      mask = 0xC0;
      increment = 1;
      shift_val = 2;
      if(moving){ // Se estiver em movimento, reduz a resolu‡Æo
         mask = 0xF0;
         increment = 2;
         shift_val = 4;
         moving = FALSE;
      }
      txl_video = (UWORD)frame_buffer[0][0];
      txl_mask = mask;
//      memset((UBYTE *)txl_video,0,(16UL*12UL));
      curr_scr_x = 0;
      wait_vbl_done();
      for(i = ply_ang - 32; i != ply_ang+32; i+=increment){
         // Raio X
         x_ray(i);
         // Raio Y
         y_ray(i);

         // Desenha a coluna
         if(xray_dist.w < yray_dist.w){
            txl_scale = dist_scale_tabl[xray_dist.b.h];
            do_texline(xtile-1,(xray_y.b.l >> 3)&0x1E);
			txl_video++;
            do_texline(xtile-1,((xray_y.b.l >> 3)&0x1E)+1);
			txl_video--;
         }else{
            txl_scale = dist_scale_tabl[yray_dist.b.h];
            do_texline(ytile-1,(yray_x.b.l >> 3)&0x1E);
			txl_video++;
            do_texline(ytile-1,((yray_x.b.l >> 3)&0x1E)+1);
			txl_video--;
         }

         // Desenha as colunas dos sprites, se necess rio
         if(  (xspr_dist.b.h != 0xFF)&&
              (xspr_dist.w < yspr_dist.w)&&
              (xspr_dist.w < xray_dist.w)&&
              (xspr_dist.w < yray_dist.w)){
            txl_scale = dist_scale_tabl[xspr_dist.b.h];
            do_texline_maskout(xsprt-1,xspr_y.b.l >> 4);
            do_texline(xsprt-1,(xspr_y.b.l >> 3)&0x1E);
            txl_video++;
            do_texline_maskout(xsprt-1,xspr_y.b.l >> 4);
            do_texline(xsprt-1,((xspr_y.b.l >> 3)&0x1E)+1);
            txl_video--;
         }else if((yspr_dist.b.h != 0xFF)&&
                  (yspr_dist.w < xray_dist.w)&&
                  (yspr_dist.w < yray_dist.w)){
            txl_scale = dist_scale_tabl[yspr_dist.b.h];
            do_texline_maskout(ysprt-1,yspr_x.b.l >> 4);
            do_texline(ysprt-1,(yspr_x.b.l >> 3)&0x1E);
            txl_video++;
            do_texline_maskout(ysprt-1,yspr_x.b.l >> 4);
            do_texline(ysprt-1,((yspr_x.b.l >> 3)&0x1E)+1);
            txl_video--;
         }

         txl_mask >>= shift_val;
         if(!txl_mask){
            txl_video += (16UL*12UL);
            txl_mask = mask;
//            memset((UBYTE *)txl_video,0,(16UL*12UL));
         }

         curr_scr_x+=increment;
      }

      // Lˆ o joystick
      joy = joypad();
      if(joy & J_UP){
         thrust(ply_ang);
         moving = TRUE;
      }
      if(joy & J_DOWN){
         thrust(ply_ang+_ANG_180);
         moving = TRUE;
      }
      if(joy & J_LEFT){
         ply_ang -= 8;
         moving = TRUE;
      }
      if(joy & J_RIGHT){
         ply_ang += 8;
         moving = TRUE;
      }

      handle_sprites();

      // Desenha o buffer na tela
      j = 0x80;
      for(i=0;i != 16; i++){
         set_bkg_data(j,12,(unsigned char *)frame_buffer[i][0]);
         j+=0x10;
      }
      auto_map();
      // Limpa o buffer
      memset(frame_buffer,0,sizeof(frame_buffer));
   }
   while(joypad());
}

void init_raycast(){
   UBYTE i,j;

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
   BGP_REG = OBP0_REG = OBP1_REG = 0xE4U;

   /* Initialize the background */
   SCX_REG = 0;
   SCY_REG = 0;

   /* Initialize the window */
   WX_REG = MAXWNDPOSX;
   WY_REG = MAXWNDPOSY;

   init_canvas();

   set_sprite_data(0x00,0x80,digits_dat);

   if(_cpu == 0x11){ // Color GameBoy
      set_bkg_palette(7,1,raycast_palette);
      set_bkg_palette(6,1,skin_palette1);
      set_bkg_palette(5,1,skin_palette2);
      set_bkg_palette(4,1,map_palette);
      //
      set_sprite_palette(7,1,digit_palette);
      set_sprite_palette(6,1,map_dot_palette);
   }

   memcpy(level_map,level1_map,32L*32L);

   level_sprite_count = 0;
   for(i = 0; i != 32; i++){
      for(j = 0; j != 32; j++){
         if(level_map[i][j] & 0x40){
            level_sprites[level_sprite_count].X = j;
            level_sprites[level_sprite_count].Y = i;
            level_sprites[level_sprite_count].first_frame = level_map[i][j];
            level_sprites[level_sprite_count].last_frame = level_map[i][j]+6;
            level_sprites[level_sprite_count].current_frame = level_map[i][j];
            level_sprites[level_sprite_count].energy = 1;
            level_sprite_count++;
         }
      }
   }

   ply_life = 100;
   ply_ammo = 255;
   update_stbar();

   DISPLAY_ON;
   enable_interrupts();

   moving = FALSE;
}
