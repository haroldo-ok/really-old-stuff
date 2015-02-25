#include <gb.h>
#include "melee.h"
#include "urq_ship.h"
#include "urq_data.h"

#define _CGB_RGB(R,G,B) ((B << 10)|(G << 5)|R)

UWORD urquan_palette[]={
_CGB_RGB(0x00L,0x00L,0x00L),
_CGB_RGB(0x1FL,0x1FL,0x00L),
_CGB_RGB(0x00L,0x1FL,0x00L),
_CGB_RGB(0x00L,0x08L,0x00L)
};

UBYTE BATTERY; //***DEBUG***

void handle_urquan(ship_rec *shp){
   urquan_aux_rec *aux_rec;
   shot_rec *shot;
   ship_rec *enm;
   UBYTE X,Y;
   char Ok;
   UBYTE i;
   fixed aux_x,aux_y; //Esse compilador ‚ uma *** M E R D A ! ! ! ***
   //
   aux_rec = shp->aux_data;
   if((joy_status&J_B)&&(!aux_rec->firing_delay)&&(shp->ship_battery.b.h >= URQUAN_FUSION_ENRG)){
      i = 0;
      while((i != URQUAN_MAX_SHOTS)&&(aux_rec->fusion_bolts[i].shot_life)){
         i++;
      }
      if(i != URQUAN_MAX_SHOTS){
         shot = (shot_rec *)(&aux_rec->fusion_bolts[i]);
         shot->angle.w = shp->angle.w;
         shot->shot_x.w = shp->ship_x.w;
         shot->shot_y.w = shp->ship_y.w;
         shot->speed_x.w = shp->speed_x.w;
         shot->speed_y.w = shp->speed_y.w;
         shot->shot_accel.w = 0xA000;
         shot->max_speed.w = 0x7000;
         shot->sprite_data = shp->sprite_data+URQUAN_SHOT_SPR_DATA;
         shot->first_sprite = shp->first_sprite+URQUAN_SHOT_1ST_SPR+i;
         shot->shot_damage = 0x01;
         shot->shot_life = 0x0A;
         aux_rec->firing_delay = 0x10;
         shp->ship_battery.b.h -= URQUAN_FUSION_ENRG;
      }
   }
   if(aux_rec->firing_delay){
      aux_rec->firing_delay--;
   }
   //
   switch(shp->ID){
      case 1:
          enm = &ship[1];
      break;
      case 2:
          enm = &ship[0];
      break;
   }
   //
   for(i = 0; i != URQUAN_MAX_SHOTS; i++){
      shot = (shot_rec *)(&aux_rec->fusion_bolts[i]);
      if(shot->shot_life){
         recenter_shot(shot);
         accelerate_shot(shot,0);
         shot->shot_x.w += shot->speed_x.w;
         shot->shot_y.w += shot->speed_y.w;
         aux_x.w = shot->shot_x.w;
         aux_y.w = shot->shot_y.w;
         calc_pos_scr(&aux_x,&aux_y,&X,&Y,&Ok);
         if(Ok){
            draw_shot(X,Y,shot);
         }else{
            move_sprite(shot->first_sprite, 0, 0);
         }
         //
         if(!shot_life_delay){
            shot->shot_life--;
            if(!shot->shot_life){
               move_sprite(shot->first_sprite, 0, 0);
            }
         }
         //
         if((shot->shot_x.b.h > (enm->ship_x.b.h - 8))&&
            (shot->shot_x.b.h < (enm->ship_x.b.h + 16))&&
            (shot->shot_y.b.h > (enm->ship_y.b.h - 8))&&
            (shot->shot_y.b.h < (enm->ship_y.b.h + 16))){
            enm->ship_crew -= shot->shot_damage;
            shot->shot_life = 0;
            move_sprite(shot->first_sprite, 0, 0);
         }
      }
   }
}

void urquan_init(ship_rec *shp){
   urquan_aux_rec *aux_rec;
   shot_rec *shot;
   UBYTE i;
   //
   aux_rec = (urquan_aux_rec *)shp->aux_data;
   //
   aux_rec->firing_delay = 0;
   //
   shot = aux_rec->fusion_bolts;
   for(i = 0; i < URQUAN_MAX_SHOTS; i++){
      shot->shot_life = 0;
      shot += sizeof(shot_rec);
   }
}
