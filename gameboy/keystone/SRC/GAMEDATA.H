#ifndef _GAMECHAR_H
#define _GAMECHAR_H

extern unsigned char background_tiles[];
extern unsigned char main_sprites[];

extern unsigned char *block_map[][5];
extern unsigned char *lstair_map[3];
extern unsigned char rstair_map[];
extern unsigned char lstair_top[];
extern unsigned char rstair_top[];
extern unsigned char wall_map[];
extern unsigned char *elevator_map[];

extern unsigned char *block_color[][5];
extern unsigned char *lstair_color[3];
extern unsigned char rstair_color[];
extern unsigned char lstair_top_color[];
extern unsigned char rstair_top_color[];
extern unsigned char wall_color[];

extern unsigned char window_map[];
extern unsigned char window_color_map[];

extern void move_player();
extern void move_thief();

#endif // _GAMECHAR_H
