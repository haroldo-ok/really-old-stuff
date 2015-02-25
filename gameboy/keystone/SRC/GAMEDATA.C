#include <gb.h>
#include "main_spr.h" // caracteres usados para os sprites
#include "bkgtiles.h" // caracteres usados para o fundo
#include "blocks.h"   // blocos usados para construir o mapa
#include "blkcolor.h" // cores usadas para os blocos
#include "keystone.h" // include principal do jogo
//   ATEN€ÇO: Do jeito como os dados estÆo espremidos nessa p gina de ROM,
// apenas um byte a mais que vocˆ adicionar causar  overflow

unsigned char window_map[]={
0x8B,0x8D,0x8A,0x8A,0x8A,0x8A,0x8C,0x8D,0x8A,0x8A,
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
//
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
//
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
//
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x90,0x91,0x92,
0x93,0x94,0x95,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
//
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
//
//0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,
//0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A,0x8A
};

unsigned char window_color_map[]={
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
//
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
//
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
//
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
//
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
//
//0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
//0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,
};

void move_player_norm(){
   UBYTE i;
   if(abs(Player.XSpd) > 1){ //Se o jogador estiver andando
      if(!(frame_ctrl&0x03)){
         Player.frame++;
      }
      if(Player.frame > 4){
         Player.frame = 1;
      }
      if(Player.XSpd > 1){
         Player.XSpd = 1;
      }else if(Player.XSpd < 1){
         Player.XSpd = -1;
      }
      if((Player.frame < 4)&&(Player.frame&0x01)&&(Player.YSpd == 0L)){
         do_sound(_SND_STEP);
      }
   }else{ //Se o jogador estiver parado
      Player.frame = 0;
   }
   if(Player.YSpd){
      Player.YSpd++;
      if(!Player.YSpd){
         Player.YSpd = 1;
      }
      Player.Y += (Player.YSpd >> 4);
      if(Player.Y == player_max_y){
         Player.YSpd = 0;
      }else{
         Player.frame = 5;
      }
   }
   //
   if((wall_list[player_floor].kind == _WAL_LEFT)&&((Player.X-global_x) < 4L)){
      Player.X = global_x + 4L;
   }
   if((wall_list[player_floor].kind == _WAL_RIGHT)&&((Player.X-global_x) > 136L)){
      Player.X = global_x + 136L;
   }
   //
   switch(stair_list[player_floor].kind){
      case _STAIR_NO:
      break;
      case _STAIR_LU:
         if((Player.Y == player_max_y)&&(labs(global_x+(9*8L)-Player.X) < 2)){
            player_mode = _PLY_MODE_STAIR;
            Player.frame = 0;
            Player.X = global_x+(9*8L);
            Player.XSpd = -1;
            Player.YSpd = -1;
            player_floor--;
            player_max_y = (player_floor*5*8L)+(2*8);
            return;
         }
      break;
      case _STAIR_LD:
      break;
      case _STAIR_RU:
         if((Player.Y == player_max_y)&&(labs(global_x+(7*8L)-Player.X) < 2)){
            player_mode = _PLY_MODE_STAIR;
            Player.frame = 0;
            Player.X = global_x+(7*8L);
            Player.XSpd =  1;
            Player.YSpd = -1;
            player_floor--;
            player_max_y = (player_floor*5*8L)+(2*8);
            return;
         }
      break;
      case _STAIR_RD:
      break;
   }
   if((player_floor+1) != curr_level->floor_count){
      switch(stair_list[player_floor+1].kind){
         case _STAIR_NO:
         break;
         case _STAIR_LU:
         break;
         case _STAIR_LD:
            if((Player.Y == player_max_y)&&(labs(global_x+((8*8L)-4)-Player.X) < 2)){
               player_mode = _PLY_MODE_STAIR;
               Player.frame = 0;
               Player.X = global_x+((8*8L)-4);
               Player.XSpd =  1;
               Player.YSpd =  1;
               player_floor++;
               player_max_y = (player_floor*5*8L)+(2*8);
               return;
            }
         break;
         case _STAIR_RU:
         break;
         case _STAIR_RD:
            if((Player.Y == player_max_y)&&(labs(global_x+(8*8L)-Player.X) < 2)){
               player_mode = _PLY_MODE_STAIR;
               Player.frame = 0;
               Player.X = global_x+(8*8L);
               Player.XSpd = -1;
               Player.YSpd =  1;
               player_floor++;
               player_max_y = (player_floor*5*8L)+(2*8);
               return;
            }
         break;
      }
   }
   //
   i = joypad();
   if(i & J_LEFT){
      if(Player.X > 0L){
         Player.X--;
         Player.XSpd = -2;
      }
   }
   if(i & J_RIGHT){
      if(Player.X < ((curr_level->room_count*160L)-16L)){
         Player.X++;
         Player.XSpd = 2;
      }
   }
   if(i & J_UP){
      if(((Player.X-global_x) > 64)&&((Player.X-global_x) < 80)&&(Player.YSpd == 0L)){
         if((elevators[current_room].floors[player_floor])&&
            (elevators[current_room].curr_floor==player_floor)&&
            ((elev_frame_map[elevators[current_room].curr_frame]&0x0F)==6)){
            player_mode = _PLY_MODE_ELEV;
            Player.frame = 0;
            Player.X = global_x+72;
            Player.Y -= 2;
            Player.XSpd =  0;
            Player.YSpd =  0;
            player_max_y = (player_floor*5*8L)+(2*8);
            return;
         }
      }
   }
   if(i & J_DOWN){
      if((abs(Player.XSpd) < 2)&&(!Player.YSpd)){
         Player.frame = 6;
      }
   }
   if(i & J_A){
      if(Player.YSpd == 0){
         Player.YSpd = -18;
         do_sound(_SND_JUMP);
      }
   }
   if(i & J_B){
   }
}

void move_player_stair(){
   if(Player.Y != player_max_y){
      Player.X += Player.XSpd;
      Player.Y += Player.YSpd;
   }else{
      player_mode = _PLY_MODE_NORM;
   }
}

void move_player_elev(){
   WORD i;
   UBYTE j;
   //
   if(elevators[current_room].curr_floor != player_floor){
      player_floor = elevators[current_room].curr_floor;
      Player.Y = (player_floor*5*8L)+(2*8)-2;
      player_max_y = (player_floor*5*8L)+(2*8);
      //
      i = Player.Y-100+3;
      if(i < 0){
         i = 0;
      }else if(i > global_max_y){
         i = global_max_y;
      }
      if(i < global_y){
         while(global_y != i){
            wait_vbl_done();
            global_y--;
            draw_actors();
            SCY_REG = ((global_y+2) & 0xFF);
         }
      }else{
         while(global_y != i){
            wait_vbl_done();
            global_y++;
            draw_actors();
            SCY_REG = ((global_y+2) & 0xFF);
         }
      }
   }
   //
   if((elev_frame_map[elevators[current_room].curr_frame]&0x0F)==6){
      if(!actor_list[0]){
         actor_list[0] = &Player;
      }
   }else{
      actor_list[0] = NULL;
      hide_walk_sprite(0);
   }
   //
   j = joypad();
   if(j & J_DOWN){
      if((elev_frame_map[elevators[current_room].curr_frame]&0x0F)==6){
         player_mode = _PLY_MODE_NORM;
         Player.Y = player_max_y;
      }
   }
}

void move_player(){
   switch(player_mode){
      case _PLY_MODE_NORM:
         move_player_norm();
      break;
      case _PLY_MODE_STAIR:
         move_player_stair();
      break;
      case _PLY_MODE_ELEV:
         move_player_elev();
      break;
   }
}

void move_thief_norm(){
   UBYTE i;
   if(abs(Thief.XSpd) > 1){ //Se o ladrÆo estiver andando
      if(!(frame_ctrl&0x07)){
         Thief.frame++;
      }
      if(Thief.frame > 4){
         Thief.frame = 1;
      }
      if(Thief.XSpd > 1){
         Thief.XSpd = 1;
      }else if(Thief.XSpd < 1){
         Thief.XSpd = -1;
      }
   }else{ //Se o ladrÆo estiver parado
      Thief.frame = 0;
   }
   if(Thief.YSpd){
      Thief.YSpd++;
      if(!Thief.YSpd){
         Thief.YSpd = 1;
      }
      Thief.Y += (Thief.YSpd >> 4);
      if(Thief.Y == thief_max_y){
         Thief.YSpd = 0;
      }else{
         Thief.frame = 5;
      }
   }
   //
   if(thief_waypoint_list[thief_curr_waypoint].mode == _PLY_MODE_STAIR){
      switch((UBYTE)thief_waypoint_list[thief_curr_waypoint].dest){
         case _STAIR_NO:
         break;
         case _STAIR_LU:
            thief_mode = _PLY_MODE_STAIR;
            Thief.frame = 0;
            Thief.XSpd = -1;
            Thief.YSpd = -1;
            thief_floor--;
            thief_max_y = (thief_floor*5*8L)+(2*8);
            return;
         break;
         case _STAIR_LD:
            thief_mode = _PLY_MODE_STAIR;
            Thief.frame = 0;
            Thief.XSpd =  1;
            Thief.YSpd =  1;
            thief_floor++;
            thief_max_y = (thief_floor*5*8L)+(2*8);
            return;
         break;
         case _STAIR_RU:
            thief_mode = _PLY_MODE_STAIR;
            Thief.frame = 0;
            Thief.XSpd =  1;
            Thief.YSpd = -1;
            thief_floor--;
            thief_max_y = (thief_floor*5*8L)+(2*8);
            return;
         break;
         case _STAIR_RD:
            thief_mode = _PLY_MODE_STAIR;
            Thief.frame = 0;
            Thief.XSpd = -1;
            Thief.YSpd =  1;
            thief_floor++;
            thief_max_y = (thief_floor*5*8L)+(2*8);
            return;
         break;
      }
   }
   //
   if(thief_waypoint_list[thief_curr_waypoint].mode == _PLY_MODE_NORM){
      if(thief_waypoint_list[thief_curr_waypoint].dest < Thief.X){
         if(frame_ctrl&0x01){
            Thief.X--;
         }
         Thief.XSpd = -2;
      }else if(thief_waypoint_list[thief_curr_waypoint].dest > Thief.X){
         if(frame_ctrl&0x01){
            Thief.X++;
         }
         Thief.XSpd = 2;
      }else{
         thief_curr_waypoint++;
      }
   }
}

void move_thief_stair(){
   if(Thief.Y != thief_max_y){
      Thief.X += Thief.XSpd;
      Thief.Y += Thief.YSpd;
   }else{
      thief_mode = _PLY_MODE_NORM;
      thief_curr_waypoint++;
   }
}

void move_thief(){
   switch(thief_mode){
      case _PLY_MODE_NORM:
         move_thief_norm();
      break;
      case _PLY_MODE_STAIR:
         move_thief_stair();
      break;
   }
}
