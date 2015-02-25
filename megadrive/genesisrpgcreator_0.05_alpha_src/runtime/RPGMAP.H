/* RPG Map Routines                */
/* by Haroldo de Oliveira Pinheiro */
#ifndef _RPGMAP_H
#define _RPGMAP_H

#define MAP_FLAG_UNCOMPRESSED 0x0000U
/* RDC Compressed map. It will be uncompressed into RAM
   and then treated as an uncompressed map */
#define MAP_FLAG_COMPRESS_RDC 0x0001U
/* RLE Compressed map. It will be uncompressed "on the fly" */
#define MAP_FLAG_COMPRESS_RLE 0x0002U

#define MAP_FLAG_BORDER_STOP 0x0000U
#define MAP_FLAG_BORDER_WRAP 0x0010U
#define MAP_FLAG_BORDER_WARP 0x0020U

#define MAP_SCR_BLOCK_X 22
#define MAP_SCR_BLOCK_Y 16

typedef struct {
	char signature[4];
	uint version;
	uint flags;
	uint width;
	uint height;
	uint pal_ids[4];
	uint tileset_id;
	uint obj_count;
} rpg_map_header;

extern uint map_x, map_y;
extern uint map_old_x, map_old_y;
extern uint map_w, map_h;
extern uint map_w_mask, map_h_mask;
extern uint map_coord_x_mask, map_coord_y_mask;

void rpg_map_init_ptrs(addr, width, height);

void rpg_map_draw_rectangle(X1, Y1, X2, Y2, value);
uchar rpg_map_get_block(X, Y);
void rpg_map_set_block(X, Y, value);

void rpg_map_repaint(X, Y);

#endif /* _RPGMAP_H */
