/* RPG Map Routines                */
/* by Haroldo de Oliveira Pinheiro */
#ifndef _RPGMAP_H
#define _RPGMAP_H

#define MAP_ENTRY_EXITS "EXI"
#define MAP_ENTRY_PALETTES "PAL"
#define MAP_ENTRY_TILESETS "TIL"
#define MAP_ENTRY_SPRITES "SPR"
#define MAP_ENTRY_ACTORS "ACT"
#define MAP_ENTRY_MAP_UNCOMPRESSED "RAW"
#define MAP_ENTRY_MAP_COMPRESS_RDC "RDC"
#define MAP_ENTRY_MAP_COMPRESS_RLE "RLE"
#define MAP_ENTRY_END "END"


#define EXT_MAP "MAP"
#define EXT_SCRIPT "ZBC"
#define EXT_TILESET "TLC"
#define EXT_TILESET_ATR "ATR"
#define EXT_SPRITE "SPR"
#define EXT_PALETTE "PLT"


#define FIRST_TILE_SPR 768
#define FIRST_TILE_BKG 256

#define SPR_TILE_CNT 96

#define MAP_FLAG_UNCOMPRESSED 0x0000U
/* RDC Compressed map. It will be uncompressed into RAM
   and then treated as an uncompressed map */
#define MAP_FLAG_COMPRESS_RDC 0x0001U
/* RLE Compressed map. It will be uncompressed "on the fly" */
#define MAP_FLAG_COMPRESS_RLE 0x0002U

#define MAP_FLAG_BORDER_STOP 0x0000U
#define MAP_FLAG_BORDER_WRAP 0x0010U
#define MAP_FLAG_BORDER_WARP 0x0020U

#define MAP_DEST_SAME -1
#define MAP_DEST_MIRROR -2


#define MAP_SCR_BLOCK_X 22
#define MAP_SCR_BLOCK_Y 16

typedef struct {
	char signature[4];
	uint version;
	uint flags;
	uint width;
	uint height;
} rpg_map_header;

typedef struct {
	char signature[4];
	uint size;
	uint recs;
} rpg_map_entry_head;

typedef struct {
	uint xpos;
	uint ypos;
	uint palnum;
	uint sprnum;
	char script[8];
} rpg_map_entry_actor;

typedef struct {
	int x;
	int y;
	uint width;
	uint height;
	int destx;
	int desty;
	char destmap[8];
} rpg_map_entry_exit;

extern uint map_flags;
extern uint map_x, map_y;
extern uint map_old_x, map_old_y;
extern uint map_w, map_h;
extern uint map_w_mask, map_h_mask;
extern uint map_coord_x_mask, map_coord_y_mask;

extern rpg_map_entry_exit *map_exit_found;

void rpg_map_load(mapname);
void rpg_map_exit(map_exit, x, y);

void rpg_map_init_ptrs(addr, width, height);

void rpg_map_draw_rectangle(X1, Y1, X2, Y2, value);
uchar rpg_map_get_block(X, Y);
void rpg_map_set_block(X, Y, value);

void rpg_map_repaint(X, Y);

void ref_to_filename(fname, ref, ext);
void rpg_map_search_exit(x, y);

#endif /* _RPGMAP_H */
