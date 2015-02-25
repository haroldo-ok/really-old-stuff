#ifndef _MELEE_H
#define _MELEE_H

#define _CGB_RGB(R,G,B) ((B << 10)|(G << 5)|R)

typedef struct _ship_rec{
   UBYTE sprite_data;
   UBYTE first_sprite;
   UBYTE ID;
   //
   fixed ship_x,ship_y;
   fixed speed_x,speed_y;
   fixed angle;
   //
   fixed max_speed;
   fixed ship_accel;
   //
   UBYTE ship_crew;	
   fixed ship_battery;
   fixed recharge_rate;
   UBYTE max_battery;
   //
   void *aux_data;
} ship_rec;

typedef struct _shot_rec{
   UBYTE sprite_data;
   UBYTE first_sprite;
   //
   fixed shot_x,shot_y;
   fixed speed_x,speed_y;
   fixed angle;
   //
   fixed max_speed;
   fixed shot_accel;
   //
   UBYTE shot_damage;	
   UBYTE shot_life;
   //
   UBYTE AI;
} shot_rec;

#define SHIP1_SPRITE_DATA 0x00
#define SHIP2_SPRITE_DATA 0x60

#define SHIP1_1ST_SPRITE 0x00
#define SHIP2_1ST_SPRITE 0x10

#define SHIP_TEMP_SIZE 0x7FU

#define STATUS_BAR_1ST_DIGIT 0x0E

extern UBYTE ship_frames[4][9];
extern UBYTE ship_props[4];
extern UBYTE ship_angles[16][2];
extern UBYTE small_ship_angles[16];

extern unsigned char bgstars[];
extern unsigned char bgstars_c[];
extern unsigned char stbar_colors[];

extern UWORD stars_palette[];
extern UWORD stbar_palette[];

extern fixed bkg_x,bkg_y;
extern fixed cntr_x,cntr_y;
extern ship_rec ship[2];
extern char small_ships;
extern UBYTE joy_status;
extern UBYTE shot_life_delay;

extern void draw_ship(UBYTE X, UBYTE Y, ship_rec *ship);
extern void draw_small_ship(UBYTE X, UBYTE Y, ship_rec *ship);
extern void draw_missile(UBYTE X, UBYTE Y, UBYTE angle);
extern void draw_missile_ship(UBYTE X, UBYTE Y, ship_rec *ship);
extern void accelerate_ship(ship_rec *ship, UBYTE dir);
extern void accelerate_shot(shot_rec *shot, UBYTE dir);
extern void control_ship_joy(UBYTE joy, ship_rec *ship);
extern void recenter_shot(shot_rec *shot);
extern void calc_scroll();
extern void calc_pos_scr(fixed *rel_x, fixed *rel_y, UBYTE *scr_x, UBYTE *scr_y, char *Ok);
extern void draw_ships();
extern void status_bar_number(UBYTE X, UBYTE Y, UBYTE crew_batt);
extern void update_status_bar();
extern void set_melee_colors();
extern void melee_init();

#endif /*_MELEE_H*/
