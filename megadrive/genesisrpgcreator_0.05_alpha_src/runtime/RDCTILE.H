/* Sega Genesis RDC-Compressed Tile Loader */
/* by Haroldo O. Pinheiro                  */

#ifndef _INC_RDCTILE_

#define TILESET_ATR_BLOCK_UP    0x0001U
#define TILESET_ATR_BLOCK_DOWN  0x0002U
#define TILESET_ATR_BLOCK_LEFT  0x0004U
#define TILESET_ATR_BLOCK_RIGHT 0x0008U
#define TILESET_ATR_PALETTE     0x6000U
#define TILESET_ATR_PRIORITY    0x8000U

extern unsigned char huge_buffer[];
extern uint tileset_base_tile;
extern uint tileset_field_addr;
extern uint tileset_attrs[128];

void tileset_load_RDC(fname, basetile, tilecnt);

void put_2x2_block(x, y, blocknum);

#define _INC_RDCTILE_

#endif
