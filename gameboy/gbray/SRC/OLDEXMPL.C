
#include <gb.h>
#include "raytable.h"
#include "speedup.h"
#include "textures.h"

extern UWORD txl_video;
extern UBYTE txl_scale;
extern UWORD txl_tex;
extern UBYTE txl_mask;

void animate_sprite();
void tile_sprite();
void place_sprite();

#define _CGB_RGB(R,G,B) ((B << 10)|(G << 5)|R)

UWORD raycast_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x00L,0x1FL,0x00L),
_CGB_RGB(0x0FL,0x1FL,0x00L),
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
   set_bkg_tiles(0, 0, 16, 14, canvas_map);
}

void putpixel(UBYTE X, UBYTE Y, UBYTE color){
   UWORD addr;
   UBYTE mask,*ptr;
   //
   addr = X & 0xF8U;
   addr = (addr << 4) + Y;
   ptr = (UBYTE *)((addr+addr)+0x8800U);
   mask = 0x80U >> (X & 0x07);
   *ptr = (*ptr&(0xFFU-mask))|mask;
}

void texline();
void texline_maskout();
void cleantexline();

UBYTE level_map[32][32]={
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
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
};

UWORD default_texture[32]={
0xFFFF,0xFFFF,
0xFFFF,0xFFFF,
0xFFFF,0xF00F,
0xFFFF,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xF00F,0xC003,
0xFFFF,0xC003,
0xFFFF,0xF00F,
0xFFFF,0xFFFF,
0xFFFF,0xFFFF
};
UWORD sprite_texture[32]={
0x0FE0,0x0000,
0x0FE0,0x0000,
0x0E00,0x0000,
0x3FC0,0x3000,
0x7FFF,0x7000,
0xFFFF,0xF800,
0xCFF0,0xFC00,
0xC7C0,0xFC00,
0xC7C0,0xFC00,
0xCFF0,0xFC00,
0xFFFF,0xF800,
0x7FFF,0x7000,
0x3FC0,0x3000,
0x0E00,0x0000,
0x0FE0,0x0000,
0x0FE0,0x0000,
};
UWORD sprite_mask[16]={
0x0FE0,
0x0FE0,
0x0E00,
0x3FC0,
0x7FFF,
0xFFFF,
0xCFF0,
0xC7C0,
0xC7C0,
0xCFF0,
0xFFFF,
0x7FFF,
0x3FC0,
0x0E00,
0x0FE0,
0x0FE0,
};

#define _BLIND_AREA 8

fixed ply_x,ply_y;
UBYTE ply_ang;
char  moving;

fixed xray_x,xray_y,xray_dist;
fixed yray_x,yray_y,yray_dist;
WORD  x_inc,y_inc,dist_inc;
UBYTE xtile,ytile;
fixed xspr_x,xspr_y,xspr_dist;
fixed yspr_x,yspr_y,yspr_dist;
UBYTE xsprt,ysprt;

WORD div2(WORD N){
   if(N&0x8000){
      return -((-N) >> 1);
   }else{
      return N >> 1;
   }
}

void x_spr(UBYTE i){
   fixed dist,x,y;

   dist.w = xray_dist.w;
   if(dist.w < xspr_dist.w){
      xspr_dist.w = dist.w;
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
      if(xtile&0x08){
         x_spr(i);
         xtile = 0;
      }
   }
}

void y_spr(UBYTE i){
   fixed dist,x,y;

   dist.w = yray_dist.w;
   if(dist.w < yspr_dist.w){
      yspr_dist.w = dist.w;
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
      if(ytile&0x08){
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

void raycast(){
   UBYTE joy;
   UBYTE i,mask;
   UBYTE interlace,interlace2;

   ply_x.w = 0x0F00;
   ply_y.w = 0x0F00;

   joy = joypad();

   interlace = 0;

   while(!(joy & J_START)){
      if(interlace){
         mask = 0x30;
      }else{
         mask = 0xC0;
      }
      if(moving){ // Se estiver em movimento, desliga o entrela‡amento
         mask = 0xF0;
         moving = FALSE;
      }
      txl_video = 0x8800;
      txl_mask = mask;
      wait_vbl_done();
      for(i = ply_ang - 32+interlace; i != ply_ang+32+interlace; i+=2){
         // Raio X
         x_ray(i);
         // Raio Y
         y_ray(i);

         // Desenha a coluna
         cleantexline();
         txl_video++;
         cleantexline();
         txl_video--;
         if(xray_dist.w < yray_dist.w){
            txl_scale = dist_scale_tabl[xray_dist.b.h];
            txl_tex = textures[xtile-1][(xray_y.b.l >> 3)&0x1E];
            texline();
			txl_video++;
            txl_tex = textures[xtile-1][((xray_y.b.l >> 3)&0x1E)+1];
            texline();
			txl_video--;
         }else{
            txl_scale = dist_scale_tabl[yray_dist.b.h];
            txl_tex = textures[ytile-1][(yray_x.b.l >> 3)&0x1E];
            texline();
			txl_video++;
            txl_tex = textures[ytile-1][((yray_x.b.l >> 3)&0x1E)+1];
            texline();
			txl_video--;
         }

         // Desenha as colunas dos sprites, se necess rio
//         cleantexline(); // Limpa o sprite antigo
         if(  (xspr_dist.b.h != 0xFF)&&
              (xspr_dist.w < yspr_dist.w)&&
              (xspr_dist.w < xray_dist.w)&&
              (xspr_dist.w < yray_dist.w)){
            txl_scale = dist_scale_tabl[xspr_dist.b.h];
            txl_tex = tex_masks[xsprt&0x07][xspr_y.b.l >> 4];
            texline_maskout();
            txl_tex = textures[xsprt&0x07][(xspr_y.b.l >> 3)&0x1E];
            texline();
            txl_video++;
            txl_tex = tex_masks[xsprt&0x07][xspr_y.b.l >> 4];
            texline_maskout();
            txl_tex = textures[xsprt&0x07][((xspr_y.b.l >> 3)&0x1E)+1];
            texline();
            txl_video--;
         }else if((yspr_dist.b.h != 0xFF)&&
                  (yspr_dist.w < xray_dist.w)&&
                  (yspr_dist.w < yray_dist.w)){
            txl_scale = dist_scale_tabl[yspr_dist.b.h];
            txl_tex = tex_masks[ysprt&0x07][yspr_x.b.l >> 4];
            texline_maskout();
            txl_tex = textures[ysprt&0x07][(yspr_x.b.l >> 3)&0x1E];
            texline();
            txl_video++;
            txl_tex = tex_masks[ysprt&0x07][yspr_x.b.l >> 4];
            texline_maskout();
            txl_tex = textures[ysprt&0x07][((yspr_x.b.l >> 3)&0x1E)+1];
            texline();
            txl_video--;
         }

         txl_mask >>= 4;
         if(!txl_mask){
            txl_video += 0x100;
            txl_mask = mask;
         }
      }
      interlace = (interlace+1)&0x01;

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
   }
   while(joypad());
}

void main()
{
  UBYTE i, j;
  UWORD	vidaddr;
  UBYTE mode;

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
  SCX_REG = 256-16;
  SCY_REG = 256-8;

  /* Initialize the window */
  WX_REG = MAXWNDPOSX;
  WY_REG = MAXWNDPOSY;

  init_canvas();

  if(_cpu == 0x11){ // Color GameBoy
     SpeedUp();
     set_bkg_palette(7,1,raycast_palette);
  }

  DISPLAY_ON;
  enable_interrupts();

//  mode = 0;
  mode = 7;

  moving = FALSE;

  while(1){
     raycast();
  }
}
